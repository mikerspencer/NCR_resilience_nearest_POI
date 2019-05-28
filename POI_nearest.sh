# Postcode to POI script

# Prep postcode data
g.copy --overwrite vector=postcodes@PERMANENT,postcodes_geography
v.db.renamecolumn map=postcodes_distance@NCR column=str_1,postcode
db.dropcolumn -f table=postcodes_distance column=int_1
db.dropcolumn -f table=postcodes_distance column=int_2
db.dropcolumn -f table=postcodes_distance column=int_3
db.dropcolumn -f table=postcodes_distance column=str_2
db.dropcolumn -f table=postcodes_distance column=str_3
db.dropcolumn -f table=postcodes_distance column=str_4
db.dropcolumn -f table=postcodes_distance column=str_5
db.dropcolumn -f table=postcodes_distance column=str_6
db.dropcolumn -f table=postcodes_distance column=str_7

# Get boundary lookups
v.db.addcolumn map=postcodes_distance@NCR columns="ag_parish VARCHAR(35),local_authority VARCHAR(30),datazone VARCHAR(30),output_area VARCHAR(30),nuts2 VARCHAR(30),nuts3 VARCHAR(30)"
v.what.vect map=postcodes_distance@NCR column=ag_parish query_map=Ag_parishes@PERMANENT query_column=PARName
v.what.vect map=postcodes_distance@NCR column=local_authority query_map=Local_authorities@PERMANENT query_column=CODE
v.what.vect map=postcodes_distance@NCR column=datazone query_map=DataZone_2011@PERMANENT query_column=DataZone
v.what.vect map=postcodes_distance@NCR column=output_area query_map=OutputArea_2011@PERMANENT query_column=code
v.what.vect map=postcodes_distance@NCR column=nuts2 query_map=NUTS2@PERMANENT query_column=nuts218cd
v.what.vect map=postcodes_distance@NCR column=nuts3 query_map=NUTS3@PERMANENT query_column=nuts318cd

g.copy --overwrite vector=postcodes_geography,postcodes_distance

# Read POI
# v.in.ascii input=/home/mspencer/Downloads/community_centre_poi.csv output=POI_community_centre separator=comma skip=1 x=4 y=5

# PC to nearest POI
v.net input=OpenRoads points=postcodes_distance output=roads_net1 operation=connect thresh=400 arc_layer=1 node_layer=2

# connect hospitals to streets as layer 3
v.net input=roads_net1 points=POI_community_centre output=roads_net2 operation=connect thresh=400 arc_layer=1 node_layer=3

# shortest paths from schools (points in layer 2) to nearest hospitals (points in layer 3)
v.net.distance in=roads_net2 out=pc_to_POI_ComCen flayer=2 to_layer=3

# Join postcode and distance tables
v.db.join map=postcodes_distance column=cat other_table=pc_to_POI_ComCen other_column=cat
 
# Make a km column
v.db.addcolumn map=postcodes_distance columns="dist_km double precision"
v.db.update map=postcodes_distance column=dist_km qcol="dist/1000"

# Join to POI data
v.db.join map=postcodes_distance column=tcat other_table=POI_community_centre other_column=cat subset_columns=int_1,str_1
v.db.renamecolumn map=postcodes_distance@NCR column=int_1,POI_ref
v.db.renamecolumn map=postcodes_distance@NCR column=str_1,POI_name
db.dropcolumn -f table=postcodes_distance column=tcat

# Write to gpkg
v.out.ogr -s input=postcodes_distance output=/home/mspencer/Downloads/pc_to_resilience.gpkg format=GPKG output_layer=postcodes
v.out.ogr -a input=DataZone_2011@PERMANENT output=/home/mspencer/Downloads/pc_to_resilience.gpkg format=GPKG output_layer=DataZone_2011
