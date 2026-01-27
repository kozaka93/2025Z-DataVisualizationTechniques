library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(jsonlite)
library(packcircles)
library(ggiraph)
library(stringi)
library(shinycssloaders)
library(tidyr)
library(bslib)
library(shinyWidgets)

styl_mojego_spotify <- function() {
  theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#181818", color = NA),  
      panel.background = element_rect(fill = "#181818", color = NA), 
      text = element_text(color = "#FFFFFF"),
      axis.text = element_text(color = "#B3B3B3"),
      axis.title = element_text(color = "#FFFFFF", face = "bold"),
      panel.grid.major = element_line(color = "#333333"),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    )
}

styl_dla_bablekow <- function() {
  theme_void() + 
    theme(
      plot.background = element_rect(fill = "#181818", color = NA),
      panel.background = element_rect(fill = "#181818", color = NA),
      panel.grid = element_blank(), 
      axis.text = element_blank(),
      axis.title = element_blank(),
      legend.position = "none"
    )
}

zrob_ciemne_plotly <- function(wykres) {
  wykres %>% layout(
    plot_bgcolor = "#181818",
    paper_bgcolor = "#181818",
    font = list(color = "#FFFFFF"),
    xaxis = list(gridcolor = "#333333"),
    yaxis = list(gridcolor = "#333333")
  )
}

LISTA_PLIKOW_KONFIG <- list(
  "Jakub"   = "dane_Jakub.json",
  "Julia"   = "dane_Julia.json",
  "Wioletta"        = "dane_Wioletta.json"
)

wczytaj_pliki_spotify <- function(wzorzec_nazwy) {
  znalezione_pliki <- list.files(pattern = wzorzec_nazwy, full.names = TRUE)
  
  if (length(znalezione_pliki) == 0 && file.exists(wzorzec_nazwy)) znalezione_pliki <- wzorzec_nazwy
  if (length(znalezione_pliki) == 0) return(NULL)
  
  tabela_tymczasowa <- data.frame()
  
  tryCatch({
    lista_ramek <- lapply(znalezione_pliki, function(plik) fromJSON(plik, flatten = TRUE))
    tabela_tymczasowa <- bind_rows(lista_ramek)
  }, error = function(blad) return(NULL))
  
  if (nrow(tabela_tymczasowa) == 0) return(NULL)
  
  dane_gotowe <- tabela_tymczasowa %>%
    as_tibble() %>%
    mutate(
      datetime = ymd_hms(ts, tz = "UTC"),
      date_col = as.Date(datetime),
      artist_name = if("master_metadata_album_artist_name" %in% names(.)) master_metadata_album_artist_name else "Nieznany",
      album_name  = if("master_metadata_album_album_name" %in% names(.)) master_metadata_album_album_name else "Nieznany Album",
      track_name  = if("master_metadata_track_name" %in% names(.)) master_metadata_track_name else "Nieznany Utwór",
      ms_played   = if("ms_played" %in% names(.)) ms_played else 0,
      skipped     = if("skipped" %in% names(.)) skipped else NA 
    ) %>%
    mutate(
      artist_name = ifelse(is.na(artist_name) | artist_name == "", "Podcast / Nieznany", artist_name),
      minutes_played = ms_played / 60000 
    ) %>%
    filter(ms_played > 0) 
  
  return(dane_gotowe)
}

motyw_spotify <- bs_theme(
  bg = "#121212",            
  fg = "#FFFFFF",            
  primary = "#1DB954",       
  "card-bg" = "#181818"      
)

ui <- page_sidebar(
  theme = motyw_spotify,
  title = div(
    style="display:flex; align-items:center; gap:10px;", 
    div(style="width:20px; height:20px; background:#1DB954; border-radius:50%;"), 
    span("Music Pulse", style="font-weight:bold;") 
  ),
  
  sidebar = sidebar(
    width = 300,
    bg = "#000000",
    
    h6("BIBLIOTEKA", style = "color: #B3B3B3; font-weight: bold; font-size: 0.8rem; letter-spacing: 1px; margin-bottom: 15px;"),
    selectInput("wybor_danych", NULL, choices = names(LISTA_PLIKOW_KONFIG)),
    textOutput("status_wczytania"),
    hr(style = "border-top: 1px solid #282828;"),
    
    radioGroupButtons(
      inputId = "aktywna_zakladka",
      label = NULL,
      choices = c(
        "Heatmapa"       = "zakladka_mapa", 
        "Top Artyści"    = "zakladka_babelki", 
        "Trendy i Analiza" = "zakladka_analiza",
        "Wyścig Albumów" = "zakladka_wyscig"        
      ),
      direction = "vertical",
      status = "dark",
      width = "100%"
    ),
    
    hr(style = "border-top: 1px solid #282828;"),
    
    h6("FILTRY", style = "color: #B3B3B3; font-weight: bold; font-size: 0.8rem; letter-spacing: 1px; margin-bottom: 15px;"),
    
    conditionalPanel(
      condition = "input.aktywna_zakladka == 'zakladka_babelki' || input.aktywna_zakladka == 'zakladka_wyscig'",
      radioButtons("filtr_pomijania", "Status pominięcia:",
                   choices = c("Wszystkie" = "wszystko", 
                               "Niepominięte" = "bez_skipow", 
                               "Pominięte" = "tylko_skipy"),
                   selected = "wszystko"),
      hr(style = "border-top: 1px solid #282828; margin: 10px 0;")
    ),
    
    conditionalPanel(
      condition = "input.aktywna_zakladka == 'zakladka_mapa'",
      dateRangeInput("zakres_dat_mapa", "Zakres dat:", start = Sys.Date(), end = Sys.Date(), language = "pl"),
      sliderInput("min_czas_sluchania", "Min. czas (s):", min = 0, max = 540, value = 30),
      actionButton("przycisk_reset_mapy", "Pokaż wszystko (Reset)", class = "btn-xs", style = "margin-top: 10px; width: 100%; background-color: #333; color: white; border: none;")
    ),
    
    conditionalPanel(
      condition = "input.aktywna_zakladka == 'zakladka_babelki'",
      sliderInput("ile_top_artystow", "Top N:", min = 10, max = 50, value = 20),
      dateRangeInput("zakres_dat_babelki", "Zakres dat:", start = Sys.Date(), end = Sys.Date(), language = "pl"),
      actionButton("przycisk_rysuj_babelki", "Odśwież", class = "btn-success", style = "width: 100%; color: black; font-weight: bold;")
    ),
    
    conditionalPanel(
      condition = "input.aktywna_zakladka == 'zakladka_analiza'",
      dateRangeInput("zakres_dat_analiza", "Zakres analizy:", start = Sys.Date(), end = Sys.Date(), language = "pl")
    ),
    
    conditionalPanel(
      condition = "input.aktywna_zakladka == 'zakladka_wyscig'",
      dateRangeInput("zakres_dat_animacja", "Animacja (max 90 dni):", start = Sys.Date(), end = Sys.Date(), language = "pl"),
      sliderInput("ile_albumow_wyscig", "Liczba albumów:", min=1, max=15, value=10)
    )
  ),
  
  navset_hidden(
    id = "kontener_glowny",
    
    nav_panel_hidden("zakladka_mapa",
                     card(full_screen = TRUE, height = "95vh",
                          card_header("Rytm Dobowy (Kliknij w kratkę, aby filtrować piosenki)"), 
                          plotlyOutput("WykresMapyCiepla", height = "65%"),
                          div(style="height: 30%; overflow-y: auto; margin-top: 15px; border-top: 1px solid #333; padding-top:10px;",
                              div(style="display:flex; justify-content:space-between; align-items:center;",
                                  h6("Ulubione piosenki w tym czasie:", style="color:#1DB954; font-size: 0.9rem; margin-bottom: 5px;"),
                                  textOutput("tekst_wybranej_godziny", inline = TRUE)
                              ),
                              tableOutput("TabelaMapy")
                          )
                     )
    ),
    
    nav_panel_hidden("zakladka_babelki",
                     card(full_screen = TRUE, height = "85vh",
                          card_header("Ulubieni Artyści"),
                          girafeOutput("WykresBabelkowy", width = "100%", height = "75vh")
                     )
    ),
    
    nav_panel_hidden("zakladka_analiza",
                     card(
                       height = "250px", 
                       card_header("Rekordowe Dni"),
                       uiOutput("lista_top_dni") 
                     ),
                     br(),
                     card(
                       full_screen = TRUE,
                       card_header("Historia i Sesje"),
                       div(style="padding: 10px;", h5("Historia odtwarzania", style="color:#1DB954; margin-bottom:15px;")),
                       withSpinner(plotlyOutput("WykresHistorii", height = "300px"), type = 6, color = "#1DB954"),
                       hr(style="border-top: 1px solid #333; margin: 20px 0;"),
                       div(style="padding: 10px;", h5("Rozkład długości sesji", style="color:#1DB954; margin-bottom:15px;")),
                       withSpinner(plotlyOutput("WykresSesji", height = "300px"), type = 6, color = "#1DB954")
                     )
    ),
    
    nav_panel_hidden("zakladka_wyscig",
                     card(full_screen = TRUE, height = "85vh",
                          card_header("Wyścig Albumów"),
                          withSpinner(plotlyOutput("WykresAnimacji", height = "100%"), type = 6, color = "#1DB954")
                     )
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$aktywna_zakladka, { nav_select("kontener_glowny", input$aktywna_zakladka) })
  
  dane_zrodlowe <- reactive({
    req(input$wybor_danych)
    wzorzec <- LISTA_PLIKOW_KONFIG[[input$wybor_danych]]
    dane <- wczytaj_pliki_spotify(wzorzec)
    shiny::validate(need(!is.null(dane), paste("Nie znaleziono pliku:", wzorzec)))
    return(dane)
  })
  
  wybrana_godzina <- reactiveVal(NULL)
  
  observe({
    dane <- dane_zrodlowe()
    req(dane)
    
    start_danych <- min(dane$date_col, na.rm = TRUE)
    koniec_danych <- max(dane$date_col, na.rm = TRUE)
    
    if (is.infinite(start_danych)) start_danych <- Sys.Date()
    if (is.infinite(koniec_danych)) koniec_danych <- Sys.Date()
    
    updateDateRangeInput(session, "zakres_dat_mapa", start = start_danych, end = koniec_danych, min = start_danych, max = koniec_danych)
    updateDateRangeInput(session, "zakres_dat_babelki", start = start_danych, end = koniec_danych, min = start_danych, max = koniec_danych)
    updateDateRangeInput(session, "zakres_dat_analiza", start = start_danych, end = koniec_danych, min = start_danych, max = koniec_danych)
    
    start_animacji <- koniec_danych - 60
    if(start_animacji < start_danych) start_animacji <- start_danych
    updateDateRangeInput(session, "zakres_dat_animacja", start = start_animacji, end = koniec_danych, min = start_danych, max = koniec_danych)
    
    output$status_wczytania <- renderText({ paste0("Baza: ", format(nrow(dane), big.mark=" "), " utworów") })
    
    wybrana_godzina(NULL)
  })
  
  observeEvent(input$przycisk_reset_mapy, {
    wybrana_godzina(NULL)
  })
  
  dane_do_analizy <- reactive({
    req(input$zakres_dat_analiza)
    dane_zrodlowe() %>% 
      filter(date_col >= input$zakres_dat_analiza[1], date_col <= input$zakres_dat_analiza[2])
  })
  
  output$lista_top_dni <- renderUI({
    dane <- dane_do_analizy()
    req(nrow(dane) > 0)
    
    top3_dni <- dane %>% 
      group_by(date_col) %>% 
      summarise(minuty = sum(minutes_played)) %>% 
      arrange(desc(minuty)) %>% 
      head(3)
    
    if(nrow(top3_dni) == 0) return(div("Brak danych", style="color: #666;"))
    
    tagList(
      lapply(1:nrow(top3_dni), function(i) {
        wiersz <- top3_dni[i, ]
        data_tekst <- format(wiersz$date_col, "%d %B %Y")
        minuty_tekst <- paste0(round(wiersz$minuty), " min")
        
        div(style = "display: flex; align-items: center; justify-content: space-between; padding: 12px; border-bottom: 1px solid #282828;",
            div(style = "display: flex; align-items: center; gap: 15px;",
                div(style = "font-size: 1.2rem; font-weight: bold; color: #1DB954; width: 25px;", paste0(i, ".")),
                div(style = "font-size: 1rem; color: white;", data_tekst)
            ),
            div(style = "font-size: 1rem; font-weight: bold; color: #1DB954;", minuty_tekst)
        )
      })
    )
  })
  
  dane_filtrowane_mapa <- reactive({
    req(input$zakres_dat_mapa)
    dane_zrodlowe() %>% 
      filter(date_col >= input$zakres_dat_mapa[1], date_col <= input$zakres_dat_mapa[2]) %>%
      filter((ms_played / 1000) >= input$min_czas_sluchania)
  })
  
  output$WykresMapyCiepla <- renderPlotly({
    dane <- dane_filtrowane_mapa()
    shiny::validate(need(nrow(dane) > 0, "Brak danych."))
    
    dane_pogrupowane <- dane %>%
      mutate(dzien_tyg = wday(datetime, label = FALSE, week_start = 1), godzina = hour(datetime)) %>%
      group_by(dzien_tyg, godzina) %>% summarise(minuty = sum(minutes_played), .groups = 'drop')
    
    siatka <- expand.grid(dzien_tyg = 1:7, godzina = 0:23) %>%
      left_join(dane_pogrupowane, by = c("dzien_tyg", "godzina")) %>% mutate(minuty = ifelse(is.na(minuty), 0, minuty))
    
    nazwy_dni <- c("Pn","Wt","Śr","Cz","Pt","So","Nd")
    siatka$etykieta_dnia <- nazwy_dni[siatka$dzien_tyg]
    siatka <- siatka %>% arrange(dzien_tyg, godzina)
    
    plot_ly(
      data = siatka, x = ~etykieta_dnia, y = ~godzina, z = ~minuty, 
      type = "heatmap", source = "zrodlo_heatmapa",
      colors = colorRamp(c("#181818", "#1DB954")),
      hoverinfo = "text",
      text = ~paste0(etykieta_dnia, ", ", godzina, ":00\n", round(minuty), " min")
    ) %>%
      layout(
        plot_bgcolor = "#181818", paper_bgcolor = "#181818", font = list(color = "#FFFFFF"),
        xaxis = list(title = "Dzień Tygodnia", gridcolor = "#333333", categoryorder = "array", categoryarray = nazwy_dni),
        yaxis = list(title = "Godzina", gridcolor = "#333333", autorange = "reversed", tickmode = "linear", dtick = 2)
      )
  })
  
  observeEvent(event_data("plotly_click", source = "zrodlo_heatmapa"), {
    klikniecie <- event_data("plotly_click", source = "zrodlo_heatmapa")
    if (is.null(klikniecie)) return()
    
    klikniety_dzien <- as.character(klikniecie$x)
    kliknieta_godzina <- as.numeric(klikniecie$y)
    
    mapa_dni <- c("Pn"=1, "Wt"=2, "Śr"=3, "Cz"=4, "Pt"=5, "So"=6, "Nd"=7)
    numer_dnia <- mapa_dni[klikniety_dzien]
    
    if (!is.na(numer_dnia) && !is.na(kliknieta_godzina)) {
      wybrana_godzina(list(dzien = unname(numer_dnia), godz = kliknieta_godzina))
    }
  })
  
  output$tekst_wybranej_godziny <- renderText({
    wybor <- wybrana_godzina()
    if (is.null(wybor)) return(" (Wszystkie godziny)")
    dni_pelne <- c("Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela")
    nazwa <- if(wybor$dzien >= 1 && wybor$dzien <= 7) dni_pelne[wybor$dzien] else "Nieznany"
    paste0( nazwa, ", godz. ", sprintf("%02d:00", wybor$godz))
  })
  
  output$TabelaMapy <- renderTable({
    dane <- dane_filtrowane_mapa()
    wybor <- wybrana_godzina()
    
    if (!is.null(wybor)) {
      dane <- dane %>% 
        mutate(d = wday(datetime, label = FALSE, week_start = 1), h = hour(datetime)) %>%
        filter(d == wybor$dzien, h == wybor$godz)
    }
    
    shiny::validate(need(nrow(dane) > 0, "Brak odtworzeń w wybranym czasie."))
    
    dane %>% group_by(track_name, artist_name) %>% 
      summarise(min = round(sum(minutes_played),1), licznik = n(), .groups='drop') %>%
      arrange(desc(min)) %>% head(20) %>% 
      rename(Utwór = track_name, Artysta = artist_name, Minuty = min, `Liczba odtworzeń` = licznik)
  }, hover = TRUE, bordered = TRUE, spacing = 'xs', width = "100%")
  
  output$WykresBabelkowy <- renderGirafe({
    req(input$przycisk_rysuj_babelki)
    req(input$filtr_pomijania) 
    
    dane <- dane_zrodlowe() %>% 
      filter(date_col >= input$zakres_dat_babelki[1], date_col <= input$zakres_dat_babelki[2])
    
    if (input$filtr_pomijania == "bez_skipow") {
      dane <- dane %>% filter(is.na(skipped) | skipped == FALSE)
    } else if (input$filtr_pomijania == "tylko_skipy") {
      dane <- dane %>% filter(skipped == TRUE)
    }
    
    dane_artysci <- dane %>%
      group_by(artist_name) %>% summarise(minuty = sum(minutes_played), .groups = "drop") %>%
      filter(minuty > 1) %>% arrange(desc(minuty)) %>% slice_head(n = input$ile_top_artystow)
    
    shiny::validate(need(nrow(dane_artysci) > 0, "Brak danych dla wybranych kryteriów."))
    
    uklad_kulek <- circleProgressiveLayout(dane_artysci$minuty, sizetype = "radius")
    dane_artysci <- cbind(dane_artysci, uklad_kulek) %>% filter(!is.na(x))
    wierzcholki <- circleLayoutVertices(uklad_kulek, npoints = 50)
    
    wierzcholki$artysta <- dane_artysci$artist_name[wierzcholki$id]
    wierzcholki$minuty <- dane_artysci$minuty[wierzcholki$id]
    wierzcholki$dymek <- paste0(wierzcholki$artysta, "\n", round(wierzcholki$minuty), " min")
    
    wykres <- ggplot(wierzcholki, aes(x, y)) +
      geom_polygon_interactive(aes(group = id, fill = minuty, tooltip = dymek, data_id = artysta), colour = "#121212", size = 0.5) +
      scale_fill_gradient(low = "#1DB954", high = "#1ED760") +
      geom_text(data = dane_artysci, aes(x, y, label = ifelse(radius > max(radius)*0.15, artist_name, "")), color = "white", size = 3) +
      coord_equal() + styl_dla_bablekow()
    
    girafe(code = print(wykres), bg = "#181818", 
           options = list(
             opts_hover(css = "fill:#1ed760; stroke:white; stroke-width: 2px; cursor:pointer;"), 
             opts_tooltip(css="background-color:#000; color:#fff; padding:5px; border:1px solid #1DB954; border-radius:5px;")
           ))
  })
  
  output$WykresHistorii <- renderPlotly({
    dane <- dane_do_analizy()
    shiny::validate(need(nrow(dane) > 0, "Brak danych."))
    
    dzienne_minuty <- dane %>% group_by(date_col) %>% summarise(minuty = round(sum(minutes_played), 2))
    pelne_daty <- data.frame(date_col = seq(min(dzienne_minuty$date_col), max(dzienne_minuty$date_col), by="day"))
    dzienne_minuty <- left_join(pelne_daty, dzienne_minuty, by="date_col") %>% mutate(minuty = replace_na(minuty, 0))
    
    p <- ggplot(dzienne_minuty, aes(x = date_col, y = minuty)) +
      geom_col(fill = "#1DB954", alpha = 0.8, aes(text = paste("Data:", date_col, "\nCzas:", minuty, "min"))) +
      labs(x="Data", y="Minuty") + styl_mojego_spotify()
    
    ggplotly(p, tooltip = "text") %>% zrob_ciemne_plotly()
  })
  
  output$WykresSesji <- renderPlotly({
    dane <- dane_do_analizy()
    shiny::validate(need(nrow(dane) > 0, "Brak danych."))
    
    dzienne <- dane %>% group_by(date_col) %>% summarise(minuty = sum(minutes_played))
    histogram <- dzienne %>% mutate(zakres = floor(minuty/15)*15) %>% group_by(zakres) %>% summarise(liczba = n())
    
    p <- ggplot(histogram, aes(x = zakres, y = liczba, text = paste("Przedział:", zakres, "-", zakres+15, "min\nLiczba dni:", liczba))) +
      geom_col(fill = "#1DB954") + labs(x="Długość dziennego słuchania (min)", y="Liczba Dni") + styl_mojego_spotify()
    
    ggplotly(p, tooltip = "text") %>% zrob_ciemne_plotly()
  })
  
  output$WykresAnimacji <- renderPlotly({
    req(input$zakres_dat_animacja)
    req(input$filtr_pomijania) 
    
    start <- input$zakres_dat_animacja[1]
    koniec <- input$zakres_dat_animacja[2]
    
    if(as.numeric(koniec - start) > 90) koniec <- start + 90
    
    withProgress(message = "Generowanie wyścigu...", {
      dane <- dane_zrodlowe() %>% filter(date_col >= start, date_col <= koniec)
      
      if (input$filtr_pomijania == "bez_skipow") {
        dane <- dane %>% filter(is.na(skipped) | skipped == FALSE)
      } else if (input$filtr_pomijania == "tylko_skipy") {
        dane <- dane %>% filter(skipped == TRUE)
      }
      
      shiny::validate(need(nrow(dane)>0, "Brak danych dla wybranych kryteriów."))
      
      top_albumy <- dane %>% group_by(album_name) %>% summarise(suma = sum(minutes_played)) %>% 
        arrange(desc(suma)) %>% slice_head(n=input$ile_albumow_wyscig) %>% pull(album_name)
      
      mapa_artystow <- dane %>% filter(album_name %in% top_albumy) %>% select(album_name, artist_name) %>% distinct(album_name, .keep_all = TRUE)
      
      dane_animacji <- dane %>% filter(album_name %in% top_albumy) %>%
        group_by(date_col, album_name) %>% summarise(dzienne_min = sum(minutes_played), .groups='drop') %>%
        complete(date_col = seq.Date(start, koniec, by="day"), album_name, fill = list(dzienne_min = 0)) %>%
        group_by(album_name) %>% arrange(date_col) %>% mutate(suma_narastajaco = cumsum(dzienne_min)) %>% ungroup() %>%
        group_by(date_col) %>% 
        mutate(pozycja = rank(-suma_narastajaco, ties.method = "first"), etykieta_pozycji = paste0("#", pozycja, " ")) %>%
        ungroup() %>% filter(pozycja <= input$ile_albumow_wyscig) %>% left_join(mapa_artystow, by = "album_name")
      
      plot_ly(
        data = dane_animacji, x = ~suma_narastajaco, y = ~pozycja, frame = ~date_col, ids = ~album_name,
        type = 'bar', orientation = 'h', marker = list(color = '#1DB954'), 
        text = ~paste0(etykieta_pozycji, album_name), 
        textposition = "inside", insidetextanchor = "start", textfont = list(color = "white", size = 12),
        hovertext = ~paste0("<b>Album:</b> ", album_name, "<br><b>Artysta:</b> ", artist_name, "<br><b>Czas:</b> ", round(suma_narastajaco, 1), " min"),
        hoverinfo = "text"
      ) %>%
        layout(
          xaxis = list(title = "Suma minut", gridcolor="#333"), 
          yaxis = list(title="", autorange="reversed", showticklabels=FALSE), 
          plot_bgcolor="#181818", paper_bgcolor="#181818", font=list(color="white"),
          margin = list(l = 10, r = 10)
        ) %>%
        animation_opts(frame=200, transition=200, redraw=FALSE, easing="linear")
    })
  })
}

shinyApp(ui, server)