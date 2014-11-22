library(shiny)
library(ggplot2)
library(ggmap)

### Server configuration
shinyServer(function(input, output) {

    dataset <- reactive(function() {
        ebolaTimeSeries[ebolaTimeSeries$date <= input$maxdate,]
    })

    output$plot <- reactivePlot(function() {

        ## Extract geocode data for sdr_name existing in maindat
        geocodeDatInclded <- geocodeDat[geocodeDat$name %in% dataset$sdr_name, ]
        
        ## ggmap
        p <- qmplot(x = gn_longitude, y = gn_latitude, data = geocodeDatInclded,
                    source = "google")

        ## Need to print to actually show
        print(p)

    }, height=700)

})
