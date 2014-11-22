### Load libraries
library(shiny)
library(magrittr)
library(ggplot2)


### Load time series dataset
## Load the data file available at:
## http://www.qdatum.io/public-sources
ebolaTimeSeries <- read.delim("./data/2.csv", header = TRUE)
## Fix
## ebolaTimeSeries$date <- ebolaTimeSeries$date + as.Date("1899-12-31")

## Used to create a smaller dataset from 1.csv
if (FALSE) {
    africaGeocodes <- read.delim("./data/1.csv", header = TRUE)
    africaGeocodes <- africaGeocodes[africaGeocodes$name %in% ebolaTimeSeries$sdr_name, ]
    ## Really tab deliminated
    write.table(x = africaGeocodes, file = "./data/1.short.csv", sep = "\t")
}
## Load the geocode dataset
geocodeDat <- read.delim("./data/1.short.csv", header = TRUE)


### shinyUI
shinyUI(pageWithSidebar(

    headerPanel("Hack Ebola: Counts Over Time"),

    sidebarPanel(

        ## Get the date to plot the cumulative occurrence for
        ## Use this to truncate the data fed to ggmap
        sliderInput('maxdate', 'Date to show cumulative occurrence for: ',
                    min = min(ebolaTimeSeries$date),
                    max = max(ebolaTimeSeries$date),
                    value = max(ebolaTimeSeries$date),
                    step = 1, round = 0),

    ),

    mainPanel(
        plotOutput('plot')
    )
))
