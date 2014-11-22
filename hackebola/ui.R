### Load libraries
library(shiny)
library(ggplot2)


### Load time series dataset
## Load the data file available at:
## http://www.qdatum.io/public-sources
ebolaTimeSeries <- read.delim("./data/2.csv", header = TRUE)


### shinyUI
shinyUI(pageWithSidebar(

    headerPanel("Hack Ebola: Occurrence Over Time"),

    sidebarPanel(
        ## Get the date to plot the cumulative occurrence for
        ## Use this to truncate the data fed to ggmap
        sliderInput('maxdate',
                    'Date to show cumulative occurrence for (days since 1900) ',
                    min   = min(ebolaTimeSeries$date),
                    max   = max(ebolaTimeSeries$date),
                    value = max(ebolaTimeSeries$date),
                    step  = 1, round = 0),
        
        ## Date hack
        ## https://github.com/rstudio/shiny/issues/66
        dateInput('maxdateDate',
                  'Date to show cumulative occurrence for',
                  value = max(ebolaTimeSeries$date) + as.Date("1899-12-31"))

    ),

    mainPanel(
        plotOutput('plot')
    )
))
