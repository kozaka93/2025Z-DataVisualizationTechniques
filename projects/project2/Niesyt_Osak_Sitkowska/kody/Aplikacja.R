library(shiny)
library(tidyverse)
library(plotly)
library(lubridate)
library(tidytext)
library(stringr)
library(bslib)

Sys.setlocale("LC_TIME", "pl_PL.UTF-8") 

cols <- list(
  bg_card = "#ffffff",
  text_main = "#2c3e50",
  text_sub = "#7f8c8d",
  mac_blue = "#007AFF",
  mac_purp = "#AF52DE",
  mac_heat = "Blues",
  gpt_green = "#10a37f",
  gpt_fill   = "rgba(16, 163, 127, 0.1)",
  yt_red    = "#FF0000",
  yt_grad   = "Reds"
)

user_colors <- c(
  "Konrad" = "#005FB8",
  "Mati"    = "#10a37f",
  "Ola"    = "#E63946"
)

safe_read <- function(file) {
  if(file.exists(file)) read.csv(file, stringsAsFactors = FALSE) else NULL
}

# Wczytanie danych
raw_mac <- safe_read("/Users/mateuszosak/Documents/projektTWD2/mac_all.csv")
raw_chat <- safe_read("/Users/mateuszosak/Documents/projektTWD2/chatgpt_all.csv")
raw_yt <- safe_read("/Users/mateuszosak/Documents/projektTWD2/yt_all.csv")

pl_months <- c(
  "sty" = "01", "lut" = "02", "mar" = "03", "kwi" = "04", 
  "maj" = "05", "cze" = "06", "lip" = "07", "sie" = "08", 
  "wrz" = "09", "paź" = "10", "lis" = "11", "gru" = "12"
)

global_min_date <- Sys.Date()
global_max_date <- Sys.Date()
users_list <- c("Brak danych")

if (!is.null(raw_mac)) {
  raw_mac <- raw_mac %>% mutate(Start_Date = as.Date(as_datetime(Start)))
  users_list <- unique(raw_mac$osoba)
  global_min_date <- min(raw_mac$Start_Date, na.rm = TRUE)
  global_max_date <- max(raw_mac$Start_Date, na.rm = TRUE)
}

if (!is.null(raw_yt)) {
  raw_yt <- raw_yt %>% 
    mutate(
      data_num = str_replace_all(Data, pl_months), 
      date_obj = dmy(data_num)
    )
  users_list <- unique(c(users_list, unique(raw_yt$osoba)))
}

if (!is.null(raw_chat)) {
  raw_chat <- raw_chat %>% mutate(date_obj = as_date(as_datetime(time)))
  users_list <- unique(c(users_list, unique(raw_chat$osoba)))
}

users_list <- sort(users_list)

custom_css <- "
  .card-style {
    background-color: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    padding: 20px;
    margin-bottom: 20px;
    border: 1px solid #f0f0f0;
  }
  .nav-tabs > li > a { font-weight: 600; }
  h4 { font-weight: 700; color: #2c3e50; }
  .control-label { font-weight: 600; color: #34495e; }
"

ui <- fluidPage(
  theme = bs_theme(bootswatch = "zephyr", primary = cols$gpt_green),
  tags$head(tags$style(HTML(custom_css))),
  
  titlePanel(div(icon("chart-line"), " Digital Life Dashboard"), windowTitle = "Analytics"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      class = "card-style",
      h4("Filtry Danych"),
      
      selectInput("selected_user", "Wybierz osobę/osoby:", 
                  choices = users_list, 
                  selected = users_list[1], 
                  multiple = TRUE),
      
      dateRangeInput("date_range", "Zakres dat:",
                     start = global_min_date,
                     end = global_max_date,
                     min = "2020-01-01",
                     max = Sys.Date() + 30,
                     language = "pl",
                     separator = " - "),
      
      hr(),
      helpText("Panel agreguje dane dla wszystkich zaznaczonych użytkowników w wybranym okresie."),
      br(),
      tags$small("Autorzy: Konrad Niesyt, Mateusz Osak, Aleksandra Sitkowska", style="color: #bdc3c7;"),
      hr(),
      uiOutput("sidebar_summary_tile")
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        id = "current_tab", 
        # ZAKŁADKA 1: MAC
        tabPanel(
          title = "Mac Ecosystem", 
          icon = icon("apple"),
          br(),
          div(class = "card-style", plotlyOutput("mac_p1", height = "400px")),
          fluidRow(
            column(6, div(class = "card-style", plotlyOutput("mac_p2", height = "350px"))),
            column(6, div(class = "card-style", plotlyOutput("mac_p3", height = "350px")))
          ),
          div(class = "card-style", plotlyOutput("mac_p4", height = "500px"))
        ),
        
        # ZAKŁADKA 2: CHAT GPT
        tabPanel(
          title = "ChatGPT AI", 
          icon = icon("robot"),
          br(),
          fluidRow(
            column(12, div(class = "card-style", plotlyOutput("chat_p1", height = "350px")))
          ),
          fluidRow(
            column(12, div(class = "card-style", plotlyOutput("chat_p2", height = "350px")))
          ),
          fluidRow(
            column(12, div(class = "card-style", plotlyOutput("chat_p3", height = "500px")))
          )
        ),
        
        # ZAKŁADKA 3: YT
        tabPanel(
          title = "YouTube Media", 
          icon = icon("youtube"),
          br(),
          div(class = "card-style", plotlyOutput("yt_p1", height = "500px")),
          fluidRow(
            column(12, div(class = "card-style", plotlyOutput("yt_p2", height = "400px")))
          ),
          div(class = "card-style", plotlyOutput("yt_p3", height = "500px"))
        )
      )
    )
  )
)


# SERVER


server <- function(input, output, session) {
  
  clean_layout <- function(p, title_text, x_title, y_title) {
    p %>% layout(
      title = list(text = paste0("<b>", title_text, "</b>"), x = 0.02, font = list(size = 18, color = cols$text_main)),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      margin = list(t = 50, b = 50, l = 80, r = 20),
      xaxis = list(
        showgrid = FALSE, 
        zeroline = FALSE, 
        title = list(text = x_title, font = list(size=12)),
        tickformat = "%d %b\n%Y",
        hoverformat = "%d %B %Y" 
      ),
      yaxis = list(showgrid = TRUE, gridcolor = "#f5f5f5", zeroline = FALSE, title = list(text = y_title, font = list(size=12))),
      font = list(family = "Segoe UI, sans-serif"),
      separators = ", " 
    ) %>% config(
      displayModeBar = FALSE,
      locale = "pl"
    )
  }
  
  df_mac_filtered <- reactive({
    req(raw_mac, input$selected_user)
    data <- raw_mac %>% 
      filter(osoba %in% input$selected_user) %>%
      filter(Start_Date >= input$date_range[1] & Start_Date <= input$date_range[2])
    
    data %>%
      mutate(
        App = str_extract(Aplikacja, "[^.]+$"),
        Date = Start_Date,
        Hour = hour(as_datetime(Start)),
        Wday = factor(wday(as_datetime(Start), label=TRUE, abbr=FALSE, locale="pl_PL"),
                      levels = c("poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela"))
      )
  })
  
  df_chat_filtered <- reactive({
    req(raw_chat, input$selected_user)
    raw_chat %>% 
      filter(osoba %in% input$selected_user) %>%
      filter(date_obj >= input$date_range[1] & date_obj <= input$date_range[2]) %>%
      mutate(time = as_datetime(time), date = date_obj)
  })
  
  df_yt_filtered <- reactive({
    req(raw_yt, input$selected_user)
    raw_yt %>% 
      filter(osoba %in% input$selected_user) %>%
      filter(date_obj >= input$date_range[1] & date_obj <= input$date_range[2]) %>%
      filter(!is.na(Data), !is.na(Godzina)) %>% 
      mutate( 
        Hour_Num = as.numeric(substr(Godzina, 1, 2)), 
        Dzien_Tygodnia = lubridate::wday(date_obj, label = TRUE, abbr = FALSE, week_start = 1) 
      ) %>% 
      filter(!is.na(date_obj), !is.na(Hour_Num)) 
  })
  create_tile <- function(title, value, unit, color, icon_obj, extra_html = NULL) {
    div(
      style = paste0("background: ", color, "; color: white; padding: 15px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.15); margin-top: 10px;"),
      div(style = "display: flex; justify-content: space-between; align-items: center;",
          h6(title, style = "margin: 0; font-size: 0.7rem; font-weight: 700;"),
          icon_obj
      ),
      div(style = "display: flex; align-items: baseline; margin-top: 5px;",
          h2(value, style = "margin: 0; font-weight: 800;"),
          span(unit, style = "margin-left: 5px; font-size: 0.9rem; opacity: 0.9;")
      ),
      if(!is.null(extra_html)) hr(style = "border-top: 1px solid rgba(255,255,255,0.2); margin: 10px 0;"),
      if(!is.null(extra_html)) extra_html
    )
  }
  output$sidebar_summary_tile <- renderUI({
    tab <- input$current_tab
    req(tab)
    
    if (tab == "Mac Ecosystem") {
      m_df <- df_mac_filtered()
      req(nrow(m_df) > 0)
      
      total_h <- sum(m_df$Czas_Sekundy, na.rm = TRUE) / 3600
      stawka <- 30.5
      zarobek <- round(total_h * stawka, 0)
      
      zakupy <- case_when(
        zarobek < 100   ~ "Moglibyście pójść na randkę do kawiarni ☕",
        zarobek < 564   ~ "Moglibyście pójść na dobrą kolację dla 2 osób 🍕",
        zarobek < 2000  ~ 'Stać by was było na warunek z Technik Wizualizacji Danych',
        zarobek < 5000  ~ "Moglibyście kupić: Bilet lotniczy na drugi koniec świata ✈️",
        zarobek < 10000 ~ "Moglibyście kupić: Nowego MacBooka Pro! 💻",
        TRUE            ~ 'Bylibyście ustawieni do końca życia!!!' 
      )
      
      extra_money <- tagList(
        p(em(paste("Gdyby tak pracować, a nie gapić się w ekran... zarobiłbyś ok. ", zarobek, " zł.")), 
          style = "font-size: 0.8rem; line-height: 1.2;"),
        p(strong(zakupy), style = "font-size: 0.85rem; margin-top: 5px;")
      )
      
      tile_money <- create_tile("CZAS PRACY MAC", round(total_h, 1), "h", cols$mac_blue, icon("clock"), extra_money)
      peak_details <- lapply(input$selected_user, function(osoba_nazwa) {
        user_df <- m_df %>% filter(osoba == osoba_nazwa)
        if(nrow(user_df) == 0) return(NULL)
        peak_hour <- user_df %>%
          group_by(Hour) %>%
          summarise(total = sum(Czas_Sekundy), .groups = "drop") %>%
          slice_max(total, n = 1, with_ties = FALSE) %>%
          pull(Hour)
        div(style = "margin-bottom: 8px; padding-bottom: 5px; border-bottom: 1px solid rgba(255,255,255,0.1);",
            p(strong(osoba_nazwa), style = "margin: 0; color: #32ADE6; font-size: 0.95rem;"),
            p(style = "font-size: 1.1rem; font-weight: 600; margin: 0;", paste0(peak_hour, ":00"))
        )
      })
      
      tile_peak <- create_tile("GODZINA SZCZYTU 🕒", "NAJCZĘSTSZA PORA", "UŻYWANIA KOMPUTERA", 
                               "#1c1c1e", icon("clock"), tagList(peak_details))
      
      tagList( tile_money,tile_peak)
        
      
    
    } else if (tab == "ChatGPT AI") {
      df <- df_chat_filtered() %>% filter(role == "user")
      req(nrow(df) > 0)
      
      stats <- df %>% group_by(osoba) %>% summarise(n = n()) %>% arrange(desc(n))
      king_name <- stats$osoba[1]
      king_count <- stats$n[1]
      
      tile_king <- create_tile("KRÓL PROMPTÓW 👑", king_name, paste0("(", king_count, ")"), 
                               cols$gpt_green, icon("crown"), 
                               p(paste0('Ach jak studenci sobie bez niego radzili...'), style="font-size:0.8rem; margin:0;"))
      
      
      total_words <- sum(str_count(df$text, "\\w+"), na.rm = TRUE)
      
      words_per_sheet <- 360 
      total_sheets <- total_words / words_per_sheet
      
      
      tree_A4 <- 8616
      total_trees <- total_sheets / tree_A4
      extra_eco <- tagList(
        p(paste0("Twoje rozmowy to łącznie ", format(total_words, big.mark=" "), " słów."), 
          style = "font-size: 0.8rem; margin: 0;"),
        p(paste0("Zajęłyby one ", round(total_sheets, 1), " kartek A4 (zapisanych obustronnie, zakładając żę na jednej strone możemy zapisać 180 słów)."), 
          style = "font-size: 0.8rem; margin-top: 5px;"),
        p(strong("Gdyby to wydrukować, natura by zapłakała..."), 
          style = "font-size: 0.85rem; margin-top: 5px; color: #10a37f;")
      )
      tile_eco <- div(
        style = "background: #000000; color: #FFFFFF; padding: 15px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.3); margin-top: 15px;",
        div(style = "display: flex; justify-content: space-between;",
            h6("KOSZT EKOLOGICZNY", style = "margin: 0; font-size: 0.7rem; font-weight: 700;"),
            icon("leaf", style = "color: #10a37f;")),
        div(style = "display: flex; align-items: baseline; margin-top: 5px;",
            h2(format(total_trees, digits = 4, nsmall = 5), style = "margin: 0; font-weight: 800;"),
            span("DRZEWA", style = "margin-left: 5px; font-size: 0.9rem; opacity: 0.8;")
        ),
        hr(style = "border-top: 1px solid rgba(255,255,255,0.2); margin: 10px 0;"),
        extra_eco
      )
      
      # Źródło danych CO2 
      # https://techeconomy.ng/study-reveals-grok-ai-as-the-most-eco-friendly-chatbot/
     # https://ember-energy.org/latest-insights/eu-ets-2022/
      # https://models.porsche.com/en-WW/model-start/911
      total_queries <- nrow(df)
      total_co2_g <- total_queries * 4.32
      porsche_km <- total_co2_g / 232  
      turow_sec <- total_co2_g / 364663 
  
      
      extra_co2 <- tagList(
        p(paste0("Wygenerowaliście łącznie ", round(total_co2_g, 1), " g CO2."), 
          style = "font-size: 0.8rem; margin: 0;"),
        p(style = "font-size: 0.8rem; margin-top: 5px;",
          paste0("To tyle, co przejechanie ", round(porsche_km, 2), " km nowym Porsche 911 🏎️")),
        p(style = "font-size: 0.8rem; margin-top: 2px;",
          paste0("Lub", format(turow_sec, scientific = FALSE, digits = 3), " sekundy pracy Elektrowni Turów 🏭"))
      )
      
      tile_co2 <- div(
        style = "background: #343a40; color: #FFFFFF; padding: 15px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.3); margin-top: 15px;",
        div(style = "display: flex; justify-content: space-between;",
            h6("ŚLAD WĘGLOWY AI", style = "margin: 0; font-size: 0.7rem; font-weight: 700;"),
            icon("cloud", style = "color: #adb5bd;")),
        div(style = "display: flex; align-items: baseline; margin-top: 5px;",
            h2(round(total_co2_g / 1000, 3), style = "margin: 0; font-weight: 800;"),
            span("KG CO2", style = "margin-left: 5px; font-size: 0.9rem; opacity: 0.8;")
        ),
        hr(style = "border-top: 1px solid rgba(255,255,255,0.2); margin: 10px 0;"),
        extra_co2
      )
    tagList(tile_king, tile_eco, tile_co2)
    } else if (tab == "YouTube Media") {
      df <- df_yt_filtered()
      req(nrow(df) > 0)
      wyznacz_cel <- function(km) {
        if(km < 5)   return("naszej kochanej Politechniki")
        if(km < 30)  return("granic Warszawy ️")
        if(km < 150) return("Łodzi lub Białegostoku ️")
        if(km < 350) return("Krakowa lub wybrzeża Bałtyku ")
        if(km < 600) return("Berlina lub Pragi ")
        if(km < 1500) return("Paryża lub Wenecji ")
        return("słonecznej Lizbony! ☀️")
      }
      widoki_osob <- lapply(input$selected_user, function(osoba_nazwa) {
        user_df <- df %>% filter(osoba == osoba_nazwa)
        if(nrow(user_df) == 0) return(NULL)
        
        n_vids <- nrow(user_df)
        h_total <- (n_vids * 11.7) / 60
        km_total <- h_total * 5
        
        div(style = "margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.15);",
            p(strong(osoba_nazwa), style = "margin-bottom: 2px; color: #ffeb3b; font-size: 1rem;"),
            p(style = "font-size: 0.8rem; margin: 0; opacity: 0.9;", 
              paste0("Obejrzał(a) ", n_vids, " filmów (", round(h_total, 1), " h).")),
            p(style = "font-size: 0.85rem; margin-top: 5px; line-height: 1.3;",
              "Idąc z Warszawy, doszedłbyś do: ",
              strong(wyznacz_cel(km_total)))
        )
      })
      note <- tags$small(
        paste0("Obliczenia oparto na danych z portalu Statista, wg nich śr. długość filmu to ", 11.7 , " min.
              Zakładamy prędkość chodu 5km/h"),
        style = "font-size: 0.7rem; opacity: 0.7; font-style: italic; display: block; margin-top: 5px;"
      )
      tile_trip <- create_tile("Jak daleko byś zaszedł gdyby nie YT?", "PIESZA", "WYPRAWA", 
                               cols$yt_red, icon("person-walking"), 
                               tagList(widoki_osob, note))
      
      peak_yt_details <- lapply(input$selected_user, function(osoba_nazwa) {
        user_df <- df %>% filter(osoba == osoba_nazwa)
        if(nrow(user_df) == 0) return(NULL)
        
        peak_hour_yt <- user_df %>%
          group_by(Hour_Num) %>%
          summarise(n = n(), .groups = "drop") %>%
          slice_max(n, n = 1, with_ties = FALSE) %>%
          pull(Hour_Num)
        
        div(style = "margin-bottom: 8px; padding-bottom: 5px; border-bottom: 1px solid rgba(255,255,255,0.1);",
            p(strong(osoba_nazwa), style = "margin: 0; color: #ffeb3b; font-size: 0.95rem;"),
            p(style = "font-size: 1.1rem; font-weight: 600; margin: 0;", 
              paste0(peak_hour_yt, ":00"))
        )
      })
      
      tile_peak_yt <- create_tile("SZCZYT SEANSÓW 🎬", "O TEJ PORZE", "POZWALALIŚMY SOBIE NA RELAKS NAJCZĘŚCIEJ", 
                                  "#1c1c1e", icon("clock"), 
                                  tagList(peak_yt_details))
      
      tagList(tile_trip, tile_peak_yt)
    }
  })
 
  
  # WYKRESY MAC
  
  output$mac_p1 <- renderPlotly({
    df <- df_mac_filtered()
    req(nrow(df) > 0)
    
    top_apps <- df %>% 
      count(App, wt = Czas_Sekundy) %>% 
      slice_max(n, n = 8) %>% 
      pull(App)
    
    daily_data <- df %>%
      mutate(App_Label = ifelse(App %in% top_apps, App, "Inne")) %>%
      group_by(Date, App_Label) %>%
      summarise(Hours = sum(Czas_Sekundy) / 3600, .groups = "drop")
    
    custom_palette <- c("#007AFF", "#5856D6", "#00C7BE", "#FF9500", "#FF2D55", "#34C759", "#32ADE6", "#AF52DE", "#8E8E93")
    
    plot_ly(daily_data, x = ~Date, y = ~Hours, type = 'bar', 
            color = ~App_Label, 
            colors = custom_palette,
            hovertemplate = "%{x}<br>%{fullData.name}: <b>%{y:.1f}h</b><extra></extra>") %>%
      clean_layout("Dzienny czas pracy", "Data", "Liczba godzin") %>% 
      layout(barmode = 'stack', legend = list(orientation = "h", y = -0.2))
  })
  output$mac_p2 <- renderPlotly({
    df <- df_mac_filtered()
    req(nrow(df) > 0)
    
    df_sum <- df %>% 
      group_by(osoba, Wday) %>% 
      summarise(Avg_Hours = round((sum(Czas_Sekundy)/3600) / n_distinct(Date), 2), .groups = "drop")
    
    plot_ly(df_sum, x = ~Wday, y = ~Avg_Hours, type = 'bar', 
            color = ~osoba, colors = user_colors,
            hovertemplate = "Osoba: %{fullData.name}<br>Dzień: %{x}<br>Średnia: %{y} godz.<extra></extra>") %>% 
      clean_layout("Średnia godzin wg dnia tygodnia", "Dzień tygodnia", "Średnia liczba godzin") %>%
      layout(
        barmode = 'group', 
        xaxis = list(tickformat = ""),
        margin = list(t = 60, b = 50)
      ) 
  })
  
  output$mac_p3 <- renderPlotly({
    df <- df_mac_filtered()
    req(nrow(df) > 0)
    
    df_plot <- df %>% 
      group_by(App) %>% 
      summarise(Hours = round(sum(Czas_Sekundy) / 3600, 2)) %>%
      slice_max(Hours, n = 10)
    
    plot_ly(df_plot, x = ~Hours, y = ~reorder(App, Hours), type = 'bar', orientation = 'h',
            marker = list(color = cols$mac_blue),
            hovertemplate = "Aplikacja: %{y}<br>Suma: %{x} godz.<extra></extra>") %>% 
      clean_layout("Top 10 Aplikacji", "Liczba godzin (łącznie)", "") %>%
      layout(
        yaxis = list(
          title = list(standoff = 20),
          automargin = TRUE 
        ),
        margin = list(l = 120, r = 20, t = 60, b = 50) 
      )
  })
  
  
  output$mac_p4 <- renderPlotly({
    df <- df_mac_filtered()
    req(nrow(df) > 0)
    
    heat_data <- df %>% 
      group_by(Wday, Hour) %>%
      summarise(Godziny = round(sum(Czas_Sekundy) / 3600, 3), .groups = 'drop') %>%
      complete(Wday, Hour = 0:23, fill = list(Godziny = 0))
    
    plot_ly(
      heat_data, 
      x = ~Hour, 
      y = ~Wday, 
      z = ~Godziny, 
      type = "heatmap", 
      colors = cols$mac_heat, 
      showscale = TRUE, 
      hovertemplate = "Godzina: %{x}<br>Dzień: %{y}<br>Godziny: %{z}<extra></extra>"
    ) %>%
      clean_layout("Aktywność w tygodniu", "Godzina", "Dzień tygodnia") %>%
      layout(
        xaxis = list(dtick = 2, title = list(text = "Godzina"), tickformat = ""),
        yaxis = list(title = list(text = "Dzień tygodnia", standoff = 40)),
        margin = list(l = 150)
      )
  })
  
  # WYKRESY CHATGPT
  

  output$chat_p1 <- renderPlotly({
    df <- df_chat_filtered()
    req(nrow(df) > 0)
    user_stats <- df %>% 
      filter(role == "user") %>% 
      group_by(osoba, date) %>% 
      summarise(n_queries = n(), .groups = "drop")
    
    plot_ly(user_stats, x = ~date, y = ~n_queries, color = ~osoba, colors = user_colors, type = 'scatter', mode = 'lines') %>%
      clean_layout("Historia promptów", "Data", "Liczba zapytań") %>%
      layout(xaxis = list(rangeslider = list(visible = FALSE)))
  })
  
  
  output$chat_p2 <- renderPlotly({
    df <- df_chat_filtered()
    req(nrow(df) > 0)
    word_stats <- df %>% 
      mutate(cnt = str_count(text, "\\w+")) %>% 
      group_by(osoba, date) %>% 
      summarise(total = sum(cnt, na.rm=T), .groups = "drop")
    
    plot_ly(word_stats, x = ~date, y = ~total, color = ~osoba, colors = user_colors, type = 'scatter', mode = 'lines') %>%
      clean_layout("Wygenerowane słowa", "Data", "Liczba słów")
  })
  
  output$chat_p3 <- renderPlotly({
    df <- df_chat_filtered()
    req(nrow(df) > 0)
    
    daily_stats <- df %>%
      filter(role == "user") %>%
      mutate(
        date = as.Date(time),
        wd = wday(time, label = TRUE, abbr = FALSE, locale = "pl_PL")
      ) %>%
      group_by(osoba, date, wd) %>%
      summarise(n = n(), .groups = "drop") %>%
      mutate(wd = factor(wd, levels = rev(c("poniedziałek", "wtorek", "środa", "czwartek", 
                                            "piątek", "sobota", "niedziela"))))
    
    plot_ly(
      daily_stats,
      y = ~wd,
      x = ~n,
      color = ~osoba,
      colors = user_colors,
      type = "box",
      orientation = "h"
    ) %>%
      clean_layout("Rozkład naszych zapytań w ciągu tygodnia", "Liczba zapytań (rozkład dzienny)", "") %>%
      layout(
        boxmode = "group",
        yaxis = list(title = ""), 
        margin = list(t = 70, b = 60, l = 120, r = 20),
        legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.15)
      )
  })
  
  # WYKRESY YOUTUBE
  output$yt_p1 <- renderPlotly({
    df <- df_yt_filtered()
    req(nrow(df) > 0)
    top15 <- df %>% 
      filter(!str_detect(Autor, "Nieznany")) %>% 
      count(Autor) %>% slice_max(n, n = 15)
    
    plot_ly(top15, x = ~n, y = ~reorder(Autor, n), type = 'bar', orientation = 'h',
            marker = list(color = ~n, colorscale = cols$yt_grad),
            text = ~n, textposition = 'auto') %>%
      clean_layout("Top 15 Kanałów", "Liczba obejrzanych filmów", "Kanał YouTube") %>%
      layout(
        xaxis = list(showticklabels = TRUE, tickformat = ""),
        yaxis = list(title = list(text = "Kanał YouTube", standoff = 40)),
        margin = list(l = 150)
      ) %>%
      config(displayModeBar = FALSE)
  })
  
  
  output$yt_p2 <- renderPlotly({
    df <- df_yt_filtered()
    req(nrow(df) > 0)
    hourly <- df %>% group_by(osoba) %>% count(Hour_Num)
    
    plot_ly(hourly, x = ~Hour_Num, y = ~n, color = ~osoba, colors = user_colors, type = 'scatter', mode = 'lines',
            line = list(shape = "spline", width = 3)) %>%
      clean_layout("Dobowy rytm YouTube", "Godzina", "Liczba filmów") %>%
      layout(
        xaxis = list(title = list(text = "Godzina"), dtick = 2, tickformat = ""),
        yaxis = list(
          title = list(
            text = "Liczba filmów",
            standoff = 40
          )
        ),
        margin = list(l = 100)
      )
  })
  
  output$yt_p3 <- renderPlotly({
    df <- df_yt_filtered()
    req(nrow(df) > 0)
    heat <- df %>% 
      count(Dzien_Tygodnia, Hour_Num) %>% 
      complete(Dzien_Tygodnia, Hour_Num=0:23, fill=list(n=0))
    
    plot_ly(
      data = heat, 
      x = ~Hour_Num, 
      y = ~Dzien_Tygodnia, 
      z = ~n, 
      type = "heatmap",
      colors = cols$yt_grad, 
      xgap = 1, 
      ygap = 1,
      hovertemplate = "Dzień: %{y}<br>Godzina: %{x}:00<br>Liczba filmów: %{z}<extra></extra>"
    ) %>%
      colorbar(title = list(text = "Liczba filmów", font = list(size = 12))) %>%
      clean_layout("Intensywność oglądania", "Godzina", "Dzień tygodnia") %>%
      layout(
        xaxis = list(dtick = 2, title = list(text = "Godzina")),
        yaxis = list(title = list(text = "Dzień tygodnia", standoff = 40)),
        margin = list(l = 100, r = 20, t = 60, b = 50)
      )
  })
}

shinyApp(ui = ui, server = server)
