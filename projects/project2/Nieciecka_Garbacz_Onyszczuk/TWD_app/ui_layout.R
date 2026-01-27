library(shiny)
library(plotly)
library(fontawesome)

app_ui <- navbarPage(
  title = "Analiza czasu spędzonego przed ekranem",
  id = "person",
  
  header = tags$head(
    tags$style(HTML("
      body { background-color: #121212; color: white; }
      .navbar { 
        background-color: #1e1e1e; 
        border-bottom: 1px solid #333; 
        min-height: 80px !important;
      }
      
      .navbar-default .navbar-nav > li > a { 
        color: white !important; 
        font-size: 20px !important;  
        padding-top: 30px !important; 
        padding-bottom: 30px !important; 
      }
      
      .navbar-default .navbar-brand { 
        color: white !important; 
        font-size: 26px !important; 
        padding-top: 30px !important;
        height: 80px !important;
      }
      
      .navbar-default .navbar-nav > .active > a { 
        background-color: #333 !important; 
        color: #4ebce2 !important; 
      }
      
      .well { background-color: #1e1e1e; border: none; }
      .selectize-input { background: #333 !important; color: white !important; }
      
      hr { 
        border-top: 3px solid #555;
        margin-top: 40px;            
        margin-bottom: 40px;      
      }
      
      /* Tło całego wyskakującego okienka */
      .datepicker {
        background-color: #222 !important;
        color: white !important;
        border: 1px solid #444;
      }
      
      /* Kolor dni tygodnia i nagłówka */
      .datepicker table tr td, .datepicker table tr th {
        color: white !important;
      }

      /* Styl dla najechania myszką na datę */
      .datepicker table tr td.day:hover,
      .datepicker table tr td.focused {
        background: #444 !important;
      }

      /* Kolor wybranych dni (zakresu) */
      .datepicker table tr td.active, 
      .datepicker table tr td.range {
        background-color: #007bff !important; /* Ładny niebieski dla zaznaczenia */
        color: white !important;
      }

      /* Kolor dni z innych miesięcy (wyciszone) */
      .datepicker table tr td.old, .datepicker table tr td.new {
        color: #777 !important;
      }
      
      #date_1 input {
        background-color: #2c2c2c !important; 
        color: white !important;
        border: 1px solid #555555 !important;
      }
      
      #date_1 .input-group-addon {
        background-color: #2c2c2c !important;
        color: white !important;
        border-top: 1px solid #555555 !important;
        border-bottom: 1px solid #555555 !important;
        border-left: none !important;
        border-right: none !important;
      }
      
      #date_3 input {
        background-color: #2c2c2c !important; 
        color: white !important;
        border: 1px solid #555555 !important;
      }
      
      #date_3 .input-group-addon {
        background-color: #2c2c2c !important;
        color: white !important;
        border-top: 1px solid #555555 !important;
        border-bottom: 1px solid #555555 !important;
        border-left: none !important;
        border-right: none !important;
      }
      
      #date_4 input {
        background-color: #2c2c2c !important; 
        color: white !important;
        border: 1px solid #555555 !important;
      }
      
      #date_4 .input-group-addon {
        background-color: #2c2c2c !important;
        color: white !important;
        border-top: 1px solid #555555 !important;
        border-bottom: 1px solid #555555 !important;
        border-left: none !important;
        border-right: none !important;
      }
    "))
  ),
  
  # Zakładki
  tabPanel("Ania", value = "Ania", icon = icon('user')),
  tabPanel("Nina", value = "Nina", icon = icon('user')),
  tabPanel("Karolina", value = "Karolina", icon = icon('user')),
  
  # Treść aplikacji
  footer = fluidPage(
    # -------------------------------------------------------------------------
    hr(),
    h4("Czas spędzony przed ekranem", style = "margin-left: 20px; color: #ddd; font-size: 24px;"),
    
    fluidRow(
      style = "margin-top: 20px; margin-bottom: 20px; margin-left: 20px;",
      column(6, dateRangeInput(inputId = "date_1", label = "Wybierz datę", start = "2025-11-29", 
                               end = "2026-01-26")),
      column(6,selectInput(
        inputId = "device_1",
        label = "Wybierz urządzenie",
        choices = c(
          "Wszystkie" = "total_duration",
          "Laptop" = "laptop_duration",
          "Telefon" = "phone_duration")
        )
      ),
      column(6,checkboxInput(
        inputId = "limit_1",
        label = "Pokaż ustalony limit czasowy",
        value = TRUE
        )
      )
    ),
    
    plotlyOutput("barplot_1"),
    
    tags$p("Uwaga: Przy wyborze opcji 'Wszystkie', wykres sumuje czas z różnych urządzeń. Może to skutkować wartościami powyżej 60 minut w ciągu godziny, jeśli korzystano jednocześnie z telefonu i komputera.", 
           style = "color: #888888; font-size: 12px; margin-left: 20px; margin-top: 5px; font-style: italic;"),
    
    # -------------------------------------------------------------------------
    hr(),
    h4("Rozkład intensywności i mapa aktywności", style = "margin-left: 20px; color: #ddd; font-size: 24px;"),
    
    fluidRow(
      style = "margin-top: 20px; margin-bottom: 20px; margin-left: 20px;",
      column(6, uiOutput("week_selector")),
      column(6, selectInput("device", "Urządzenie:", choices = c("Wszystkie", "Laptop", "Telefon")))
    ),
    
    # Statystyki
    fluidRow(
      style = "margin-top: 10px; margin-bottom: 30px;",
      column(6, htmlOutput('total_time')),
      column(6, htmlOutput('mean_time'))
    ),
    
    #density plot + heatmapa
    plotlyOutput("density_heatmap", height = "700px"),
    
    tags$p("Uwaga: Przy wyborze opcji 'Wszystkie', wykres sumuje czas z różnych urządzeń. Może to skutkować wartościami powyżej 60 minut w ciągu godziny, jeśli korzystano jednocześnie z telefonu i komputera.", 
           style = "color: #888888; font-size: 12px; margin-left: 20px; margin-top: 5px; font-style: italic;"),
    
    # -------------------------------------------------------------------------
    hr(),
    h4("Najczęściej używane aplikacje w podziale na kategorie ", style = "margin-left: 20px; color: #ddd; font-size: 24px;"),
    
    fluidRow(
      style = "margin-top: 20px; margin-bottom: 20px; margin-left: 20px;",
      column(6, dateRangeInput(inputId = "date_3", label = "Wybierz datę",start = "2025-11-29", 
             end = "2026-01-26")),
      column(6, selectInput("device_treemap", "Urządzenie:", choices = c("Wszystkie", "Laptop", "Telefon")))
    ),
    tags$p("Po kliknięciu na wybrana kategorię, nastąpi jej powiększenie.", 
           style = "color: #888888; font-size: 14px; margin-left: 20px; margin-top: 5px; font-style: italic;"),
    #treemap
      plotlyOutput("wykres_treemap", height = "700px"),
    
    # -------------------------------------------------------------------------
    hr(),
    h4("Czas snu oszacowany na podstawie użykowania telefonu", style = "margin-left: 20px; color: #ddd; font-size: 24px;"),
    
    fluidRow(style = "margin-top: 10px; margin-bottom: 30px;",
             column(12, htmlOutput('sleepy_descript'))),
    
    fluidRow(
      style = "margin-top: 20px; margin-bottom: 20px; margin-left: 20px;",
      column(6, 
             dateRangeInput(inputId = "date_4", label = "Wybierz datę", start = "2025-11-29", 
                               end = "2026-01-26"),
             checkboxInput(inputId = "recomm_4", label = "Zalecana ilość snu", value = TRUE))
    ),
    
    plotlyOutput("barplot_2"),
    
    fluidRow(
      style = "margin-top: 10px; margin-bottom: 30px;",
      column(6, htmlOutput('mean_sleep')),
      column(6, htmlOutput('max_sleep'))
    ),
    
    # -------------------------------------------------------------------------
    hr(),
    
    fluidRow(style = "margin-top: 10px; margin-bottom: 30px;",
             column(12, htmlOutput('end'))),
    
  )
)
