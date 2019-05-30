x@data %>% 
   as_tibble() %>% 
   group_by(datazone) %>% 
   summarise(dist = median(dist_km, na.rm=T)) %>% 
   mutate(dist = replace_na(dist, -999)) %>% 
   drop_na() %>% 
   write_csv("Downloads/temp.csv")
