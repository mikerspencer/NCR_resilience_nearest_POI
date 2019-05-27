# Postcode to POI script

# Read POI
v.in.ascii input=/home/mspencer/Downloads/community_centre_poi.csv output=POI_community_centre separator=comma skip=1 x=4 y=5

# PC to nearest POI
v.net input=OpenRoads points=postcodes output=roads_net1 operation=connect thresh=400 arc_layer=1 node_layer=2

# connect hospitals to streets as layer 3
v.net input=roads_net1 points=POI_community_centre output=roads_net2 operation=connect thresh=400 arc_layer=1 node_layer=3

# shortest paths from schools (points in layer 2) to nearest hospitals (points in layer 3)
v.net.distance in=roads_net2 out=pc_to_POI_ComCen flayer=2 to_layer=3

# Join postcode and distance tables
g.copy vector=postcodes@PERMANENT,postcodes_distance
v.db.join map=postcodes_distance column=cat other_table=pc_to_POI_ComCen other_column=cat
 
# Make a km column
v.db.addcolumn map=postcodes_distance columns="dist_km double precision"
v.db.update map=postcodes_distance column=dist_km qcol="dist/1000"

# Write to gpkg
v.out.ogr -s input=postcodes output=pc_2_stjames format=ESRI_Shapefile output_layer=pc_2_station
