#UI script
library(shiny)

shinyUI(fluidPage(
  titlePanel("Top artists for user in time period"),
  sidebarLayout(
    sidebarPanel(
      numericInput("nTopArtists", "Observations:", 20,
                   min = 1, max = 100),
      dateInput("fromDate",
                label = "Date (from yyyy-mm-dd to present)",
                value = "2016-01-01")
    ),
  mainPanel(
    plotOutput("topUserArtists")
  ))
))
