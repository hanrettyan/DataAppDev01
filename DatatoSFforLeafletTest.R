# This is a testing space for determining if I have to convert the .CSV data using SF to spatial data for using the CROSSTALK function

library(sf)
library(rgdal)
library(crosstalk) # This produces an error, I think we need the other version listed below anyways.


# ---------------------------------------------
# CONVERT CSV DATA INTO SF:
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
str(araptusdata)

# CONVERT THE DATA INTO SIMPLE FEATURE AND SPECIFIC THE COORDINATES AND COORDINATE REFERENCE SYSTEM:
plot_araptusdata <- st_as_sf(araptusdata, coords = c("Longitude", "Latitude"), crs = "+init=epsg:3857")

# CONRFIRM CRS:
st_crs(plot_araptusdata)

# Test plot spatial object:
plot(plot_araptusdata$geometry, main = "Test Plot")

# Output to shapefile (for fun):
st_write(plot_araptusdata, "PlotAraptusData.shp", driver = "ESRI Shapefile")

# ---------------------------------------------
# INSTALL CROSSTALK:
# First you will need to install this version of crosstalk: 
devtools::install_github("dmurdoch/leaflet@crosstalk4")

# ---------------------------------------------
# CONVERT SF OBJECTS TO SPATIAL?:
# Or, if you use sf and dplyr for most spatial tasks (like me) convert an sf object to Spatial:
library(dplyr)
shapes_to_filter <- st_read("PlotAraptusData.shp") %>% as('Spatial')  # sf import to 'Spatial Object'

  
# ---------------------------------------------
# CREATE SHARED DATA OBJECTS FOR LEAFLET AND A COPY FOR THE DATATABLE:
# Then create an sd object for leaflet, and a data frame copy for the filters (IMPORTANT: note how the group for sd_df is set using the group names from the sd_map):

library(crosstalk)
sd_map <- SharedData$new(shapes_to_filter)
sd_df <- SharedData$new(as.data.frame(shapes_to_filter@data), group = sd_map $groupName())
# sd <- SharedData$new(plot_araptusdata)



# CREATE MAP AND DATATABLE USING SHARED DATA OBJECTS: 
bscols(
  leaflet(sd_map) %>%
    addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") %>%
    # addRasterImage(rast, opacity = 0.5, group = "Elevation Raster") %>%
    addMarkers( label = ~Site, group = "Araptus Data") %>%
    addLayersControl(
      overlayGroups = c("Elevation Raster", "Araptus Data"),
      options = layersControlOptions(collapsed = FALSE)
    ),
  
  datatable(sd_df, extensions = "Scroller", style="Bootstrap", class="compact", width="100%",
            options=list(deferRender=TRUE, scrollY=100, scroller=TRUE))
)
