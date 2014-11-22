### Load packages
library(shiny)
library(ggplot2)


### Load time series dataset
## Load the data file available at:
## http://www.qdatum.io/public-sources
ebolaTimeSeries <- read.delim("./data/2.csv", header = TRUE)


### shinyUI
shinyUI(pageWithSidebar(

    ## Title
    headerPanel("Hack Ebola: Occurrence Over Time (very crude, please do confirm with other sources)"),


    ## Side bar for controls
    sidebarPanel(
        ## Get the date to plot the cumulative occurrence for
        ## Use this to truncate the data fed to ggmap
        sliderInput('maxdate',
                    'Date to show cumulative occurrence for (days since 1900) ',
                    min   = min(ebolaTimeSeries$date) + 1,
                    max   = max(ebolaTimeSeries$date),
                    value = max(ebolaTimeSeries$date),
                    step  = 1, round = 0),

        ## Date hack
        ## https://github.com/rstudio/shiny/issues/66
        dateInput('maxdateDate',
                  'Date to show cumulative occurrence for',
                  value = max(ebolaTimeSeries$date) + as.Date("1899-12-31")),

        ## Radio buttons to select which ones to plot
        radioButtons('whichMap',
                     'Which Map(s)?',
                     choices = list("cases","ETC","both"),
                     selected = "cases"),
        
        ## Hair line
        tags$hr(),
        
        "Created by ",
        tags$a("@kaz_yos",
               href="https://twitter.com/kaz_yos"),
        " at ",
        tags$a("Hack Ebola with Data",
               href="http://hackebolawithdata.challengepost.com"),
        tags$br(),
        "Source code available at ",
        tags$a("Github",
               href="https://github.com/kaz-yos/hack-ebola/tree/master/hackebola"),
        tags$br(),
        tags$br(),
        "The administrative level of data is ADM2 for Guinea and Sierra Leone, and ADM1 for Liberia. Presence of cases (red points) reflects reports of any of cases, suspected cases, or death by that date. Ebola Treatment Centers (ETC) are plotted in green. The ones open at the time of selection are plotted. Those without opening or closing dates are always plotted."
        

    ),


    ## What to put in the main panel
    mainPanel(

        ## Plot the reuslts (may have two plots)
        plotOutput('plots')

    )
))
