---
title: "Mexico Population Density by Municipality"
author: "Ethan Tenison"
date: "11/15/2019"
output: html_document
---

```{r, libraries}
library(dplyr)
library(tidyverse)
library(sf)
library(cartography)
library(janitor)
library("mxmaps")

```


```{r, Mexico Pop Density}

mexico <- st_read("./Mexico/Muni_2012gw.shp")
mexico <- clean_names(mexico)

population <- df_mxmunicipio

mexico_map <- left_join(mexico, population, by = c("CVE_MUN"="municipio_code"))

```