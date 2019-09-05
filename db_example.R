# --------------------------------
# --------------------------------
# Example db read and join
# --------------------------------
# --------------------------------

library(RSQLite)
library(tidyverse)
library(rgdal)
library(sf)


# --------------------------------
# Extract data

db = dbConnect(SQLite(), dbname="~/Downloads/pc_to_resilience.gpkg")

# db structure
dbListTables(db)
dbListFields(db, "postcode_to_POI")

# Distances
postcodes = dbGetQuery(db, "SELECT datazone, resilience_type, median(dist_km) AS dist
                       FROM postcode_to_POI
                       GROUP BY datazone, resilience_type") %>% 
   as_tibble() %>% 
   drop_na() %>% 
   spread(resilience_type, dist)

dbDisconnect(db)
rm(db)

# Boundaries
datazones = readOGR("/home/mspencer/Downloads/pc_to_resilience.gpkg", "DataZone_2011")


# --------------------------------
# Join boundaries and distances

datazones@data = datazones@data %>% 
   left_join(postcodes, by = c(DataZone = "datazone"))


# --------------------------------
# Convert to sf and plot

x = st_as_sf(datazones)

x %>% 
   select(Emergency, Medical, Everyday) %>% 
   plot()
