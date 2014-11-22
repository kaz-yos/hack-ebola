### Load packages
library(shiny)
library(ggplot2)
library(ggmap)
library(lubridate)
library(magrittr)
library(gridExtra)


### Load time series dataset
## Load the data file available at:
## http://www.qdatum.io/public-sources
ebolaTimeSeries <- read.delim("./data/2.csv", header = TRUE)
## Keep only ADM2
ebolaTimeSeries <- ebolaTimeSeries[ebolaTimeSeries$sdr_level == "ADM2",]


### Load geocode dataset
geocodeDat <- read.delim("./data/1.csv", header = TRUE) %>%
    subset(., country_code %in% c("GN","LR","SL") &
               level %in% c("ADM2") &
               ## drop ones in the sea
               gn_latitude > 0)


### Load Ebola Treatment Centres, Isolation Wards Hospitals and Transit Centres
etcDat <- read.delim("./data/5.csv", header = TRUE) %>%
    subset(., country %in% c("Liberia","Guinea","Sierra Leone"))

CleanEtcDates <- function(v) {
    v[v %in% "N/A"] <- NA
    v[v %in% "-"]   <- NA
    v[v %in% "?"]   <- NA
    v
}
etcDat$centre_opening_date <- CleanEtcDates(etcDat$centre_opening_date) %>%
    dmy %>% as.Date
etcDat$centre_closing_date <- CleanEtcDates(etcDat$centre_closing_date) %>%
    dmy %>% as.Date

## Give very early date for centers without oepning date
etcDat$centre_opening_date[is.na(etcDat$centre_opening_date)] <- as.Date("2014-03-01")
## Give very late date for centers without closing date
etcDat$centre_closing_date[is.na(etcDat$centre_closing_date)] <- as.Date("2014-12-31")


### Server configuration
## shinyServer then gives Shiny the unnamed function in its first argument.
shinyServer(function(input, output, session) {

    ## Update date input based on the slider value
    observe({
        updateDateInput(session, 'maxdateDate',
                        value = input$maxdate + as.Date("1899-12-31"))
    })

    ## Create a reactive dataset
    ## reactive() is just creating a thunk (delayed execution)
     datasetThunk <- reactive({
        ## Subset dataset based on the max date
        ebolaTimeSeries[ebolaTimeSeries$date <= input$maxdate,]
    })

    ## Plot thunk creation (named plot1)
    output$plots <- renderPlot({

        ## Get the max date in as.Date format
        maxdate_as.Date <- input$maxdate + as.Date("1899-12-31")

        ## Subset ETC dataset to the corresponding period
        ## ETC is not cumulative
        etcDatIncluded <- subset(etcDat, centre_opening_date <= maxdate_as.Date &
                             centre_closing_date > maxdate_as.Date)

        ## Subset geocode data for sdr_name existing in datasetThunk
        geocodeDatInclded <- geocodeDat[geocodeDat$name %in% datasetThunk()$sdr_name, ]

        ## Cases
        p1 <- qmplot(x = gn_longitude, y = gn_latitude, data = geocodeDatInclded,
                     xlim = range(geocodeDat$gn_longitude),
                     ylim = range(geocodeDat$gn_latitude),
                     source = "google")

        ## ETCs
        p2 <- qmplot(x = longitude, y = latitude, data = etcDatIncluded,
                     xlim = range(etcDat$longitude),
                     ylim = range(etcDat$latitude),
                     source = "google")


        ## Need to print conditionally to actually show

        if (input$whichMap == "cases") {
            
            print(p1)
            
        } else if (input$whichMap == "ETC") {

            print(p2)
            
        } else {


            grid.arrange(p1, p2, ncol = 1)
            ## print(p1)
            ## print(p2)
            
        }

    }, height = 800)

})
