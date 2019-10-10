# THIS APP IS ATTEMPTED TO INTEGRATE WHAT WAS SUCESSFULLY CREATED IN DATAAPPDEV01 AS A DASHBOARD AS WELL AS DATATOSFORLEAFLETTEST.R 
# WHICH SUCCESSFULLY USED CROSSTALK BETWEEN LEAFLET MAP AND DATATABLE OUTPUTS:

# Load necessary libraries
# library(devtools)
# install_github("nik01010/dashboardthemes")   <-- for custom theme but command shinyDashboardThemes not functioning at this time...
library(shiny)
library(crosstalk)
library(DT)
library(raster)
library(leaflet)
library(dplyr)
library(shinydashboard)
library(sf)
library(rgdal)


# Load data (using different sets of sample data)
classesdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRFdDGgmoI-9prZL45gHOixA4thITZleI_DkEZ49E-JqELRaxn8K46YM1HaBb0bBgkV5Xx-YrxKRgYM/pub?output=csv")
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
rast <- raster("alt_22.tif")


#################
###### UI #######
#################

ui <- dashboardPage(skin = "yellow",
                    
                    # Page header/app title
                    dashboardHeader(title = "ENVS Class Data Portal", titleWidth = 250),
                    
                    # Sidebar/list of classes to open pages
                    dashboardSidebar(
                        sidebarMenu(
                            menuItem("ENVS Data Portal", tabName= "dataportal", icon = icon("dashboard")),
                            menuItem("ENVS 401", tabName = "envs401", icon = icon("bar-chart-o")),
                            menuItem("ENVS 602", tabName = "envs602", icon = icon("bar-chart-o")),
                            menuItem("ENVS 603", tabName = "envs603", icon = icon("bar-chart-o"))
                        )
                    ),
                    
                    # Body of pages
                    dashboardBody(
                        # shinyDashboardThemes(theme="blue_gradient"),  <-- not working at this time, but keep in case I figure it out.
                        tabItems(
                            
                            #ENVS DATA PORTAL HOME PAGE:
                            tabItem(tabName = "dataportal",
                                    fillPage(
                                        h1("Data Portal of ENVS data for classes."),
                                        tags$img(src="ces_logo.png", width="75%", align="center"),
                                        h2("Blahdy blah blah blahhhhh!"),
                                        h4("This is cool!")
                                    )),
                            
                            #ENVS 601 page: preferred layout
                            tabItem(tabName = "envs601",
                                    fillPage(
                                        h1("Class Data for ENVS601"),
                                        # valueBox( format( sum(araptusdata$Sites), big.mark=",", scientific=FALSE), "Total Sites", icon=icon("couch")),
                                        title = "Data",
                                        dataTableOutput("araptusdatatable", height = 400)  
                                    ),
                                    
                                    fillPage(
                                        title = "Map",
                                        leafletOutput("araptusmap", height = 350)  
                                    )),
                            
                            
                            #ENVS 602 page
                            #This page just includes a datatable as a fillpage
                            tabItem(tabName = "envs602",
                                    fillPage(
                                        h1("Class Data for ENVS602"),
                                        title = "Envs 602 data",
                                        dataTableOutput("classesdatatable"))),
                            
                            
                            #ENVS 603 page
                            #This page is empty!
                            tabItem(tabName = "envs603",
                                    fillPage(
                                        h1("Surprise! This page is empty!"),
                                        title = "Envs 603 data"))
                            
                            
                            
                            
                        )
                    ))




#################
#### SERVER #####
#################

# CONVERT THE DATA INTO SIMPLE FEATURE AND SPECIFIC THE COORDINATES AND COORDINATE REFERENCE SYSTEM:


# ---------------------------------------------
# CREATE SHARED DATA OBJECTS FOR LEAFLET AND A COPY FOR THE DATATABLE:
sd_map <- SharedData$new(araptusdata)
sd_df <- SharedData$new( araptusdata , group = sd_map$groupName())

server <- function(input, output) {
    # Output for ARAPTUS datatable
    output$araptusdatatable = DT::renderDataTable({sd_df},
                                                  filter="top",
                                                  fillContainer = TRUE,
                                                  extensions = c("Buttons",
                                                                 "Scroller"),
                                                  rownames = FALSE,
                                                  style = "bootstrap",
                                                  class = "compact",
                                                  height = "100%",
                                                  server = FALSE,
                                                  options = list(
                                                      lengthChange = FALSE,
                                                      dom = "Blrtip",
                                                      autoWidth = TRUE,
                                                      # deferRender = TRUE,
                                                      # scrollY = 10,
                                                      scrollX = 30,
                                                      # scroller = TRUE,
                                                      columnDefs = list(
                                                          list(
                                                              visible = FALSE, targets= c(1:2))),
                                                      buttons = list(
                                                          "csv", "excel", "pdf")),
                                                  colnames = c("Site No." = "Site",
                                                               "Longitude" = "Longitude",
                                                               "Latitude" = "Latitude",
                                                               "No. Males" = "Males",
                                                               "No. Females" = "Females",
                                                               "Suitability" = "Suitability"))
    
    
    
    # Output for ARAPTUS leaflet:
    output$araptusmap <- renderLeaflet({
        leaflet(sd_map) %>%
            addProviderTiles( providers$Esri.WorldImagery, group = "Imagery") %>%
            
            # addRasterImage(rast, opacity = 0.5, group = "Elevation Raster") %>%
            
            addMarkers( label = ~Site, group = "Araptus Data") %>%
            
            addLayersControl(
                overlayGroups = c("Elevation Raster", "Araptus Data"),
                options = layersControlOptions(collapsed = FALSE)
            )
    })
    
    # Output for CLASSES datatable:
    output$classesdatatable = DT::renderDataTable({classesdata},
                                                  filter="top",
                                                  fillContainer = TRUE,
                                                  extensions = c("Buttons",
                                                                 "Scroller"),
                                                  rownames = FALSE,
                                                  style = "bootstrap",
                                                  class = "compact",
                                                  height = "100%",
                                                  options = list(
                                                      lengthChange = FALSE,
                                                      dom = "Blrtip",
                                                      deferRender = TRUE,
                                                      # scrollY = 10,
                                                      scrollX = 30,
                                                      # scroller = TRUE,
                                                      columnDefs = list(
                                                          list(
                                                              visible = TRUE)),
                                                      buttons = list(
                                                          "csv", "excel")),
                                                  colnames = c("Class Num" = "CLASS.NUMBER",
                                                               "Name" = "CLASS.NAME",
                                                               "Grade" = "GRADE",
                                                               "Year" = "YEAR",
                                                               "Semester" = "SEMESTER")
    )
    
    
    # Output for ARAPTUS datatable 2:
    output$araptusdatatable2 = DT::renderDataTable({araptusdata},
                                                   filter="top",
                                                   fillContainer = TRUE,
                                                   extensions = c("Buttons",
                                                                  "Scroller"),
                                                   rownames = FALSE,
                                                   style = "bootstrap",
                                                   class = "compact",
                                                   height = "100%",
                                                   options = list(
                                                       lengthChange = FALSE,
                                                       dom = "Blrtip",
                                                       autoWidth = TRUE,
                                                       # deferRender = TRUE,
                                                       # scrollY = 10,
                                                       scrollX = 30,
                                                       # scroller = TRUE,
                                                       columnDefs = list(
                                                           list(
                                                               visible = FALSE, targets=c(1:2))),
                                                       buttons = list(
                                                           "csv", "excel")),
                                                   colnames = c("Site" = "Site",
                                                                "Long" = "Longitude",
                                                                "Lat" = "Latitude",
                                                                "No. Males" = "Males",
                                                                "No. Females" = "Females",
                                                                "Suitability" = "Suitability"))
    
    
    
    
    
}

#################
#### RUN APP ####
#################

shinyApp(ui = ui, server = server)

