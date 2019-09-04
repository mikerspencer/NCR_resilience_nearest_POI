# --------------------------------
# --------------------------------
# NCR resilience
# Distance to feature as a loop
# --------------------------------
# --------------------------------

library(rgrass7)
library(RSQLite)
library(tidyverse)

# Postcodes to road network
system("g.copy --overwrite vector=postcodes_geography,postcodes_distance")
system("v.net --overwrite input=OpenRoads points=postcodes_distance output=roads_net1 operation=connect thresh=500 arc_layer=1 node_layer=2")

# Read POI
# system("v.in.ascii --overwrite input=/home/mspencer/Downloads/resilience_indicators.csv output=POIs separator=comma skip=1 x=3 y=4") 

ids = unique(read_csv("~/Downloads/resilience_indicators.csv")$description)

lapply(ids, function(i){
   
   execGRASS("v.extract", flags=c("overwrite"),
             parameters = list(input="POIs",
                               where=paste0("str_3 = '", i, "'"),
                               output="points"))
   
   # connect POI to streets as layer 3
   execGRASS("v.net", flags=c("overwrite"),
             parameters=list(input="roads_net1",
                             points="points",
                             output="roads_net2",
                             operation="connect",
                             threshold=500,
                             arc_layer="1",
                             node_layer="3"))
   
   # shortest paths
   system("v.net.distance --overwrite in=roads_net2 out=pc_to_POI flayer=2 to_layer=3")
   
   # Join postcode and distance tables
   system("g.copy --overwrite vector=postcodes_distance,postcodes_temp")
   system("v.db.join map=postcodes_temp column=cat other_table=pc_to_POI other_column=cat")
   
   # Make a km column
   system("v.db.addcolumn map=postcodes_temp columns='dist_km double precision'")
   system("v.db.update map=postcodes_temp column=dist_km qcol='dist/1000'")
   
   # Join to POI data
   system("v.db.join map=postcodes_temp column=tcat other_table=points other_column=cat subset_columns=int_1,str_3")
   system("v.db.renamecolumn map=postcodes_temp@NCR column=int_1,POI_ref")
   system("v.db.renamecolumn map=postcodes_temp@NCR column=str_3,POI_type")
   system("db.dropcolumn -f table=postcodes_temp column=tcat")
   
   # Write to csv
   x = which(ids == i)
   system(paste0("v.out.ogr -s input=postcodes_temp output=/home/mspencer/Downloads/points_", x, ".csv format=CSV"))
})

# Write to gpkg
system("v.out.ogr -a -s input=DataZone_2011@PERMANENT output=/home/mspencer/Downloads/pc_to_resilience.gpkg format=GPKG output_layer=DataZone_2011")

# Read csvs and write to GPKG attribute table
f = list.files("~/Downloads", pattern = "^points_*", full.names = T)
res_types = read_csv("Downloads/resilience_codes.csv")

db = dbConnect(SQLite(), dbname="~/Downloads/pc_to_resilience.gpkg")

dbSendQuery(conn=db,
            "CREATE TABLE postcode_to_POI
            (postcode TEXT,
            ag_parish TEXT,
            local_authority TEXT,
            datazone TEXT,
            output_area TEXT,
            nuts2 TEXT,
            nuts3 TEXT,
            dist REAL,
            dist_km REAL,
            POI_ref INTEGER,
            POI_name TEXT,
            POI_type TEXT,
            resilience_type TEXT,
            PRIMARY KEY (postcode, POI_type))")

lapply(f, function(i){
   y = read_csv(i) %>% 
      left_join(res_types, by=c(POI_type = "description"))
   dbWriteTable(db, name="postcode_to_POI", y, append=T, row.names=F)
})

dbDisconnect(db)
rm(db)
