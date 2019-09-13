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
# Currently getting error; cannot create RasterLayer; file does not exist

# A custom marker for fun map
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
        fluidPage(
            box(title = "Data",
                dataTableOutput("araptusdatatable")),
            
            box(title = "Map",
                leafletOutput("araptusmap"))
            
            
        )
    )
)


#################
#### SERVER #####
#################

server <- function(input, output, session) {
    # Output for datatable
    output$araptusdatatable = DT::renderDataTable({araptusdata},
                                                  filter="top",
                                                  fillContainer = TRUE,
                                                  extensions = c("Buttons",
                                                                 "Scroller"),
                                                  rownames = FALSE,
                                                  style = "bootstrap",
                                                  class = "compact",
                                                  height = "100%",
                                                  options = list(
                                                      # dom = "Blrtip",
                                                      deferRender = TRUE,
                                                      scrollY = 10,
                                                      scroller = TRUE,
                                                      columnDefs = list(
                                                          list(
                                                              visible = TRUE)),
                                                      buttons = list(
                                                          "csv", "excel")),
                                                  colnames = c("Site Number" = "Site",
                                                               "Long" = "Longitude",
                                                               "Lat" = "Latitude",
                                                               "No. Males" = "Males",
                                                               "No. Females" = "Females",
                                                               "Suitability" = "Suitability"))
    
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
