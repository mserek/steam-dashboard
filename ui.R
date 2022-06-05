library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)
library(plotly)
library(markdown)


dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
    ),
    
    useShinyjs(),
    
    fluidRow(
      column(
        width = 6,
        includeMarkdown("www/header.md"),
        class = "header"
      ),
      column(width = 6, a(img(
        src = "logo.png", id = "logo"
      ), href = "https://www.put.poznan.pl/"))
    ),
    fluidRow(
      shinydashboard::infoBoxOutput("percentReviewsBox"),
      shinydashboard::infoBoxOutput("positiveReviewsBox"),
      shinydashboard::infoBoxOutput("totalPriceBox")
    ),
    fluidRow(
      shinydashboard::infoBoxOutput("totalReviewsBox"),
      shinydashboard::infoBoxOutput("negativeReviewsBox"),
      shinydashboard::infoBoxOutput("totalTimeBox")
    ),
    flowLayout(
      column(
        12,
        dateRangeInput(
          "dateInput",
          label = "Period:",
          start = "1997-06-30",
          end = "2019-05-01",
          min = "1997-06-30",
          max = "2019-05-01"
        )
      ),
      column(
        12,
        numericInput(
          "minReviews",
          label = "Minimal number of reviews:",
          value = 0,
          min = 0
        )
      ),
      column(
        12,
        numericInput(
          "minAvgPlaytime",
          label = "Minimal average playtime:",
          value = 0,
          min = 0
        )
      ),
      column(
        12,
        sliderInput(
          "priceRange",
          label = "Price range in $:",
          value = c(0, 80),
          min = 0,
          max = 80
        )
      ),
      column(
        12,
        div(style = "height:24px;"),
        actionButton("restartButton",
                     label = "Set all filters to default"),
      )
    ),
    fluidRow(dataTableOutput("mainDataTable")),
  
    tabsetPanel(
      tabPanel(
        "Publishers' games ",
        fluidRow(column(
          12,
          align = "center",
          radioButtons(
            "visualizedVariableSelection",
            "Choose visualized variable:",
            c("total reviews", "prices", "average playtimes"),
            inline = TRUE
          )
        )),
        fluidRow(plotlyOutput("developerGamesPlot"))
      ),
      tabPanel(
        "Idk how to name this",
        
        flowLayout(
          selectInput(
            "xAxis",
            label = "X-axis",
            choices = c(
              "Number of positive reviews",
              "Number of negative reviews",
              "Average playtime",
              "Price",
              "Number of total reviews"
            )
          ),
          selectInput(
            "yAxis",
            label = "Y-axis",
            choices = c(
              "Number of positive reviews",
              "Number of negative reviews",
              "Average playtime",
              "Price",
              "Number of total reviews"
            )
          )
        ),
        fluidRow(plotlyOutput("interactivePlot"))
      ),
    ),
  )
)