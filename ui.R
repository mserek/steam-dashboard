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
    fluidRow(dataTableOutput("mainDataTable")),
    fluidRow(plotOutput("developerGamesPlot"))
  )
)