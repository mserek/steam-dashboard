library(shiny)
library(shinydashboard)
library(treemap)
library(DT)
library(dplyr)
library(tidyr)
library(shinyjs)
library(plotly)



data <- read.csv("data/steam_data.csv", sep = ",")


shinyServer(function(input, output) {
  selectedData <- reactive({
    data %>%
      filter(release_date >= input$dateInput[1]) %>%
      filter(release_date <= input$dateInput[2]) %>%
      filter(total_ratings >= input$minReviews) %>%
      filter(average_playtime >= input$minAvgPlaytime) %>%
      filter(price >= input$priceRange[1]) %>%
      filter(price <= input$priceRange[2])
  })
  
  output$totalReviewsBox <- renderInfoBox({
    total <- 0
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      total <- selectedData()[rows,] %>%
        select(total_ratings) %>%
        sum(.)
    }
    shinydashboard::infoBox(
      "Total reviews:",
      paste(total),
      icon = icon("pen", lib = "font-awesome"),
      color = "black"
    )
  })
  
  output$positiveReviewsBox <- renderInfoBox({
    positive <- 0
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      positive <- selectedData()[rows,] %>%
        select(positive_ratings) %>%
        sum(.)
    }
    shinydashboard::infoBox(
      "Positive reviews:",
      paste(positive),
      icon = icon("thumbs-up", lib = "font-awesome"),
      color = "green"
    )
  })
  
  output$negativeReviewsBox <- renderInfoBox({
    negative <- 0
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      negative <- selectedData()[rows,] %>%
        select(negative_ratings) %>%
        sum(.)
    }
    shinydashboard::infoBox(
      "Negative reviews:",
      paste(negative),
      icon = icon("thumbs-down", lib = "font-awesome"),
      color = "red"
    )
  })
  
  output$percentReviewsBox <- renderInfoBox({
    percent <- 0
    chosen_color <- "black"
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      positive <- selectedData()[rows,] %>%
        select(positive_ratings) %>%
        sum(.)
      total <- selectedData()[rows,] %>%
        select(total_ratings) %>%
        sum(.)
      percent <- round(100 * positive / total)
      chosen_color = ifelse(percent < 40, "red", ifelse(percent < 70, "yellow", "green"))
    }
      shinydashboard::infoBox(
      "Rating: ",
      paste(percent, "%"),
      icon = icon("chart-line", lib = "font-awesome"),
      color = chosen_color
    )
  })
  
  output$totalPriceBox <- renderInfoBox({
    total <- 0
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      total <- selectedData()[rows,] %>%
        select(price) %>%
        sum(.)
    }
    shinydashboard::infoBox(
      "Total price:",
      paste(total),
      icon = icon("dollar-sign", lib = "font-awesome"),
      color = "olive"
    )
  })
  
  output$totalTimeBox <- renderInfoBox({
    total <- 0
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      total <- selectedData()[rows,] %>%
        select(average_playtime) %>%
        sum(.)
    }
    shinydashboard::infoBox(
      "Total average time played:",
      paste(total),
      icon = icon("clock", lib = "font-awesome"),
      color = "navy"
    )
  })
  
  output$mainDataTable <- renderDataTable({
    datatable(selectedData())
  })
  
  observeEvent(input$restartButton, {
    reset("dateInput")
    reset("minReviews")
    reset("minAvgPlaytime")
    reset("priceRange")
  })
  
  output$developerGamesPlot <- renderPlotly({
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      games <- selectedData()[rows, ]%>%
        group_by(publisher) %>%
        select(c(publisher, name, total_ratings))
  

      publishers <-  selectedData()[rows, ] %>%
        group_by(publisher) %>% 
        summarise(total_ratings = sum(total_ratings)) %>%
        mutate(parent = "")

      fig <- plot_ly(
        type="treemap",
        labels=c(games$name, publishers$publisher),
        parents=c(games$publisher, publishers$parent),
        values = c(games$total_ratings, publishers$total_ratings),
        branchvalues="total",
        textinfo="label+value",
        outsidetextfont=list(size=20, color= "darkblue"),
        marker=list(line= list(width=2)),
        pathbar=list(visible= FALSE),
        domain=list(column=1))
    }
    
  })
  
})