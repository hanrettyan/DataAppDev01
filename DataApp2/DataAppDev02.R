# THIS APP WAS BUILT TO MODEL A GEOSPATIAL DATA PORTAL FOR ENVS CLASSES WITH INTERACTIVE LEAFLET MAPS AND DATATABLES.

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
library(htmlwidgets)


# Load data (using different sets of sample data)
classesdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRFdDGgmoI-9prZL45gHOixA4thITZleI_DkEZ49E-JqELRaxn8K46YM1HaBb0bBgkV5Xx-YrxKRgYM/pub?output=csv")
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
rvaschoolsdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRQG-5hP_znz9xCFwR8VeAQv4B1ALFZIljlIhhnZHtdmd57c5JDJz3O0Y5SkkaHEDVJB7CJetDPb6KW/pub?gid=466483422&single=true&output=csv")
# rast <- raster("RVAtemp.tif") # Used this as an example of pulling into leaflet. Not necessary here.

#################
###### UI #######
#################

ui <- dashboardPage(skin = "yellow",
                    
                    # Page header/app title
                    dashboardHeader(title = "ENVS Class Data Portal", titleWidth = 300),
                    
                    # Sidebar/list of classes to open pages
                    dashboardSidebar(
                        # The following line hides the toggle button on the dashboardheader:
                        # tags$script(JS("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'hidden';")),
                        sidebarMenu(
                            menuItem("ENVS Data Portal", tabName= "dataportal", icon = icon("dashboard")),
                            menuItem("Undergraduate Classes",
                                     menuSubItem("ENVS 302", tabName = "envs302", icon = icon("bar-chart-o")),
                                     menuSubItem("ENVS 401", tabName = "envs401", icon = icon("bar-chart-o"))),
                            menuItem("Graduate Classes",
                                     menuSubItem("ENVS 602", tabName = "envs602", icon = icon("bar-chart-o")),
                                     menuSubItem("ENVS 603", tabName = "envs603", icon = icon("bar-chart-o")))
                        )
                    ),
                    
                    # Body of pages
                    dashboardBody(
                        # shinyDashboardThemes(theme="blue_gradient"),  <-- not working at this time, but keep in case I figure it out.
                        tabItems(
                            
                            #ENVS DATA PORTAL HOME PAGE:
                            tabItem(tabName = "dataportal",
                                    fluidPage(
                                        tags$img(src = "ces_logo.png", width="90%", align="center"),
                                        h1("Data Portal of ENVS data for classes."),
                                        h2("This is a sample home space for a data portal!"),  
                                        h2(" "),  # Just makes blank space between lines,
                                        h4("This will be a great place to host some data.")
                                        )
                                        
                                    ),
                            
                            #ENVS 401 page: preferred layout
                            tabItem(tabName = "envs401",
                                    fluidPage(
                                        h1("Class Data for fake ENVS401"),
                                        h2(" "), # Just makes blank space between lines.
                                        h4("Select rows or use the selection tool on the map to filter data for download."),
                                        # valueBox( format( sum(araptusdata$Sites), big.mark=",", scientific=FALSE), "Total Sites", icon=icon("couch")),
                                        title = "Data",
                                        h2(" "),  # Just makes blank spaces between lines.
                                        dataTableOutput("araptusdatatable", height = 400)  
                                    ),
                                    
                                    fluidPage(
                                        title = "Map",
                                        leafletOutput("araptusmap", height = 400)  
                                    )),
                            
                            
                            #ENVS 602 page: 
                            tabItem(tabName = "envs602",
                                    fluidPage(
                                        h1("Class Data for fake ENVS602"),
                                        h2(" "), # Just makes blank space between lines.
                                        h4("Select rows or use the selection tool on the map to filter data for download."),
                                        # valueBox( format( sum(araptusdata$Sites), big.mark=",", scientific=FALSE), "Total Sites", icon=icon("couch")),
                                        title = "Data",
                                        h2(" "),  # Just makes blank spaces between lines.
                                        dataTableOutput("rvaschoolsdatatable", height = 400)  
                                    ),
                                    
                                    fluidPage(
                                        title = "Map",
                                        leafletOutput("rvaschoolsmap", height = 400)  
                                    )),
                            
                            
                            #ENVS 302 page
                            #This page just includes a datatable as a fillpage
                            tabItem(tabName = "envs302",
                                    fluidPage(
                                        h1("Class Data for fake ENVS302"),
                                        h4(" "),
                                        h2(" "),
                                        title = "Envs 302 data",
                                        dataTableOutput("classesdatatable", height = 400))),
                            
                            
                            #ENVS 603 page
                            #This page is empty!
                            tabItem(tabName = "envs603",
                                    fluidPage(
                                        h1("Oh no! This page is empty!"),
                                        h3("This data portal will be designed to host Shapefiles, Rasters, File Geodatabases, KML files and Tabular data."),
                                        title = "Envs 603 data"))
                            
                            
                            
                            
                        )
                    ))




#################
#### SERVER #####
#################

# CREATE SHARED DATA OBJECTS FOR LEAFLETS AND A COPY FOR THE DATATABLES:
sd_map_araptus <- SharedData$new(araptusdata)
sd_df_araptus <- SharedData$new( araptusdata , group = sd_map_araptus$groupName())

sd_map_rvaschools <- SharedData$new(rvaschoolsdata)
sd_df_rvaschools <- SharedData$new(rvaschoolsdata, group = sd_map_rvaschools$groupName())

server <- function(input, output) {
    # Output for ARAPTUS datatable
    output$araptusdatatable = DT::renderDataTable({sd_df_araptus},
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
        leaflet(sd_map_araptus) %>%
            addProviderTiles( providers$Esri.WorldImagery, group = "Imagery") %>%
            
            addCircles(color = "yellow", lng= ~Longitude, lat= ~Latitude, label = ~Site, group = "Araptus Data") %>%
            
            addLayersControl(
                overlayGroups = c("Araptus Data"),
                options = layersControlOptions(collapsed = FALSE)
            )
    })
    
    

    # Output for RVA SCHOOLS datatable
    output$rvaschoolsdatatable = DT::renderDataTable({sd_df_rvaschools},
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
                                                              visible = FALSE, targets= c(0,1,4,5,6))),
                                                      buttons = list(
                                                          "csv", "excel", "pdf")),
                                                  colnames = c("Long" = "X",
                                                               "Lat" = "Y",
                                                               "Name" = "School.Name",
                                                               "Street" = "Street",
                                                               "City" = "City",
                                                               "State" = "State",
                                                               "Zip" = "Zip",
                                                               "Level" = "Level",
                                                               "Nmbr" = "Number"))
    
    
    
    # Output for RVA SCHOOLS leaflet:
    output$rvaschoolsmap <- renderLeaflet({
        leaflet(sd_map_rvaschools) %>%
            
            # addRasterImage(rast, group = "Heat Islands") %>%   # Used this as a sample. Not necessary here. 
            
            addProviderTiles( providers$Esri.WorldStreetMap, group = "Streets") %>%
            
            addMarkers(lng = ~X, lat = ~Y, label = ~School.Name, group = "Richmond Schools") %>%
            
            addLayersControl(
                overlayGroups = c("Richmond Schools", "Streets"),
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
                                                          "csv", "excel", "pdf")),
                                                  colnames = c("Class Num" = "CLASS.NUMBER",
                                                               "Name" = "CLASS.NAME",
                                                               "Grade" = "GRADE",
                                                               "Year" = "YEAR",
                                                               "Semester" = "SEMESTER")
    )
}

#################
#### RUN APP ####
#################

shinyApp(ui = ui, server = server)

