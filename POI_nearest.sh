# Postcode to POI script

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

# Join postcodes to Hebridies routes
v.extract --overwrite input=Local_authorities@PERMANENT output=Hebridies
v.select ainput=pc_to_POI_ComCen_Hebridies@NCR binput=Hebridies output=pc_to_POI_ComCen_Hebridies operator=overlap
v.db.join map=pc_to_POI_ComCen_Hebridies column=cat other_table=postcodes_distance other_column=cat subset_columns=postcode,POI_ref,datazone


# Write to gpkg
v.out.ogr -s input=postcodes_distance output=/home/mspencer/Downloads/pc_to_resilience.gpkg format=GPKG output_layer=postcodes
v.out.ogr -a input=DataZone_2011@PERMANENT output=/home/mspencer/Downloads/pc_to_resilience.gpkg format=GPKG output_layer=DataZone_2011
