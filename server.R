library(shiny)
library(shinydashboard)
library(treemap)
library(DT)
library(dplyr)
library(tidyr)



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
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      positive <- selectedData()[rows,] %>%
        select(positive_ratings) %>%
        sum(.)
      total <- selectedData()[rows,] %>%
        select(total_ratings) %>%
        sum(.)
      percent = round(100 * positive / total)
    }
    
    #implement 0-40% red, 40-70 yellow, 70-100 blue/green
    chosen_color = "black"
    shinydashboard::infoBox(
      "Rating: ",
      paste(percent, "%"),
      icon = icon("chart-line", lib = "font-awesome"),
      color = chosen_color
    )
  })
  
  output$mainDataTable <- renderDataTable({
    datatable(selectedData())
  })
  
  output$developerGamesPlot <- renderPlot({
    rows <- input$mainDataTable_rows_selected
    if (!is.null(rows)) {
      publishers <- selectedData()[rows, ] %>%
        group_by(publisher) %>%
        select(c(publisher, name, total_ratings))
      
      p <- treemap(
        publishers,
        index = c("publisher", "name"),
        vSize = "total_ratings",
        type = "index",
        fontsize.labels = c(16, 8),
        fontface.labels = c(2, 3),
        fontcolor.labels = c("white", "black"),
        bg.labels = c("transparent"),
        align.labels = list(c("center", "center"),
                            c("right", "bottom")),
        palette = "Set2",
        border.col = c("white", "black"),
        border.lwds = c(4, 2),
        title = "Number of reviews for publisher's games",
        fontsize.title = 32
      )
    }
  })
  
})