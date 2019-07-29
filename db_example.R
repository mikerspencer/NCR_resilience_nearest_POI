# --------------------------------
# --------------------------------
# Example db read and join
# --------------------------------
# --------------------------------

library(RSQLite)
library(tidyverse)
library(rgdal)

db = dbConnect(SQLite(), dbname="~/Downloads/pc_to_resilience.gpkg")

# db structure
dbListTables(db)
dbListFields(db, "postcode_to_POI")

postcodes = dbGetQuery(db, "SELECT datazone, median(dist_km) AS dist
                       FROM postcode_to_POI
                       GROUP BY datazone") %>% 
   as_tibble()

datazones = readOGR("/home/mspencer/Downloads/pc_to_resilience.gpkg", "DataZone_2011")

datazones@data = datazones@data %>% 
   left_join(postcodes, by = c(DataZone = "datazone"))
