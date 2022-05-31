library(shiny)
library(shinydashboard)
library(DT)




dashboardPage(
  dashboardHeader(title = "Steam Games"),
  dashboardSidebar(),
  dashboardBody(
    fluidRow(
      shinydashboard::infoBoxOutput("totalReviewsBox"),
      shinydashboard::infoBoxOutput("percentReviewsBox")
    ),
    fluidRow(
      shinydashboard::infoBoxOutput("positiveReviewsBox"),
      shinydashboard::infoBoxOutput("negativeReviewsBox")
    ),
    flowLayout(
      dateRangeInput(
        "dateInput",
        label = "Period:",
        start = "1997-06-30",
        end = "2019-05-01",
        min = "1997-06-30",
        max = "2019-05-01"
      ),
      numericInput(
        "minReviews",
        label = "Minimal number of reviews:",
        value = 0,
        min = 0
      ),
      numericInput(
        "minAvgPlaytime",
        label = "Minimal average playtime:",
        value = 0,
        min = 0
      ),
      sliderInput(
        "priceRange",
        label = "Price range in $:",
        value = c(0, 80),
        min = 0,
        max = 80
      )
    ),
    fluidRow(dataTableOutput("mainDataTable")),
    fluidRow(plotOutput("developerGamesPlot")),
  )
)