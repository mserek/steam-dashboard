library(shiny)
library(shinydashboard)
library(treemap)
library(DT)
library(dplyr)
library(tidyr)
library(shinyjs)
library(plotly)
library(scales)



data <- read.csv("data/steam_data.csv", sep = ",", encoding = "UTF-8")

labels <- list(
  "Number of positive reviews" = "positive_ratings",
  "Number of negative reviews" = "negative_ratings",
  "Average playtime" = "average_playtime",
  "Price" = "price",
  "Number of total reviews" = "total_ratings"
)

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
      total <- selectedData()[rows, ] %>%
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
      positive <- selectedData()[rows, ] %>%
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
      negative <- selectedData()[rows, ] %>%
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
      positive <- selectedData()[rows, ] %>%
        select(positive_ratings) %>%
        sum(.)
      total <- selectedData()[rows, ] %>%
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
      total <- selectedData()[rows, ] %>%
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
      total <- selectedData()[rows, ] %>%
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
      variable = input$visualizedVariableSelection
      title = paste("Publishers' games ", variable)
      
      games <- selectedData()[rows,] %>%
        group_by(publisher) %>%
        select(c(publisher, name, total_ratings, price, average_playtime))
      
      publishers <-  selectedData()[rows,] %>%
        group_by(publisher) %>%
        summarise(
          total_ratings = sum(total_ratings),
          price = sum(price),
          average_playtime = sum(average_playtime)
        ) %>%
        mutate(parent = title)
      
      
      
      if (variable == "total reviews") {
        values = c(games$total_ratings, publishers$total_ratings)
        texttemplate = "%{label}<br>%{value} reviews"
        
      } else if (variable == "prices") {
        values = c(games$price, publishers$price)
        texttemplate = "%{label}<br>%{value} $"
        
      } else if (variable == "average playtimes") {
        values = c(games$average_playtime, publishers$average_playtime)
        texttemplate = "%{label}<br>%{value} minutes"
      }
      
      fig <- plot_ly(
        type = "treemap",
        labels = c(games$name, publishers$publisher),
        parents = c(games$publisher, publishers$parent),
        branchvalues = "total",
        values = values,
        texttemplate = texttemplate,
        outsidetextfont = list(size = 20, color = "darkblue"),
        marker = list(line = list(width = 2)),
        pathbar = list(visible = FALSE),
        domain = list(column = 1)
      )
    } else {
      p <- plotly_empty(mode = "markers", type="scatter") %>%
        config(displayModeBar = FALSE) %>%
        layout(
          title = list(
            text = "Mark some rows in the table above to visualize!",
            yref = "paper",
            y = 0.5
          )
        )
    }
  })
  
  output$interactivePlot <- renderPlotly({
    p <- ggplot(selectedData(),
                aes(
                  x = get(labels[[input$xAxis]]),
                  y = get(labels[[input$yAxis]]),
                  text = paste(
                    "Developer: ",
                    developer,
                    "\nGame: ",
                    name,
                    "\nRelease date: ",
                    release_date,
                    "\nRating: ",
                    round(100 * positive_ratings / total_ratings),
                    "%",
                    "\nPrice: ",
                    price,
                    "$"
                  ),
                  colour = round(100 * positive_ratings / total_ratings)
                )) +
      labs(x = input$xAxis,
           y = input$yAxis) +
      geom_jitter(width = 1,
                  height = 1) +
      scale_colour_gradient(
        name = "Rating in %:",
        low = "red",
        high = "green",
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      
      scale_x_continuous(labels = comma_format(big.mark = ".",
                                               decimal.mark = ",")) +
      scale_y_continuous(labels = comma_format(big.mark = ".",
                                               decimal.mark = ",")) +
      labs(x = input$xAxis,
           y = input$yAxis,
           colour = "Rating in %") +
      theme_bw()
    ggplotly(p, tooltip = "text")
  })
  
})