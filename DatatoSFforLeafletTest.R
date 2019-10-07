# This is a testing space for determining if I have to convert the .CSV data using SF to spatial data for using the CROSSTALK function

library(sf)
library(rgdal)


# ---------------------------------------------
# CONVERT CSV DATA INTO SF:
araptusdata <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQNCFb3C1oSia_dN5ISXusrGqwVSFibt0_zkqq7wiNtW_tl1DM-Ch-fIKKmIz_ijXxdrKux6qvvy8yD/pub?output=csv")
str(araptusdata)

# CONVER THE DATA INTO SIMPLE FEATURE AND SPECIFIC THE COORDINATES AND COORDINATE REFERENCE SYSTEM:
plot_araptusdata <- st_as_sf(araptusdata, coords = c("Latitude", "Longitude"), crs = "+init=epsg:4326")

# CONRFIRM CRS:
st_crs(plot_araptusdata)

# ---------------------------------------------
# INSTALL CROSSTALK:
# First you will need to install this version of crosstalk: 
devtools::install_github("dmurdoch/leaflet@crosstalk4")

# ---------------------------------------------
# CONVERT SF OBJECTS TO SPATIAL?:
# Or, if you use sf and dplyr for most spatial tasks (like me) convert an sf object to Spatial:
# library(dplyr)
# library(sf)
# shapes_to_filter <- st_read("data/features.shp") %>% as('Spatial')  # sf import to 'Spatial Object'
# sf:::as_Spatial() 

  
# ---------------------------------------------
# CREATE SHARED DATA OBJECTS FOR LEAFLET AND A COPY FOR THE DATATABLE:
# Then create an sd object for leaflet, and a data frame copy for the filters (IMPORTANT: note how the group for sd_df is set using the group names from the sd_map) :
  
# library(crosstalk)
# sd_map <- SharedData$new(shapes_to_filter)
# sd_df <- SharedData$new(as.data.frame(shapes_to_filter@data), group = sd_map $groupName())

  
# ---------------------------------------------
# CREATE CROSSTALK FILTERS USING SD_DF:
# Create crosstalk filters using sd_df:
# filter_select("filterid",  "Select Filter Label", sd_df, ~SomeColumn)


# ---------------------------------------------
# CREATE THE MAP USING SD_MAP OBJECT:
# library(leaflet)
# leaflet() %>%
# addProviderTiles("OpenStreetMap") %>%
# addPolygons(data = sd_map)


# ---------------------------------------------
# THE DATATABLE ALSO NEEDS TO USE THE SD_DF OBJECT:
# library(DT)
# datatable(sd_df)

