### Load libraries
library(shiny)
library(magrittr)
library(ggplot2)


### Load time series dataset
## Load the data file available at:
## http://www.qdatum.io/public-sources
dataset <- read.delim("./data/2.csv", header = TRUE)
## Fix 
dataset$date <- dataset$date + as.Date("1899-12-31")


### shinyUI
shinyUI(pageWithSidebar(

    headerPanel("Hack Ebola: Counts Over Time"),

    sidebarPanel(

        ## Get the date to plot the cumulative for
        sliderInput('date', 'Date',
                    min = min(dataset$date),
                    max = max(dataset$date),
                    value = max(dataset$date),
                    step = 1, round = 0),

    ),

    mainPanel(
        plotOutput('plot')
    )
))
