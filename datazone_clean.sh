# Clean and smooth datazones

v.clean input=DataZone_2011@PERMANENT output=DataZone_2011_clean type=point,line,area tool=rmarea,rmsa,snap,rmline thres=10000,0,10,0.00

v.generalize input=DataZone_2011_clean@NCR output=DataZone_2011_clean_smooth method=douglas threshold=10
