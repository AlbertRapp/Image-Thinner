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
library(markdown) 
library(scattermore)
library(shinycssloaders)

# Allox up to 10 MB file uploads
options(shiny.maxRequestSize = 10 * 1024^2)

# Define UI
ui <- fluidPage(
    # Basic theming
    theme = bslib::bs_theme(
      bg = 'white', # background color
      fg = '#06436e', # foreground
      primary = colorspace::lighten('#06436e', 0.3), # primary color
      # Fonts (Use multiple in case a font cannot be displayed)
      base_font = c(
        'Source Sans Pro',  'Lato', 'Merriweather', 'Roboto Regular', 
        'Cabin Regular'
      ),
      heading_font = c(
        'Oleo Script', 'Prata', 'Roboto', 'Playfair Display', 'Montserrat'
      ),
      font_scale = 1.25
    ),
    # Enable feedback like warnings etc. for inputs
    shinyFeedback::useShinyFeedback(),
    # Create panels: One for app, one for about page
    tabsetPanel(
      # App panel
      tabPanel(
        "App", 
        titlePanel("Thin Out Your Image"),
        
        # Include explainer text via .md-file
        div(includeMarkdown('explainer.md')),
        
        # Sidebar
        sidebarLayout(
          sidebarPanel(
            fileInput(
              'img_file', 
              'Upload Image (Max. 10 MB)' , 
              accept = c('.png', '.jpg', '.jpeg')
            ),
            numericInput("pixel_skip",
                        "Pixel skip x",
                        min = 50,
                        max = 1000,
                        step = 1,
                        value = 100),
            sliderInput("point_size",
                        "Point size",
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
              'Flip y-axis?',
              value = T
            ),
            actionButton(
              'pixel_button',
              'Thin out!'
            )
          ),
          
          # Plot output with spinner during calculation
          # Spinner uses {shinycssloaders}
          mainPanel(
            withSpinner(plotOutput("plot"))
          )
        )
      ),
      
      # About panel
      tabPanel(
        "About",
        fluidRow(
          # White space left and right avoids wall of text.
          column(2),
          column(8, div(includeMarkdown('about.md'))),
          column(2)
        )
        
      )
    ),
    

    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Create raster from image
  raster_dat <- eventReactive(input$img_file, {
    image_read(input$img_file$datapath) %>% 
      image_raster() %>% 
      as_tibble() 
  })
  
  # Compute pixels if button is pressed
  dat <- eventReactive(input$pixel_button, {
    # Make sure input is in correct range
    req(between(input$pixel_skip, 50, 1000))
    
    # Flip raster if necessary and convert to data.frame for recycling of vector
    tmp <- raster_dat() %>% 
      mutate(
        x = if (input$flip_x) max(x) - x else x,
        y = if (input$flip_y) max(y) - y else y
      ) %>% 
      arrange(x, y) %>% 
      as.data.frame()
    
    # Recycle TRUE/FALSE vector to skip pixels
    tmp[c(T, rep(F, input$pixel_skip)), ]
  })
  
  # After pixels are computed, render plot
  # Isolate point_size to avoid reactivity before button is pressed
  observeEvent(dat, {
    output$plot <- renderPlot({
      dat() %>%
        ggplot(aes(x, y, col = col)) +
        geom_scattermore(pointsize = isolate(input$point_size)) +
        scale_color_identity() +
        theme_void()
    })
  })
  
  # Return user feedback when incorrect values for pixel skip is used
  observeEvent(input$pixel_skip, {
    shinyFeedback::hideFeedback('pixel_skip')
    shinyFeedback::feedbackDanger(
      'pixel_skip',
      show = !between(input$pixel_skip, 50, 1000),
      text = 'Enter an integer between 50 and 1000.',
      icon = NULL
    )
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
