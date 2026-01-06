library(dplyr)
library(ggplot2)
library(shiny)
data <- read.csv("uk_demographics.csv")
colnames(data) = c("area_id","area","sex_id","sex","age_cat_id","age_cat","number")


ui <- fluidPage(
  titlePanel("Choinki z rozkładow ludności i płci angielskich miast"),
  sidebarLayout(
    sidebarPanel(
      selectInput("miasto",
                  "Wybierz miasto:",
                  sort(unique(data$area))),
    ),
    mainPanel(
      plotOutput(outputId = "choinka", width = "400px", height = "600px"),
    )
  )
)


server <- function(input, output) {
  
  output$choinka <- renderPlot({
    
    city_data <- data %>% filter(area == input$miasto)
    city_data <- city_data %>%  group_by(sex_id, age_cat_id) %>% summarise(total_number = sum(number)) %>% 
    mutate(total_number = total_number/max(total_number))
    
    
    distinct(data, area)
    
    
    bombki_func <-
      function(total_number, age_cat, sex){
        tibble(
          y = seq(0,total_number,0.02),
          x = rep(age_cat, length(y)),
          sex = rep(sex, length(y)),
          total_number = rep(total_number, length(y))
        )
      }
    
    bombki <- c()
    for (i in 1:nrow(city_data)){
      bombki <- rbind(bombki,bombki_func(city_data$total_number[i],city_data$age_cat_id[i],city_data$sex_id[i]))
    }
    
    bombki <- bombki %>% mutate(y = (2*sex - 3) * y) 

    bombki <- slice_sample(bombki, prop = 6/100)
    
    bombki <- 
      bombki %>% 
      mutate(color = sample(c("r", "y", "b", "p"), n(), replace = TRUE))
    
    
    pien <- tibble(
      x = rep(-6:-1, times = 2),
      y = rep(c(-0.1,0.1),each = 6)
    )
    
    pom <- seq(0,2*pi,pi/6)
    size <- 20
    star <- tibble(
      x = sin(pom)*c(size/sqrt(3),size)*100/600 + 100,
      y = cos(pom)*c(size/sqrt(3),size)*2/400
    )
    
    city_data <- city_data %>% mutate(total_number = (2*sex_id - 3) * total_number)
    
    city_data %>% 
      ggplot() +
      geom_col(aes(x=age_cat_id, y=total_number), color="#10421a", fill = "#060") +
      geom_point(data = bombki, aes(x=x, y = y, color=color), shape="*", size=7) +
      geom_col(data = pien, aes(x=x, y=y), color="#631", fill = "#631") +
      geom_polygon(data = star, aes(x=x,y=y),fill = "#F1D900")+
    
      scale_color_manual(values = c("#FDF5E6", "#ffe", "#efe", "#ffd")) +
      theme_light() +
      coord_flip() +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "none"
      )
  

  })
}

shinyApp(ui = ui, server = server)


