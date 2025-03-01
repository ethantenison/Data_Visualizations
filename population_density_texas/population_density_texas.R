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
library(stringr)
library(viridis)
library(RColorBrewer)
library(rayshader)

population_2017<- read.csv("./population_density_texas/ACS_17_5YR_B01003_with_ann.csv")
names(population_2017) <- as.matrix(population_2017[1, ])
population_2017 <- population_2017[-1, ]
population_2017 <- clean_names(population_2017)
population_2017$geography <- as.character(population_2017$geography)
population_2017$id2 <- as.character(population_2017$id2)
population_2017$geography <- str_replace(population_2017$geography, "County, Texas","")


counties <- st_read("./population_density_texas/Texas_County_Boundaries_Detailed.shp")
counties$CNTY_NM <- as.character(counties$CNTY_NM)
counties$CNTY_FIPS <- as.character(counties$CNTY_FIPS)

county_area <- read.csv("./population_density_texas/DEC_10_SF1_GCTPH1.US05PR_with_ann.csv")
names(county_area) <- as.matrix(county_area[1, ])
county_area<- county_area[-1, ]
county_area <- clean_names(county_area)
county_area$geographic_area_2 <- as.character(county_area$geographic_area_2)
county_area$geographic_area_2 <- as.character(county_area$geographic_area_2)
county_area$target_geo_id2<- as.character(county_area$target_geo_id2)
county_area$geographic_area_2 <- str_replace(county_area$geographic_area_2, "County","")

density2017 <- left_join(population_2017, county_area, by = c("id2" = "target_geo_id2"))
density2017 <- select(density2017, id2,geography.x,estimate_total, area_in_square_miles_land_area)
density2017$estimate_total <- as.character(density2017$estimate_total)
density2017$estimate_total <- as.numeric(density2017$estimate_total)
density2017$area_in_square_miles_land_area<- as.character(density2017$area_in_square_miles_land_area)
density2017$area_in_square_miles_land_area <- as.numeric(density2017$area_in_square_miles_land_area)
density2017<- mutate(density2017, density = estimate_total/area_in_square_miles_land_area)

density_map2017 <- left_join(density2017, counties, by = c("id2" = "CNTY_FIPS"))
density_map2017 <- st_as_sf(density_map2017)
density_map2017 <- rename(density_map2017, County = geography.x)

mymap <- ggplot(data=density_map2017) + geom_sf(aes(fill =density)) + scale_fill_viridis_c(name="Persons/mile^2") +theme_bw() + ggtitle("Density of Texas Counties (2019)")


texas_density <- plot_gg(mymap,multicore=TRUE,width=5,height=4,fov = 70, zoom =.4)
#render_depth(focallength=100,focus=0.9)
#render_snapshot()

filename_movie = tempfile()

phivechalf = 30 + 60 * 1/(1 + exp(seq(-7, 20, length.out = 180)/2))
phivecfull = c(phivechalf, rev(phivechalf))
thetavec = -90 + 60 * sin(seq(0,359,length.out = 360) * pi/180)
zoomvec = 0.45 + 0.2 * 1/(1 + exp(seq(-5, 20, length.out = 180)))
zoomvecfull = c(zoomvec, rev(zoomvec))

render_movie(filename = filename_movie, type = "custom", frames = 360,  phi = phivecfull, zoom = zoomvecfull, theta = thetavec)

