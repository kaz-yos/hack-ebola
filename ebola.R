#!/usr/bin/Rscript

################################################################################
### Hack Ebola Hackathon
## 
## Created on: 2014-11-21
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

if (FALSE) {
    ## This is ordered wrong.
    ## csvFiles <- Filter(function(x) {grepl(".csv",x)}, dir("./data"))
    csvFiles <- paste0("./data/", 1:16, ".csv")

    dataList <- lapply(csvFiles, function(file) {
        read.delim(file = file, header = TRUE)    
    })

    save(dataList, file = "dataList.RData")
}

load(file = "dataList.RData")

### Check data
################################################################################

cat("### names\n")
lapply(dataList, names)

cat("### summary\n")
lapply(dataList, summary)
















################################################################################
## Record package versions
print(sessionInfo())
## Stop sinking to a file if active
if (sink.number() != 0) {sink()}
