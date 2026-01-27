library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(stringr)
library(lubridate)
library(reactable)
library(ggplot2)
library(leaflet)
library(htmltools)
library(tidyr)

theme_set(theme_light())

df_sztuczne <- read.csv("sztucznedane.csv", stringsAsFactors = FALSE)
df_sztuczne$Miesiac <- as.Date(df_sztuczne$Miesiac)

# Funkcja wczytująca dane finansowe
load_person_data <- function(file_path) {
  if(!file.exists(file_path)) return(NULL)
  
  # Wczytanie danych
  df <- read.csv(file_path, sep = ";", stringsAsFactors = FALSE)
  
  if(nrow(df) < 3) return(NULL)
  
  df %>%
    mutate(
      Kwota.operacji = str_replace_all(Kwota.operacji, "[^0-9,-]", ""),
      Kwota.operacji = as.numeric(str_replace(Kwota.operacji, ",", ".")),
      Data.księgowania = dmy(Data.księgowania),
      Tydzien = floor_date(Data.księgowania, unit = "week"),
      
      Kategoria = case_when(
        Kategoria %in% c("Artykuły spożywcze", "Żywność i chemia domowa", "Za zakupy do domu") ~ "Żywność i dom",
        Kategoria %in% c("Restauracje i kawiarnie", "Jedzenie poza domem", "Puby i kluby") ~ "Jedzenie na mieście",
        Kategoria %in% c("Transport publiczny", "Paliwo", "Przejazdy", "Auto i transport - inne") ~ "Transport",
        Kategoria %in% c("Kosmetyki", "Zdrowie i uroda", "Lekarstwa") ~ "Zdrowie i uroda",
        Kategoria %in% c("Ubrania", "Obuwie", "Dodatki, biżuteria", "Odzież i obuwie", "Usługi (pralnia, krawiec, szewc,...)") ~ "Ubrania i obuwie",
        Kategoria %in% c("Multimedia", "Kino i teatr", "Wyjścia i wydarzenia", "Sport i hobby", "Zajęcia dodatkowe") ~ "Rozrywka",
        Kategoria %in% c("Książki", "Gazety lub czasopisma", "Multimedia, książki i prasa", "Edukacja") ~ "Książki i edukacja",
        Kategoria %in% c("Podróże", "Podróże i wyjazdy") ~ "Podróże",
        Kategoria %in% c("Internet, TV, telefon", "Ubezpieczenia", "Opłaty i odsetki") ~ "Rachunki i usługi",
        Kategoria %in% c("Prezenty, upominki", "Prezenty i wsparcie", "Sprzęt AGD i RTV", "Akcesoria i wyposażenie", "Zakupy przez internet", "Inne", "Bez kategorii", "Nieistotne - inne", "Płatności - inne") ~ "Inne zakupy",
        Kategoria %in% c("Zwrot", "Wpływy - inne", "Przelew własny") ~ "Transfery",
        TRUE ~ "Inne"
      )
    ) %>%
    filter(!is.na(Data.księgowania), !is.na(Kwota.operacji), Kwota.operacji < 0)
}

# Funkcja mapująca ikony dla mapy (Poprawiona: małe litery i trimws)
get_icon <- function(kat) {
  kat <- trimws(tolower(as.character(kat)))
  case_when(
    kat == "piekarnia"   ~ "lemon-o",
    kat == "spożywcze"   ~ "shopping-basket",
    kat == "restauracja" ~ "cutlery",
    kat == "książki"     ~ "book",
    kat == "odzież"      ~ "shopping-bag",
    kat == "inne"        ~ "star",
    TRUE                 ~ "info-circle"
  )
}

# Wczytanie danych do mapy
if(file.exists("miejsca.csv")) {
  punkty_mapa <- read.csv("miejsca.csv", stringsAsFactors = FALSE, strip.white = TRUE)
  
  # Przypisanie kolorów
  punkty_mapa <- punkty_mapa %>%
    mutate(kolor_markeru = case_when(
      osoba == "Barbara" ~ "purple",
      osoba == "Rozalia" ~ "blue",
      osoba == "Filip"   ~ "red",
      TRUE               ~ "black"
    ))
} else {
  punkty_mapa <- NULL
}

lista_osob <- list(
  "osoba1" = list(name = "Barbara", data = load_person_data("basia_wydatki.csv")),
  "osoba2" = list(name = "Rozalia", data = load_person_data("rozalia_wydatki.csv")),
  "osoba3" = list(name = "Filip",   data = load_person_data("filip_wydatki.csv"))
)

# Wczytanie danych sztucznych
df_sztuczne <- read.csv("sztucznedane.csv", stringsAsFactors = FALSE)
df_sztuczne$Miesiac <- as.Date(df_sztuczne$Miesiac)


ui <- dashboardPage(
  dashboardHeader(title = "Analiza Wydatków"),
  skin = "green",
  dashboardSidebar(
    sidebarMenu(id = "tabs",
                menuItem("Strona Główna", tabName = "home", icon = icon("home")),
                menuItem("Analiza Indywidualna", icon = icon("chart-bar"), startExpanded = TRUE,
                         lapply(names(lista_osob), function(id) {
                           menuItem(lista_osob[[id]]$name, tabName = id, icon = icon("user"))
                         })
                ),
                hr(),
                conditionalPanel(
                  condition = "input.tabs != 'home' && input.tabs != 'wspolne'",
                  uiOutput("slider_ui"),
                  selectInput("kolumna", "Grupuj według:", choices = c("Kategoria" = "Kategoria","Typ operacji" = "Typ.operacji")),
                  div(style = "padding: 0 15px;", 
                      actionButton("select_all", "Zaznacz wszystko", class = "btn-xs"),
                      actionButton("deselect_all", "Odznacz wszystko", class = "btn-xs")),
                  tags$div(style = "max-height: 250px; overflow-y: auto; margin-top: 10px;", uiOutput("checkboxy_ui"))
                )
    )
  ),
  body = dashboardBody(
    
    tags$head(
      tags$link(href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&display=swap&subset=latin-ext", rel="stylesheet"),
      tags$style(HTML("
        body, h1, h2, h3, h4, h5, h6, .main-header .logo { 
            font-family: 'Lato', sans-serif !important; 
        }
        h1, h2, h3, h4, h5, h6 { font-weight: 700; }
        .main-header .logo { font-weight: bold; }
        
        .irs--shiny .irs-bar {
          background: #39b33d !important;
          border-top: 1px solid #39b33d !important;
          border-bottom: 1px solid #39b33d !important;
        }
        .irs--shiny .irs-bar-edge {
          background: #39b33d !important;
          border: 1px solid #39b33d !important;
        }
        .irs--shiny .irs-single, .irs--shiny .irs-from, .irs--shiny .irs-to {
          background: #39b33d !important;
        }
        
        input[type='checkbox'] {
          accent-color: #39b33d !important;
        }
      "))
    ),
    
    do.call(tabItems, c(
      list(
        tabItem(tabName = "home",
                fluidRow(box(width = 12, style = "text-align: center;", uiOutput("home_welcome_text"))),
                fluidRow(
                  box(width = 12, style = "text-align: center; padding: 20px;",
                      uiOutput("home_welcome_text"),
                      hr(style = "border-top: 1px solid #d2d6de;"),
                      div(h4("O systemie", style = "text-align: center; font-weight: bold;"),
                          p("Grupa 13 w składzie: Barbara Kozłowska, Filip Łabuś, Rozalia Wróblewska wita w aplikacji
                            służącej do wykonywania analizy finansowej, powstałej jako projekt 2 Technik Wizualizacji Danych
                             w semestrze zimowym roku akademickiego 2025/2026. Pokazane dane są mieszanką losowych wartości
                            oraz naszych wydatków w roku 2025."),
                          p("Niniejsza aplikacja służy do szczegółowego monitorowania i wizualizacji domowych finansów. 
                      Dane są automatycznie przetwarzane z plików bankowych, co pozwala na bieżący wgląd w 
                      strukturę wydatków i bardziej świadome planowanie wydatków."),
                          p("Aby rozpocząć analizę, wybierz osobę z menu po lewej stronie. Możesz tam filtrować 
                      transakcje według dat oraz konkretnych kategorii operacji.")
                      )
                  )
                ),
                fluidRow(
                  #box(title = "Udział osób w wydatkach", width = 6, plotlyOutput("home_plot_1")),
                  box(title = "Udział osób w wydatkach", width = 6, plotOutput("home_plot_1", height = "400px")),
                  box(title = "Top 8 kategorii (wszyscy)", width = 6, plotlyOutput("home_plot_2"))
                ),
                
                fluidRow(
                  box(
                    title = "Mapa ulubionych miejsc",
                    status = "success",
                    solidHeader = TRUE,
                    width = 12,
                    leafletOutput("wspolna_mapa", height = "500px")
                  )
                )
                
        )
      ),
      lapply(names(lista_osob), function(id) {
        tabItem(tabName = id,
                box(width = 12, uiOutput(paste0("header_", id))),
                box(title = "Suma tygodniowa", width = 12, plotlyOutput(paste0("plot1_", id))),
                box(title = "Podział na kategorie", width = 12, plotlyOutput(paste0("plot2_", id))),
                uiOutput(paste0("summary_ui_", id)),
                box(
                  title = "Symulacja Budżetu (Dane Przykładowe)", 
                  #status = "warning", 
                  solidHeader = TRUE, 
                  width = 12,
                  div(
                    style = "padding-bottom: 10px; color: #555;",
                    icon("info-circle"),
                    tags$b("Uwaga:"), 
                    "Poniższy wykres bazuje na sztucznych danych (symulacja)."
                  ),
                  
                  sliderInput(paste0("sztuczne_zakres_", id), "Zakres miesięcy:",
                              min = min(df_sztuczne$Miesiac),
                              max = max(df_sztuczne$Miesiac),
                              value = c(min(df_sztuczne$Miesiac), max(df_sztuczne$Miesiac)),
                              timeFormat = "%m", 
                              step = 1, 
                              width = "100%"
                  ),
                  plotlyOutput(paste0("wykres_sztuczny_", id), height = "300px")
                )
        )
      })
    ))
  )
)

server <- function(input, output, session) {
  
  curr_raw <- reactive({ 
    req(input$tabs)
    if(input$tabs %in% names(lista_osob)) {
      lista_osob[[input$tabs]]$data 
    } else { NULL }
  })
  
  polskie_miesiace <- c("sty", "lut", "mar", "kwi", "maj", "cze", "lip", "sie", "wrz", "paź", "lis", "gru")
  
  output$home_welcome_text <- renderUI({
    godzina <- hour(Sys.time())
    pora <- if(godzina < 18) "Dzień dobry" else "Dobry wieczór"
    total_wydatki <- sum(sapply(lista_osob, function(x) sum(x$data$Kwota.operacji, na.rm=TRUE)), na.rm=TRUE)
    
    HTML(paste0(
      "<h1>", pora, "!</h1>",
      "<h3>Witaj w systemie analizy wydatków.</h3>",
      "Łączna kwota wydatków wszystkich osób: <b>", 
      format(abs(round(total_wydatki, 2)), nsmall=2), " zł</b>"
    ))
  })
  
  all_data <- reactive({
    bind_rows(lapply(names(lista_osob), function(id) {
      if(!is.null(lista_osob[[id]]$data)) {
        lista_osob[[id]]$data %>% mutate(Osoba = lista_osob[[id]]$name)
      }
    }))
  })
  
  output$home_plot_1 <- renderPlot({
    df <- all_data() %>% 
      group_by(Osoba) %>% 
      summarise(suma = abs(sum(Kwota.operacji, na.rm = TRUE)), .groups = "drop") %>%
      arrange(desc(suma)) # Sortowanie malejąco
    
    total_suma <- sum(df$suma)
    one_square_value <- total_suma / 100
    
    df <- df %>% 
      mutate(squares = round((suma / total_suma) * 100))
    diff <- 100 - sum(df$squares)
    if(diff != 0) {
      df$squares[1] <- df$squares[1] + diff 
    }
    
    waffle_vector <- rep(df$Osoba, df$squares)
    if(length(waffle_vector) < 100) waffle_vector <- c(waffle_vector, rep(NA, 100 - length(waffle_vector)))
    if(length(waffle_vector) > 100) waffle_vector <- waffle_vector[1:100]
    
    waffle_data <- expand.grid(x = 1:10, y = 1:10)
    waffle_data$Osoba <- waffle_vector
    
    waffle_data$Osoba <- factor(waffle_data$Osoba, levels = df$Osoba)
    
    kolory_mapy <- c(
      "Barbara" = "#605ca8",
      "Rozalia" = "#0073b7",
      "Filip"   = "#dd4b39"
    )
    
    etykiety_legendy <- setNames(
      paste0(df$Osoba, " (", format(round(df$suma, 2), nsmall=2), " zł)"),
      df$Osoba
    )
    
    ggplot(waffle_data, aes(x = x, y = y, fill = Osoba)) +
      geom_tile(color = "white", size = 0.8) +
      scale_fill_manual(
        values = kolory_mapy,
        labels = etykiety_legendy 
      ) +
      coord_equal() +
      labs(
        subtitle = paste0("Jeden kwadracik (■) ≈ ", format(round(one_square_value, 2), nsmall=2), " zł"),
        fill = "Osoba i suma wydatków"
      ) +
      theme_void() +
      theme(
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5, family = "Lato"),
        plot.subtitle = element_text(size = 12, color = "#555555", hjust = 0.5, margin = margin(b = 10), family = "Lato"),
        legend.position = "bottom",
        legend.title = element_text(face = "bold", size = 10),
        legend.text = element_text(size = 11)
      )
  })
  
  output$home_plot_2 <- renderPlotly({
    df <- all_data() %>% group_by(Kategoria) %>% summarise(suma = abs(sum(Kwota.operacji))) %>%
      slice_max(suma, n = 8)
    
    plot_ly(df, 
            x = ~reorder(Kategoria, -suma),
            y = ~suma, 
            type = "bar", 
            marker = list(color = '#2ea646'),
            text = ~paste(round(suma, 2), "zł"),
            hoverinfo = "text",
            textposition = "none") %>%
      layout(xaxis = list(title = "Kategoria"), 
             yaxis = list(title = "Suma (zł)"))
  })
  
  
  output$wspolna_mapa <- renderLeaflet({
    
    if(is.null(punkty_mapa)) return(leaflet() %>% addTiles())
    
    
    mapa <- leaflet(data = punkty_mapa) %>%
      addTiles() %>%
      
      setView(lng = 21.0122, lat = 52.2297, zoom = 12) %>%
      
      setMaxBounds(lng1 = 20.8, lat1 = 52.0,  
                   lng2 = 21.3, lat2 = 52.5)  
    
    
    for(i in 1:nrow(punkty_mapa)) {
      punkt <- punkty_mapa[i, ]
      nazwa_ikony <- get_icon(punkt$kategoria)
      
      
      uzyta_biblioteka <- "fa"
      if(nazwa_ikony == "cutlery") {
        uzyta_biblioteka <- "glyphicon"
      }
      
      ikona_specyficzna <- awesomeIcons(
        icon = nazwa_ikony,
        library = uzyta_biblioteka,
        markerColor = punkt$kolor_markeru,
        iconColor = 'black'
      )
      
      mapa <- mapa %>%
        addAwesomeMarkers(
          lng = punkt$lon, 
          lat = punkt$lat,
          icon = ikona_specyficzna,
          group = punkt$osoba,
          popup = paste0(
            "<div style='min-width: 150px;'>",
            "<h4 style='margin:0; color:#2c3e50;'>", punkt$tytul, "</h4>",
            "<hr style='margin:5px 0;'>",
            "<b>Kategoria:</b> ", punkt$kategoria, "<br>",
            "<b>Osoba:</b> ", punkt$osoba,
            "</div>"
          ),
          label = punkt$tytul
        )
    }
    
    
    mapa %>%
      addLayersControl(
        overlayGroups = unique(punkty_mapa$osoba),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      addLegend(
        position = "bottomright",
        colors = c("#605ca8","blue", "red"), 
        labels = c("Barbara","Rozalia", "Filip"),
        title = "Osoba",
        opacity = 1
      )
  })
  
  
  output$slider_ui <- renderUI({
    req(curr_raw())
    r <- range(curr_raw()$Tydzien, na.rm = TRUE)
    sliderInput("data_range", "Okres:", min = r[1], max = r[2], value = r, step = 7, timeFormat = "%d.%m")
  })
  
  output$checkboxy_ui <- renderUI({
    req(curr_raw(), input$kolumna)
    opts <- unique(curr_raw()[[input$kolumna]])
    checkboxGroupInput("wybrane_opcje", "Filtry:", choices = opts, selected = opts)
  })
  
  observeEvent(input$select_all, {
    req(curr_raw())
    opts <- unique(curr_raw()[[input$kolumna]])
    updateCheckboxGroupInput(session, "wybrane_opcje", selected = opts)
  })
  
  observeEvent(input$deselect_all, {
    updateCheckboxGroupInput(session, "wybrane_opcje", selected = character(0))
  })
  
  dane_finalne <- reactive({
    req(curr_raw(), input$data_range, input$wybrane_opcje)
    curr_raw() %>% 
      filter(Tydzien >= input$data_range[1], 
             Tydzien <= input$data_range[2], 
             .data[[input$kolumna]] %in% input$wybrane_opcje)
  })
  
  lapply(names(lista_osob), function(id) {
    
    
    wybrany_kolor <- case_when(
      id == "osoba1" ~ "#605ca8", 
      id == "osoba2" ~ "#0073b7", 
      id == "osoba3" ~ "#dd4b39", 
      TRUE ~ "green"
    )
   
    
    output[[paste0("header_", id)]] <- renderUI({
      df <- dane_finalne()
      req(nrow(df) > 0)
      suma_wydatkow <- abs(sum(df$Kwota.operacji))
      top_kat <- df %>% group_by(K = .data[[input$kolumna]]) %>% 
        summarise(s = abs(sum(Kwota.operacji))) %>% slice_max(s, n = 1, with_ties = FALSE)
      
      HTML(paste0(
        "Okres: <b>", format(input$data_range[1], "%d.%m.%Y"), " - ", format(input$data_range[2], "%d.%m.%Y"), "</b><br>",
        "Suma: <b>", format(round(suma_wydatkow, 2), nsmall = 2), " zł</b><br>",
        "Najwięcej: <b>", top_kat$K, "</b> (", round(top_kat$s, 2), " zł)"
      ))
    })
    
    output[[paste0("plot1_", id)]] <- renderPlotly({
      df_raw <- dane_finalne()
      req(nrow(df_raw) > 0)
      total_suma <- abs(sum(df_raw$Kwota.operacji, na.rm = TRUE))
      
      df_tydzien <- df_raw %>% 
        group_by(Tydzien) %>% 
        summarise(suma_tyg = abs(sum(Kwota.operacji)), .groups = "drop") %>%
        mutate(procent = (suma_tyg / total_suma) * 100)
      
      min_d <- min(df_tydzien$Tydzien, na.rm = TRUE)
      max_d <- max(df_tydzien$Tydzien, na.rm = TRUE)
      
      tick_dates <- seq(floor_date(min_d, "month"), ceiling_date(max_d, "month"), by = "month")
      
      tick_labels <- paste(polskie_miesiace[month(tick_dates)])
      
      plot_ly(df_tydzien, 
              x = ~Tydzien, 
              y = ~suma_tyg, 
              type = "bar", 
              marker = list(color = wybrany_kolor),
              text = ~paste0(
                "<b>Tydzień od:</b> ", format(Tydzien, "%d.%m.%Y"), "<br>",
                "<b>Suma wydatków:</b> ", format(round(suma_tyg, 2), nsmall = 2), " zł<br>",
                "<b>Udział w okresie:</b> ", round(procent, 1), "%"
              ),
              hoverinfo = "text",
              textposition = "none"
      ) %>% 
        layout(
          xaxis = list(
            title = "Miesiąc",
            # Tutaj podmieniamy automatyczną oś na naszą ręczną
            tickvals = tick_dates,  # Gdzie mają być kreski
            ticktext = tick_labels, # Co ma być napisane (po polsku)
            tickmode = "array"      # Tryb tablicowy
          ),
          yaxis = list(title = "Suma wydatków (zł)"),
          hoverlabel = list(bgcolor = "white", font = list(size = 13))
        )
    })
    
    output[[paste0("plot2_", id)]] <- renderPlotly({
      df <- dane_finalne()
      req(nrow(df) > 0)
      
      total <- abs(sum(df$Kwota.operacji))
      
      df_plot <- df %>% 
        group_by(Tydzien, G = .data[[input$kolumna]]) %>% 
        summarise(s = abs(sum(Kwota.operacji)), .groups = "drop") %>%
        mutate(p = (s / total) * 100)
      
      min_d <- min(df_plot$Tydzien, na.rm = TRUE)
      max_d <- max(df_plot$Tydzien, na.rm = TRUE)
      
      tick_dates <- seq(floor_date(min_d, "month"), ceiling_date(max_d, "month"), by = "month")
      tick_labels <- paste(polskie_miesiace[month(tick_dates)])
       
      plot_ly(df_plot, 
              x = ~Tydzien, 
              y = ~s, 
              color = ~G, 
              type = "bar", 
              text = ~paste0(
                "<b>Data:</b> ", format(Tydzien, "%d.%m.%Y"), "<br>",
                "<b>Kategoria:</b> ", G, "<br>",
                "<b>Kwota:</b> ", format(round(s, 2), nsmall = 2), " zł<br>",
                "<b>Udział:</b> ", round(p, 1), "%"
              ),
              hoverinfo = "text",
              textposition = "none"
      ) %>% 
        layout(
          barmode = "stack",
          xaxis = list(
            title = "Miesiąc",
            tickvals = tick_dates,  
            ticktext = tick_labels, 
            tickmode = "array"
          ),
          yaxis = list(title = "Suma wydatków (zł)"),
          hoverlabel = list(bgcolor = "white", font = list(size = 13))
        )
    })
    
    output[[paste0("summary_ui_", id)]] <- renderUI({
      req(input$wybrane_opcje)
      tagList(
        box(title = "Częstotliwość wydatków", width = 12, 
            plotlyOutput(paste0("heatmap_", id), height = "210px")),
        
        box(title = "Szczegółowe podsumowanie", width = 12, 
            reactableOutput(paste0("tab_", id)))
      )
    })
    
    output[[paste0("heatmap_", id)]] <- renderPlotly({
      library(tidyr)
      library(lubridate)
      
      df <- dane_finalne()
      req(nrow(df) > 0)
      
      min_date <- min(df$Data.księgowania)
      max_date <- max(df$Data.księgowania)
      
      wlasne_skroty <- c("pon", "wt", "śr", "czw", "pt", "sob", "ndz")
      
      plot_data <- df %>%
        count(Data.księgowania, name = "Liczba") %>%
        complete(Data.księgowania = seq(min_date, max_date, by = "day"), 
                 fill = list(Liczba = 0)) %>%
        mutate(
          Dzien_Num = wday(Data.księgowania, week_start = 1),
          
          Dzien_Osi = factor(Dzien_Num, levels = 1:7, labels = wlasne_skroty),
          
          Dzien_Pelny = wday(Data.księgowania, label = TRUE, week_start = 1, abbr = FALSE),
          Dzien_Pelny = str_to_title(as.character(Dzien_Pelny)),
          
          Tydzien_Start = floor_date(Data.księgowania, unit = "week", week_start = 1),
          
          Tooltip = paste0(
            "<b>Data:</b> ", format(Data.księgowania, "%d.%m.%Y"), "<br>",
            "<b>Dzień:</b> ", Dzien_Pelny, "<br>",
            "<b>Liczba operacji:</b> ", Liczba
          )
        )
      
      p <- ggplot(plot_data, aes(x = Tydzien_Start, y = Dzien_Osi, fill = Liczba, text = Tooltip)) +
        geom_tile(color = "white", size = 2) + 
        scale_fill_gradient(low = "#ebedf0", high = wybrany_kolor) +

      scale_y_discrete(limits = rev(wlasne_skroty)) + 
        scale_x_date(date_labels = "%b", date_breaks = "1 month") +
        theme_minimal() +
        labs(x = "", y = "", fill = "Liczba") +
        theme(
          panel.grid = element_blank(),
          axis.ticks = element_blank(),
          axis.text.x = element_text(hjust = 0),
          panel.background = element_rect(fill = "white", color = NA),
          legend.position = "none"
        )
      
      ggplotly(p, tooltip = "text") %>%
        config(displayModeBar = TRUE) %>%
        layout(plot_bgcolor = "white")
    })
    
    
    output[[paste0("tab_", id)]] <- renderReactable({
      df <- dane_finalne(); req(nrow(df) > 0)
      total <- abs(sum(df$Kwota.operacji))
      sum_df <- df %>% group_by(Kat_Tech = .data[[input$kolumna]]) %>% 
        summarise(Suma_Tech = abs(sum(Kwota.operacji)), N_Tech = n()) %>% 
        mutate(P_Tech = round(Suma_Tech/total*100, 1)) %>% arrange(desc(Suma_Tech))
      
      reactable(sum_df, filterable = TRUE, highlight = TRUE,
                columns = list(
                  Kat_Tech = colDef(name = "Kategoria"),
                  Suma_Tech = colDef(name = "Suma", format = colFormat(suffix = " zł", separators = TRUE)),
                  N_Tech = colDef(name = "Ilość"),
                  P_Tech = colDef(name = "% ogółu", format = colFormat(suffix = "%"))
                ),
                details = function(index) {
                  det <- df %>% filter(.data[[input$kolumna]] == sum_df$Kat_Tech[index]) %>% 
                    select(Data = Data.księgowania, Kwota = Kwota.operacji) %>% mutate(Kwota = abs(Kwota))
                  div(style = "padding: 1rem", reactable(det, compact = TRUE, outlined = TRUE))
                })
    })
    
    output[[paste0("wykres_sztuczny_", id)]] <- renderPlotly({
      req(input[[paste0("sztuczne_zakres_", id)]])
      zakres <- input[[paste0("sztuczne_zakres_", id)]]
      wybrana_osoba <- lista_osob[[id]]$name
      
      data_start <- floor_date(zakres[1], "month")
      data_koniec <- ceiling_date(zakres[2], "month") - days(1) 
      
      plot_data <- df_sztuczne %>%
        filter(
          Osoba == wybrana_osoba,
          Miesiac >= data_start,
          Miesiac <= data_koniec
        ) %>%
        pivot_longer(
          cols = c("Kwota_Otrzymana", "Kwota_Wydana"),
          names_to = "Typ",
          values_to = "Kwota"
        ) %>%
        mutate(
          Typ = case_when(
            Typ == "Kwota_Otrzymana" ~ "Wpływy",
            Typ == "Kwota_Wydana" ~ "Wydatki"
          )
        )
      
      p <- ggplot(plot_data, aes(x = Miesiac, y = Kwota, fill = Typ)) +
        geom_col(position = "dodge", width = 20) + 
        scale_fill_manual(values = c("Wpływy" = "#445B88", "Wydatki" = "#EB334B")) +
        scale_x_date(date_labels = "%b", date_breaks = "1 month") + # Dodano rok do osi
        theme_minimal() +
        labs(
          x = "Miesiąc",
          y = "Kwota (PLN)",
          fill = ""
        ) +
        theme(legend.position = "bottom")
      
      ggplotly(p) %>% config(displayModeBar = FALSE)
    })
    
  })
}

shinyApp(ui, server)