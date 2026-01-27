library(shiny)
library(dplyr)
library(plotly)
library(jsonlite)
library(lubridate)
library(tidyr)
library(tibble)
library(fontawesome)

# Pliki Karolina --------------------------------------------------------------
source("data_loader.R")
source("density_heatmap.R")
source("ui_layout.R")

# Pliki Nina ------------------------------------------------------------------
source("barplot_screentime.R")
source("barplot_sleep.R")
source("sleepy_text.R")

#pliki Ania -------------------------------------------------------------------
source("plot_Ania.R")
source("cleaning_data_ania.R")

server <- function(input, output) {
  # ---------------------------------------------------------------------------
  # Bar Plot dla screentime ---------------------------------------------------
  output$barplot_1 <- renderPlotly({
    req(input$person)
    
    screentime_barplot(input$person, input$date_1, input$limit_1, input$device_1)
  })
  
  # ---------------------------------------------------------------------------
  # HeatMap ------------------------------------------------------------------
  current_user_data <- reactive({
    req(input$person)
    get_user_data(input$person)
  })
  
  # wybór początka tygodnia
  output$week_selector <- renderUI({
    data_for_weeks <- current_user_data()
    req(nrow(data_for_weeks) > 0)
    
    tygodnie <- sort(unique(data_for_weeks$tydzien_start), decreasing = TRUE)
    selectInput("selected_week", "Wybierz tydzień (początek):", 
                choices = setNames(as.character(tygodnie), format(tygodnie, "%d.%m.%Y")))
  })
  

  # wybór danych
  filtered_data <- reactive({
    req(input$selected_week, current_user_data())
    df_filtered <- current_user_data() %>%
      filter(as.character(tydzien_start) == input$selected_week)
    
    if (input$device == "Laptop") {
      df_filtered <- df_filtered %>% filter(device == "komputer")
      
    } else if (input$device == "Telefon") {
      df_filtered <- df_filtered %>% filter(device == "telefon")
    }
    
    df_filtered
  })
  

  #gęstość i heatmapa
  output$density_heatmap <- renderPlotly({
    df_filtered <- filtered_data()
    req(nrow(df_filtered) > 0)
    
    combined_plot(df_filtered)
  })
  
  # Statystyki
  output$total_time <- renderUI({
    df_sum <- filtered_data() 
    req(nrow(df_sum) > 0)
    
    total_sek <- sum(df_sum$duration, na.rm = TRUE)
    godz <- floor(total_sek / 3600)
    min <- floor((total_sek %% 3600) / 60)
    
    HTML(paste0("<div style='margin-left: 20px; font-size: 22px;'>",
                "Łączny czas: <span style='color: #4ebce2; font-weight: bold;'>", 
                godz, " h ", min, " min</span></div>"))
  })
  
  output$mean_time <- renderUI({
    df_sum <- filtered_data()
    req(nrow(df_sum) > 0)
    
    total_sek <- sum(df_sum$duration, na.rm = TRUE) / 7
    godz <- floor(total_sek / 3600)
    min <- floor((total_sek %% 3600) / 60)
    
    HTML(paste0("<div style='margin-left: 20px; font-size: 22px;'>",
                "Średnio dziennie: <span style='color: #4ebce2; font-weight: bold;'>", 
                godz, " h ", min, " min</span></div>"))
  })
  
  # ---------------------------------------------------------------------------
  # Bar Plot dla snu ----------------------------------------------------------
  output$barplot_2 <- renderPlotly({
    req(input$person)
    
    sleep_barplot(input$person, input$date_4, input$recomm_4)
  })
  
  output$sleepy_descript <- renderUI({
    HTML(paste0("<div style='margin-left: 20px; font-size: 16px;'>",
                "Czas snu, który jest przedstawiony na poniższym wykresie, został oszacowany poprzez 
                obliczenie różnicy między ostatnim porannym budzikiem a ostatnią 
                aktywnością telefonu danego dnia (za koniec dnia przyjęta została godzina 5:15)."))
  })
  
  output$mean_sleep <- renderUI({
    req(input$person, input$date_4)
    
    text <- sleepy_text(input$person, input$date_4)[1]
    HTML(text)
  })
  
  output$max_sleep <- renderUI({
    req(input$person, input$date_4)
    
    text <- sleepy_text(input$person, input$date_4)[2]
    HTML(text)
  })
  
  # ---------------------------------------------------------------------------
  # Treemap -------------------------------------------------------------------
  selected_files <- reactive({
    req(input$person, input$device_treemap)
    user<-input$person
    f1 <- NULL
    f2 <- NULL
    
    if (input$device_treemap == "Telefon") {
      f1 <- paste0("data/treemap/", user , "_telefon_treemap.csv")
    } else if (input$device_treemap == "Laptop") {
      f1 <- paste0("data/treemap/", user, "_komputer_treemap.csv")
    } else if (input$device_treemap == "Wszystkie") {
      f1 <- paste0("data/treemap/", user, "_komputer_treemap.csv")
      f2 <- paste0("data/treemap/", user, "_telefon_treemap.csv")
    }
    
    list(path1 = f1, path2 = f2)
  })
  
  data_clean <- reactive({
    paths <- selected_files() 
    req(paths$path1, input$date_3)
    start_date <- input$date_3[1]
    end_date <- input$date_3[2]
    
    d1 <- cleaning_data_ania(paths$path1, start_date, end_date)
    
    if (!is.null(paths$path2)) {
      d2 <- cleaning_data_ania(paths$path2, start_date, end_date)
      return(bind_rows(d1, d2))
    }
    return(d1)
  })
  output$wykres_treemap<- renderPlotly({
    make_treemap(data_clean())
  })
  
  # Zakonczenie ---------------------------------------------------------------
  
  output$end <- renderUI({
    HTML(paste0("<div style='margin-left: 20px; font-size: 22px;'>",
                "Dane zostały uzyskane za pomocą aplikacji ActivityWatch dla laptopów i telefonów."))
  })
}


shinyApp(ui = app_ui, server = server)
