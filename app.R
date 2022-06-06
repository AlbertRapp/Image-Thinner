#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(magick)
library(scattermore)

options(shiny.maxRequestSize = 10 * 1024^2)

# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bslib::bs_theme(
      bg = 'white', 
      fg = '#06436e', 
      primary = colorspace::lighten('#06436e', 0.3),
      base_font = 'Source Sans Pro',
      heading_font = 'Oleo Script'
    ),
    # Application title
    tabsetPanel(
      tabPanel(
        "Pixels", 
        titlePanel("Thin Out Your Image"),
        # Sidebar with a slider input for number of bins 
        sidebarLayout(
          sidebarPanel(
            fileInput('img_file', 'Upload Image (Max. 10 MB)' , accept = c('.png', '.jpg', '.jpeg')),
            sliderInput("pixel_skip",
                        "Pixel skip?:",
                        min = 0,
                        max = 1000,
                        value = 1000),
            sliderInput("point_size",
                        "Point size:",
                        min = 0,
                        max = 5,
                        value = 2,
                        step = 0.25),
            shiny::checkboxInput(
              'flip_x', 
              'Flip x-axis?'
            ),
            shiny::checkboxInput(
              'flip_y', 
              'Flip y-axis?'
            ),
            actionButton(
              'pixel_button',
              'Thin out!'
            )
          ),
          
          # Show a plot of the generated distribution
          mainPanel(
            plotOutput("plot")
          )
        )
      ),
      tabPanel(
        "About", 
        div(includeMarkdown('about.md'))
      )
    ),
    

    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  raster_dat <- eventReactive(input$img_file, {
    image_read(input$img_file$datapath) %>% 
      image_raster() %>% 
      as_tibble() 
  })
  
  dat <- eventReactive(input$pixel_button, {
    tmp <- raster_dat() %>% 
      mutate(
        x = if (input$flip_x) max(x) - x else x,
        y = if (input$flip_y) max(y) - y else y
      ) %>% 
      arrange(x, y) %>% 
      as.data.frame()
    tmp[c(T, rep(F, isolate(input$pixel_skip))), ]
  })
  
  observeEvent(dat, {
    output$plot <- renderPlot({
      dat() %>%
        ggplot(aes(x, y, col = col)) +
        geom_scattermore(pointsize = isolate(input$point_size)) +
        scale_color_identity() +
        theme_void()
    })
  })
  
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
