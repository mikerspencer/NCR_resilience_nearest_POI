# --------------------------------
# --------------------------------
# NCR resilience
# Distance to feature as a loop
# --------------------------------
# --------------------------------

library(rgrass7)
library(RSQLite)

# Postcodes to road network
system("g.copy --overwrite vector=postcodes_geography,postcodes_distance")
system("v.net input=OpenRoads points=postcodes_distance output=roads_net1 operation=connect thresh=400 arc_layer=1 node_layer=2")

# Read POI
# v.in.ascii input=/home/mspencer/Downloads/community_centre_poi.csv output=POI_community_centre separator=comma skip=1 x=4 y=5

ids = unique()

lapply(ids, function(i){
   
   # connect POI to streets as layer 3
   execGRASS("v.net", flags=c("overwrite"),
             parameters=list(input="roads_net1",
                             points=i,
                             output=roads_net2,
                             operation="connect",
                             thresh=400,
                             arc_layer=1,
                             node_layer=3))
   
   # shortest paths
   system("v.net.distance --overwrite in=roads_net2 out=pc_to_POI flayer=2 to_layer=3")
   
   # Join postcode and distance tables
   system("g.copy --overwrite vector=postcodes_distance,postcodes_temp")
   system("v.db.join map=postcodes_temp column=cat other_table=pc_to_POI other_column=cat")
   
   # Make a km column
   system("v.db.addcolumn map=postcodes_temp columns='dist_km double precision'")
   system("v.db.update map=postcodes_temp column=dist_km qcol='dist/1000'")
   
   # Join to POI data
   v.db.join map=postcodes_temp column=tcat other_table=POI other_column=cat subset_columns=int_1,str_1
   system("v.db.renamecolumn map=postcodes_temp@NCR column=int_1,POI_ref")
   system("v.db.renamecolumn map=postcodes_temp@NCR column=str_1,POI_name")
   system("db.dropcolumn -f table=postcodes_temp column=tcat")
   
   # Write to csv
})

# Read csvs and write to GPKG attribute table
