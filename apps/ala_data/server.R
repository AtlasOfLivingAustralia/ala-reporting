library(ggplot2)
library(shiny)
library(paws)
library(jsonlite)
library(tibble)
source("get_data.R")


server <- function(input, output, session) {
  load("data/dashboard_objs.RData")
  record_counts <- get_counts(dashboard_objs)
  bor_counts <- get_bor_counts(dashboard_objs)
  load('data/data_resource_counts.RData')
  updateSelectizeInput(inputId = "druid", choices = unique(dr_csv$name))
  load('data/image_data.RData')
  output$dashboard_plot <- renderPlot({
    switch(input$statistic,
           "total" = ggplot(record_counts) +
             geom_line(aes(x = date, y = total)),
           "bor" = ggplot(bor_counts) +
             geom_area(
               mapping = aes(x = date, y = count, fill = basis_of_record),
               stat = "identity"),
           "image" = ggplot(image_data) +
             geom_line(aes(x = date, y = image_count)))
  })
  
  output$data_resource_plot <- renderPlot({
    data <- dr_csv %>% filter(name == input$druid)
    ggplot(data) + geom_line(aes(x = date, y = count))
  })
}





