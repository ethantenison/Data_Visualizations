library(tidyverse) 
library(dplyr) #data manipulation
library(janitor) #data cleaning
library(scales) #to convert to percent 
library(lubridate) #converting time 
library(readr) #reading in data
library(openxlsx) #reading excel sheets 
library(readr) #necessary for reading in files. 
library(sf)
library(ggplot2)

population_2017<- read.csv("./population_density_texas/ACS_17_5YR_B01003_with_ann.csv")
names(population_2017) <- as.matrix(population_2017[1, ])
population_2017 <- population_2017[-1, ]
population_2017 <- clean_names(population_2017)
population_2017 <- rename(population_2017, zipcode = id2)
population_2017$zipcode <- as.character(population_2017$zipcode)
population_2017$zipcode <- as.numeric(population_2017$zipcode)


zip <- st_read("./population_density_texas/tl_2015_us_zcta510.shp")
zip <- zip %>% select(GEOID10, ALAND10, geometry) %>% rename(zipcode = GEOID10, total_area = ALAND10)
zip$zipcode = as.character(zip$zipcode)
zip$zipcode = as.numeric(zip$zipcode)


density2017 <- left_join(population_2017, zip, by = "zipcode")
density2017 <- mutate(density2017, total_area = total_area * 0.0000003861)
density2017$estimate_total <- as.numeric(density2017$estimate_total)
density2017<- mutate(density2017, density = estimate_total/total_area)
density2017 <- st_as_sf(density2017)
density2017 <- mutate(density2017, logdensity = log(density))



