
## This is the server logic for a Shiny web application.
## You can find out more about building applications with Shiny here:
##
## http://shiny.rstudio.com
##

library(shiny)

## Description:
##      Defines the server-side logic of the Shiny application. This
##      generally involves creating functions that map user inputs to
##      various kinds of output.
## Usage:
##      shinyServer(func)

shinyServer(function(input, output) {
    
    output$distPlot <- renderPlot({
        
        ## generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        
        ## draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'skyblue', border = 'white',
             ylim = c(0, input$ylim_upper))
        
    })
    
})
