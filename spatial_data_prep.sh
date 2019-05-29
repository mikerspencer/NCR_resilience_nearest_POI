# Data prep

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
