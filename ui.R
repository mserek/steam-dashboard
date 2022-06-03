library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)




dashboardPage(
  dashboardHeader(title = "Steam Games"),
  dashboardSidebar(),
  dashboardBody(
    useShinyjs(),
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
      column(12,
        dateRangeInput(
          "dateInput",
          label = "Period:",
          start = "1997-06-30",
          end = "2019-05-01",
          min = "1997-06-30",
          max = "2019-05-01"
        )
      ),
      column(12,
        numericInput(
          "minReviews",
          label = "Minimal number of reviews:",
          value = 0,
          min = 0
        )
      ),
      column(12,
        numericInput(
          "minAvgPlaytime",
          label = "Minimal average playtime:",
          value = 0,
          min = 0
        )
      ),
      column(12,
        sliderInput(
          "priceRange",
          label = "Price range in $:",
          value = c(0, 80),
          min = 0,
          max = 80
        )
      ),
      column(12,
        div(style = "height:24px;"),
        actionButton(
          "restartButton",
          label = "Set all filters to default"
        )
      )
    ),
    fluidRow(dataTableOutput("mainDataTable")),
    fluidRow(plotlyOutput("developerGamesPlot")),
  )
)