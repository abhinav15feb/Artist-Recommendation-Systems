#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

if(!exists("BaseData")){
  load("Project.RData",envir=.GlobalEnv)
}
# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("spacelab"),
                  # Application title
                  titlePanel("Artist Recommendation"),
                  sidebarLayout(
                    sidebarPanel(
                      selectInput("Artist1",
                                  "First Artist",
                                  choices = c("Select from List", as.character(BaseData$Id)),selected = NULL),
                      selectInput("Artist2",
                                  "Second Artist",
                                  choices = c("Select from List", as.character(BaseData$Id)),selected = NULL),
                      selectInput("Artist3",
                                  "Third Artist",
                                  choices = c("Select from List", as.character(BaseData$Id)),selected = NULL)
                    ),
                    
                    # Show a plot of the generated distribution
                    mainPanel(
                      tabsetPanel(
                        tabPanel("Insight", plotOutput("distPlot"),plotOutput("distDistribution"),plotOutput("RecentData"),plotOutput("Top10Artist")),
                        tabPanel("Network Summary", verbatimTextOutput("summary")),
                        tabPanel("Recommendation- Based on Content (Cosine)", htmlOutput("userOutput1")),
                        tabPanel("Recommendation- Network Metrics (Random Forest)", htmlOutput("userOutput2"), imageOutput("ginger"))
                      )
                    )
                  )
  )
)
