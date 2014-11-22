library(shiny)
library(ggplot2)
library(ggmap)


### Load geocode dataset
## Used to create a smaller dataset from 1.csv
if (FALSE) {
    africaGeocodes <- read.delim("./data/1.csv", header = TRUE)
    africaGeocodes <- africaGeocodes[africaGeocodes$name %in% ebolaTimeSeries$sdr_name, ]
    ## Really tab deliminated
    write.table(x = africaGeocodes, file = "./data/1.short.csv", sep = "\t")
}
## Load the geocode dataset
geocodeDat <- read.delim("./data/1.short.csv", header = TRUE)




### Server configuration
## shinyServer then gives Shiny the unnamed function in its first argument.
shinyServer(function(input, output) {

    ## Create a reactive dataset 
    ## reactive() is just creating a thunk (delayed execution)
    datasetThunk <- reactive(function() {
        ebolaTimeSeries[ebolaTimeSeries$date <= input$maxdate,]
    })

    ## Plot thunk creation
    output$plot <- renderPlot(function() {

        ## Extract geocode data for sdr_name existing in maindat
        geocodeDatInclded <- geocodeDat[geocodeDat$name %in% datasetThunk()$sdr_name, ]

        ## ggmap
        p <- qmplot(x = gn_longitude, y = gn_latitude, data = geocodeDatInclded,
                    source = "google")

        ## Need to print to actually show
        print(p)

    }, height=700)

})
