#!/usr/bin/Rscript

################################################################################
### Case data file cleaning script
## 
## Created on: 2014-11-22
## Author: Kazuki Yoshida
################################################################################


### Prepare environment
################################################################################

## Configure parallelization
library(doMC)           # Parallel backend to foreach (used in plyr)
registerDoMC()          # Turn on multicore processing
options(cores = 4)
options(mc.cores = 4)

## Load packages
library(magrittr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(survival)

## Configure sink()
if (sink.number() != 0) {sink()}
..scriptFileName.. <- gsub("^--file=", "", Filter(function(x) {grepl("^--file=", x)}, commandArgs()))
if (length(..scriptFileName..) == 1) {
    sink(file = paste0(..scriptFileName.., ".txt"), split = TRUE)
}
options(width = 120)


### Load data
################################################################################

load(file = "dataList.RData")
## 01: SDR locations africa
## 02: Sub-national time series data on Ebola cases
## 03: Redcross Official Dataset
## 04: West Africa Ebola Movement Restrictions
## 05: Ebola Treatment Centres, Isolation Wards Hospitals and Transit Centres
## 06: Sub-national Indicators Ebola Countries
## 07: Food Prices Datasets for the Ebola-affected countries
## 08: Liberia Population - by county
## 09: Liberia Populated places 2011
## 11: Liberia Educational Facilties UNDP LIBGov 2007
## 12: Liberia policestations
## 13: Liberia Health Facilities UNDP LIBGov 2007
## 14: All Health Facilities (2010)
## 15: Market Centers
## 16: Liberia_Religious_Institutions
## 17: Rice Production (2006-07)

## sdrLocationsAfrica %>% extract("country_code") %>% table

## Subset by countries and ADM2
sdrLocationsAfrica <- dataList[[1]] %>%
    subset(., country_code %in% c("GN","LR","SL") &
               level %in% c("ADM2") &
               gn_latitude > 0 # drop ones in the sea
           )

min(sdrLocationsAfrica$gn_latitude)
min(sdrLocationsAfrica$gn_longitude)
max(sdrLocationsAfrica$gn_latitude)


## Plot all
p <- qmplot(x = gn_longitude, y = gn_latitude, data = sdrLocationsAfrica,
            zoom = 6,
            source = "google")
p

timeSeriesCases    <- dataList[[2]]






################################################################################
## Record package versions
print(sessionInfo())
## Stop sinking to a file if active
if (sink.number() != 0) {sink()}
