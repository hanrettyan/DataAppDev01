
library(shiny)
library(crosstalk)
library(DT)
library(leaflet)
library(shinydashboard)

# LOAD DATA
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")

# UI
ui <- fluidPage(
    fluidRow(
        column(6, dataTableOutput("araptusdatatable")),
        column(6, leafletOutput("araptusmap"))
        )
        )
        
# SERVER
server <- function(input, output, session) {
    # Create SHARED DATA for Crosstalk to work
    shared_araptus <- SharedData$new(araptusdata)
    
    # Araptus Map
    output$araptusmap <- renderLeaflet({
        leaflet(shared_araptus) %>%
            addProviderTiles( providers$Esri.WorldImagery, group = "Imagery") %>%
            
            addMarkers( label = ~Site, group = "Araptus Data") %>%
            
            addLayersControl(
                overlayGroups = c("Elevation Raster", "Araptus Data"),
                options = layersControlOptions(collapsed = FALSE)
            )
    })
    
    # Aratpus Data Table
    output$araptusdatatable <- DT::renderDataTable(shared_araptus, server= FALSE,
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
}

# RUN APP
shinyApp(ui, server)