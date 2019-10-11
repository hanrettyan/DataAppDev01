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
library(htmlwidgets)


# Load data (using different sets of sample data)
classesdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRFdDGgmoI-9prZL45gHOixA4thITZleI_DkEZ49E-JqELRaxn8K46YM1HaBb0bBgkV5Xx-YrxKRgYM/pub?output=csv")
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
rast <- raster("alt_22.tif")
rvaschoolsdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRQG-5hP_znz9xCFwR8VeAQv4B1ALFZIljlIhhnZHtdmd57c5JDJz3O0Y5SkkaHEDVJB7CJetDPb6KW/pub?gid=466483422&single=true&output=csv")

#################
###### UI #######
#################

ui <- dashboardPage(skin = "yellow",
                    
                    # Page header/app title
                    dashboardHeader(title = "ENVS Class Data Portal", titleWidth = 300),
                    
                    # Sidebar/list of classes to open pages
                    dashboardSidebar(
                        # The following line hides the toggle button on the dashboardheader:
                        tags$script(JS("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'hidden';")),
                        sidebarMenu(
                            menuItem("ENVS Data Portal", tabName= "dataportal", icon = icon("dashboard")),
                            menuItem("Undergraduate Classes",
                                     menuSubItem("ENVS 401", tabName = "envs401", icon = icon("bar-chart-o")),
                                     menuSubItem("ENVS 402", tabName = "envs402", icon = icon("bar-chart-o"))),
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
                                    fillPage(
                                        h1("Data Portal of ENVS data for classes."),
                                        tags$img(src="ces_logo.png", width="80%", align="center"),  
                                        h2("Blahdy blah blah blahhhhh!"),  
                                        h2(" "),  # Just makes blank space between lines,
                                        h4("This is cool!")
                                    )),
                            
                            #ENVS 401 page: preferred layout
                            tabItem(tabName = "envs401",
                                    fillPage(
                                        h1("Class Data for fake ENVS401"),
                                        h2(" "), # Just makes blank space between lines.
                                        h4("Select rows or use the selection tool on the map to filter data for download."),
                                        # valueBox( format( sum(araptusdata$Sites), big.mark=",", scientific=FALSE), "Total Sites", icon=icon("couch")),
                                        title = "Data",
                                        h2(" "),  # Just makes blank spaces between lines.
                                        dataTableOutput("araptusdatatable", height = 400)  
                                    ),
                                    
                                    fillPage(
                                        title = "Map",
                                        leafletOutput("araptusmap", height = 350)  
                                    )),
                            
                            
                            #ENVS 402 page: 
                            tabItem(tabName = "envs402",
                                    fillPage(
                                        h1("Class Data for fake ENVS402"),
                                        h2(" "), # Just makes blank space between lines.
                                        h4("Select rows or use the selection tool on the map to filter data for download."),
                                        # valueBox( format( sum(araptusdata$Sites), big.mark=",", scientific=FALSE), "Total Sites", icon=icon("couch")),
                                        title = "Data",
                                        h2(" "),  # Just makes blank spaces between lines.
                                        dataTableOutput("rvaschoolsdatatable", height = 400)  
                                    ),
                                    
                                    fillPage(
                                        title = "Map",
                                        leafletOutput("rvaschoolsmap", height = 350)  
                                    )),
                            
                            
                            #ENVS 602 page
                            #This page just includes a datatable as a fillpage
                            tabItem(tabName = "envs602",
                                    fillPage(
                                        h1("Class Data for fake ENVS602"),
                                        title = "Envs 602 data",
                                        dataTableOutput("classesdatatable", height = 500))),
                            
                            
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
            
            addMarkers(lng= ~Longitude, lat= ~Latitude, label = ~Site, group = "Araptus Data") %>%
            
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
            
            addProviderTiles( providers$Esri.WorldStreetMap, group = "Streets") %>%
            
            addMarkers(lng = ~X, lat = ~Y, label = ~School.Name, group = "RVA Schools Data") %>%
            
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

