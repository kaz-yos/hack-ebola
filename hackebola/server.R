### Load packages
library(shiny)
library(ggplot2)
library(ggmap)
library(gridExtra)


###
### Data processing
if (FALSE) {
### Load packages for data processing only
    library(lubridate)
    library(magrittr)
    library(dplyr)

### Load time series dataset
    ## Load the data file available at:
    ## http://www.qdatum.io/public-sources
    ## Use ADM2 except for Liberia (LR) for which only ADM1 are available
    ebolaTimeSeries <- read.delim("./data/2.csv", header = TRUE) %>%
        subset(., sdr_level == "ADM2" | (country_code == "LR" & sdr_level == "ADM1"))

### Load geocode dataset
    geocodeDat <- read.delim("./data/1.csv", header = TRUE) %>%
        subset(., ((country_code %in% c("GN","LR","SL") & level %in% c("ADM2")) |
                       (country_code %in% c("LR") & level %in% c("ADM1"))
                   ) &
                       ## drop ones in the sea
                       gn_latitude > 0) %>%
                       ## rename
                       rename(.,
                              latitude = gn_latitude,
                              longitude = gn_longitude)

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

### Save dataset
    save.image(file = "./data/data.RData")
}

###
### Load all data
load(file = "./data/data.RData")

###
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


        ## Merge two dataset with only geocoordinates
        ## Drop unnecessary columns
        geocodeDatInclded <- geocodeDatInclded[c("latitude","longitude")]
        geocodeDatInclded$type <- "Cases"
        etcDatIncluded    <- etcDatIncluded[c("latitude","longitude")]
        etcDatIncluded$type <- "ETCs"
        ## Merge
        mergedData <- rbind(etcDatIncluded, geocodeDatInclded)

        ## Cases
        p <- qmplot(x = longitude, y = latitude, data = mergedData,
                    xlim = range(geocodeDat$longitude),
                    ylim = range(geocodeDat$latitude),
                    source = "google") +
             layer(geom = "point",
                   mapping = aes(color = type),
                   size = 10, alpha = 0.5) +
             scale_color_manual(values = c("Cases" = "red", "ETCs" = "green"))

        ## Need to print conditionally to actually show
        if (input$whichMap == "cases") {

            print(p %+% subset(mergedData, type == "Cases"))

        } else if (input$whichMap == "ETC") {

            print(p %+% subset(mergedData, type == "ETCs"))

        } else {

            print(p)

        }

    }, height = 800)

})
