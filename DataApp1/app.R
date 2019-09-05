# Attempting to bring everything over from the Rmd into a Shiny app to support real-time data updates within running application.

# Load necessary libraries
library(shiny)
library(crosstalk)
library(DT)
library(raster)
library(leaflet)
library(dplyr)
library(shinydashboard)

# Load data
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
# rast <- raster("alt_22.tif")
# Currently getting error; cannot create RasterLayer file does not exist

# Create a custom marker for fun map
bluepointicon <- makeIcon(
    iconUrl = "https://www.twinword.com/wp-content/uploads/2016/10/location-icon-vector-blue-pin.svg",
    iconWidth = 30,
    iconHeight = 30
)

#################
###### UI #######
#################

ui <- dashboardPage(
    
    # Page header/app title
    dashboardHeader(title = "Testing Crosstalk"),
    
    # Sidebar/list of classes to open pages
    dashboardSidebar(
        sidebarMenu(
            menuItem("ENVS 601", tabName = "envs601", icon = icon("dashboard")),
            menuItem("ENVS 602", tabName = "envs602", icon = icon("dashboard")),
            menuItem("ENVS 603", tabName = "envs603", icon = icon("dashboard"))
        )
    ),
    
    # Body of pages
    dashboardBody(
        fluidRow(
            box(
                title = "Data",
                dataTableOutput("araptusdata", height = 250)),
            
            box(
                title = "Map",
                leafletOutput("araptusmap", height = 250))
            
            
        )
    )
)


#################
#### SERVER #####
#################

server <- function(input, output, session) {
    # Output for datatable
    output$araptusdatatable = DT::renderDataTable({araptusdata}, filter="top")
    
    # Output for leaflet:
    output$araptusmap <- renderLeaflet({
        leaflet(araptusdata) %>%
            addProviderTiles( providers$Esri.WorldImagery, group = "Imagery") %>%
            
            addMarkers( icon = bluepointicon, label = ~Site, group = "Araptus Data") %>%
            
            addLayersControl(
                overlayGroups = c("Elevation Raster", "Araptus Data"),
                options = layersControlOptions(collapsed = FALSE)
            )
    })
 
}

#################
#### RUN APP ####
#################

shinyApp(ui = ui, server = server)
