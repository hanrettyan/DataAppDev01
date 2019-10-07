# THIS APP IS ATTEMPTING TO CREATE A DASHBOARD THAT HOSTS A DATATABLE AND LEAFLET FOR DATA IN EACH DIFFERENT CLASS TAB
#
# NOTES: Cannot place same datatableoutput, leafletoutput on more than one page inside dashboard!!! This should only be an issue
# when trying to use sample data to develop app.
# Raster image contained within Shiny app folder- not programmed to pull from alt data source at this time. ARE DISABLED IN MAPS
# TEMPORARILY TO INCREASE PROCESSING TIME FOR APP DEVELOPMENT.






# Load necessary libraries
library(shiny)
library(crosstalk)
library(DT)
library(raster)
library(leaflet)
library(dplyr)
library(shinydashboard)

# Load data (using different sets of sample data)
classesdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRFdDGgmoI-9prZL45gHOixA4thITZleI_DkEZ49E-JqELRaxn8K46YM1HaBb0bBgkV5Xx-YrxKRgYM/pub?output=csv")
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
rast <- raster("alt_22.tif")


#################
###### UI #######
#################

ui <- dashboardPage(skin = "yellow",
                    
                    # Page header/app title
                    dashboardHeader(title = "Testing Shiny App"),
                    
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
                        tabItems(
                            #ENVS 601 page
                            #This page uses FILLPAGE for the datatable at the top of the page, and then adds the map as a box below:
                            tabItem(tabName = "envs601",
                                    fillPage(
                                        title = "Data", solidHeader = "DATA",
                                        dataTableOutput("araptusdatatable", height = 500)
                                    ),
                                    
                                    box(
                                        title = "Map", solidHeader = TRUE,
                                        leafletOutput("araptusmap")
                                    )),
                            
                            #ENVS 602 page
                            #This page just includes a datatable as a fillpage
                            tabItem(tabName = "envs602",
                                    fillPage(
                                        title = "Envs 602 data",
                                        dataTableOutput("classesdatatable"))),
                            
                            #ENVS 603 page
                            #This page includes the datatable and the map as components of the FILLPAGE
                            tabItem(tabName = "envs603",
                                    fillPage(
                                        title = "Envs 603 data",
                                        dataTableOutput("araptusdatatable2"),
                                        leafletOutput("araptusmap2")))
                            
                            
                            
                            
                        )
                    ))
                    

                            
                            
#################
#### SERVER #####
#################

server <- function(input, output) {
    # Output for ARAPTUS datatable
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
                                                      lengthChange = FALSE,
                                                      dom = "Blrtip",
                                                      autoWidth = TRUE,
                                                      # deferRender = TRUE,
                                                      # scrollY = 10,
                                                      scrollX = 30,
                                                      # scroller = TRUE,
                                                      columnDefs = list(
                                                          list(
                                                              visible = TRUE)),
                                                      buttons = list(
                                                          "csv", "excel")),
                                                  colnames = c("Site" = "Site",
                                                               "Long" = "Longitude",
                                                               "Lat" = "Latitude",
                                                               "No. Males" = "Males",
                                                               "No. Females" = "Females",
                                                               "Suitability" = "Suitability"))
    
    
    
    # Output for ARAPTUS leaflet:
    output$araptusmap <- renderLeaflet({
        leaflet(araptusdata) %>%
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
                                                              visible = TRUE)),
                                                      buttons = list(
                                                          "csv", "excel")),
                                                  colnames = c("Site" = "Site",
                                                               "Long" = "Longitude",
                                                               "Lat" = "Latitude",
                                                               "No. Males" = "Males",
                                                               "No. Females" = "Females",
                                                               "Suitability" = "Suitability"))
    
    
    
    # Output for ARAPTUS leaflet 2:
    output$araptusmap2 <- renderLeaflet({
        leaflet(araptusdata) %>%
            addProviderTiles( providers$Esri.WorldImagery, group = "Imagery") %>%
            
            # addRasterImage(rast, opacity = 0.5, group = "Elevation Raster") %>%
            
            addMarkers( label = ~Site, group = "Araptus Data") %>%
            
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