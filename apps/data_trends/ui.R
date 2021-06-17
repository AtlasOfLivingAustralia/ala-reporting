library(shiny)

ui <- fluidPage(
  titlePanel("Long term ALA data trends"),
  tabsetPanel(
    type = "tabs",
    id = "tabPanel",
    tabPanel(
      title = "Summary statistics", 
      value = "summary",
      br(),
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "statistic",
            label = "Data to display",
            choices = c("Total counts" = "total", "Basis of record counts" = "bor",
                        "Image counts" = "image"))
        ),
        mainPanel(
          plotOutput("dashboard_plot")
        )
      )
    ),
    tabPanel(
      title = "Data resource counts",
      value = "drs",
      br(),
      sidebarLayout(
        sidebarPanel(
          selectizeInput(
            "druid",
            label = "Data resource",
            choices = c()
          )
        ),
        mainPanel(
          plotOutput("data_resource_plot")
        )
      )
    )
  )
  # mainPanel(
  #   tabsetPanel(type = "tabs",
  #               id = "tabPanel",
  #               tabPanel("Summary statistics", ,
  #               tabPanel("Data resources", plotOutput("dr_plot")),
  #               tabPanel("API usage", plotOutput("api_data_plot"))
  #   )
  # )
)