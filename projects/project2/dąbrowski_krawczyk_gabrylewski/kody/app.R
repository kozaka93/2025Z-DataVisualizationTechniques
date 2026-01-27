library(shiny)
library(plotly)
library(dplyr)
library(tidyr)
library(lubridate)
library(readr)
library(bslib)
library(thematic)
library(reticulate)
# reticulate::py_install(c("pandas", "plotly"), envname = "r-reticulate")

try(
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path)),
  silent = TRUE
)
cat("WD:", getwd(), "\n")
cat("FILES:", list.files(), "\n")

thematic_shiny(font = "auto")

theme_app <- bs_theme(
  version = 5,
  bootswatch = "minty",
  base_font = font_google("Inter"),
  fg = "#0f172a",
  bg = "#f5fbf7",
  primary = "#16a34a"
)

css_app <- "
:root{
  --bg:#f5fbf7;
  --panel:#ffffff;
  --fg:#0f172a;
  --muted:rgba(15,23,42,0.72);
  --border:rgba(15,23,42,0.10);
  --accent:#16a34a;
  --accent2:#22c55e;
  --shadow:0 10px 28px rgba(2,6,23,0.10);
}
html, body { background-color:var(--bg) !important; color:var(--fg) !important; }
* { color:var(--fg); }
.small-muted { color:var(--muted) !important; font-size:.95rem; }
h1, h2, h3, h4, h5, h6, p, span, div, label, .form-label, .help-block, .shiny-input-container, .control-label { color:var(--fg) !important; }
a { color:var(--accent) !important; }
.sidebar { border-right:1px solid var(--border); background:rgba(255,255,255,0.65); backdrop-filter: blur(8px); }
.nav-link { color:var(--fg) !important; }
.nav-link.active {
  background: rgba(34,197,94,0.12) !important;
  border:1px solid rgba(34,197,94,0.35) !important;
  box-shadow: 0 0 0 2px rgba(34,197,94,0.10) inset;
}
.bslib-card {
  border-radius: 16px !important;
  border:1px solid var(--border) !important;
  background: var(--panel) !important;
  box-shadow: var(--shadow);
}
.card-header {
  border-bottom:1px solid var(--border) !important;
  font-weight: 900 !important;
  letter-spacing: .6px !important;
}
h1.page-title{
  text-align:center;
  text-transform:uppercase;
  letter-spacing:6px;
  font-weight:300;
  margin:22px 0 10px 0;
  color: rgba(2,6,23,0.86) !important;
}
.neon-border{ border-bottom:2px solid rgba(34,197,94,0.40) !important; }
.legend-dot{ font-weight:900; }
.kpi-box{
  background: rgba(34,197,94,0.08);
  border: 1px solid rgba(34,197,94,0.22);
  border-radius: 14px;
  padding: 12px 14px;
}
.kpi-title{
  font-size:.85rem;
  color: rgba(15,23,42,0.70) !important;
  letter-spacing:1px;
  text-transform:uppercase;
}
.kpi-value{ font-size:1.6rem; font-weight:950; }
.accent-green{ color: var(--accent) !important; }
.view{ animation: fadeSlide 220ms ease-out; }
@keyframes fadeSlide{ from{opacity:0; transform:translateY(10px);} to{opacity:1; transform:translateY(0);} }
.selectize-input, .selectize-dropdown, .form-control { color:var(--fg) !important; }
.irs-bar { background: rgba(34,197,94,0.65) !important; border-color: rgba(34,197,94,0.65) !important; }
.irs-handle { border-color: rgba(34,197,94,0.65) !important; }
"

apply_plotly_light <- function(p, x_title = NULL, y_title = NULL) {
  p %>% layout(
    font = list(color = "rgba(15,23,42,0.92)"),
    paper_bgcolor = "rgba(0,0,0,0)",
    plot_bgcolor = "rgba(0,0,0,0)",
    hoverlabel = list(
      bgcolor = "rgba(255,255,255,0.98)",
      bordercolor = "rgba(15,23,42,0.20)",
      font = list(color = "rgba(15,23,42,0.95)")
    ),
    xaxis = list(
      title = if (is.null(x_title)) list(text = "") else list(text = x_title),
      tickfont = list(color = "rgba(15,23,42,0.86)"),
      titlefont = list(color = "rgba(15,23,42,0.92)"),
      gridcolor = "rgba(15,23,42,0.08)",
      zeroline = FALSE,
      linecolor = "rgba(15,23,42,0.18)"
    ),
    yaxis = list(
      title = if (is.null(y_title)) list(text = "") else list(text = y_title),
      tickfont = list(color = "rgba(15,23,42,0.86)"),
      titlefont = list(color = "rgba(15,23,42,0.92)"),
      gridcolor = "rgba(15,23,42,0.08)",
      zeroline = FALSE,
      linecolor = "rgba(15,23,42,0.18)"
    )
  )
}

river_iframe_css <- "
<style>
html, body { margin:0; padding:0; background:transparent !important; color: rgba(15,23,42,0.92) !important; }
.js-plotly-plot .plotly .xtick text,
.js-plotly-plot .plotly .ytick text,
.js-plotly-plot .plotly .gtitle,
.js-plotly-plot .plotly text { fill: rgba(15,23,42,0.88) !important; }
.js-plotly-plot .plotly .xaxis .title,
.js-plotly-plot .plotly .yaxis .title { fill: rgba(15,23,42,0.92) !important; }
</style>
"

paths <- c(
  "Krzysiek" = "Dane_Krzysiek.csv",
  "Gustaw"   = "Dane_Gustaw.csv",
  "Łukasz"   = "Dane_Lukasz.csv"
)

load_person_csv <- function(path, person) {
  df <- read_csv(path, show_col_types = FALSE)
  df$Person <- person
  df
}

df_raw_all <- bind_rows(
  load_person_csv(paths["Krzysiek"], "Krzysiek"),
  load_person_csv(paths["Gustaw"], "Gustaw"),
  load_person_csv(paths["Łukasz"], "Łukasz")
)

df_raw_all_safe <- df_raw_all
colnames(df_raw_all_safe) <- make.names(colnames(df_raw_all_safe))
persons <- sort(unique(df_raw_all$Person))


py_ok <- tryCatch({
  source_python("RzekaCzasu.py")
  exists("generuj_rzeke", mode = "function")
  })


time_to_extended_hours <- function(time_str) {
  hms_val <- hms(time_str)
  dec_hour <- hour(hms_val) + minute(hms_val) / 60
  ifelse(dec_hour < 10, dec_hour + 24, dec_hour)
}

interval_data <- df_raw_all %>%
  mutate(Date = as.Date(Date)) %>%
  arrange(Person, Date) %>%
  group_by(Person) %>%
  mutate(
    Wake_Time_Raw = Sleep_end,
    Wake_Num = hour(hms(Sleep_end)) + minute(hms(Sleep_end)) / 60,
    Next_Sleep_Start_Raw = lead(Sleep_start),
    Next_Sleep_Num = time_to_extended_hours(lead(Sleep_start)),
    Awake_Duration = Next_Sleep_Num - Wake_Num
  ) %>%
  ungroup() %>%
  filter(!is.na(Awake_Duration)) %>%
  mutate(
    Is_Deprived = Awake_Duration > 18,
    Status = ifelse(Is_Deprived, "Deprywacja (>18h)", "Norma"),
    Tooltip = paste0(
      "<b>", Person, "</b><br>",
      "Data: ", Date, "<br>",
      "Pobudka: ", Wake_Time_Raw, "<br>",
      "Pójście spać: ", Next_Sleep_Start_Raw, "<br>",
      "Czas czuwania: <b>", round(Awake_Duration, 1), " h</b>"
    )
  )

radar_summary <- df_raw_all_safe %>%
  rowwise() %>%
  mutate(
    Steps_val = if ("Steps" %in% names(.)) Steps else 0,
    Sleep_h = if ("Sleep_time.s." %in% names(.)) Sleep_time.s. / 3600 else 0,
    Comp_h = if ("Comp_time.s." %in% names(.)) Comp_time.s. / 3600 else 0,
    Phone_h = if ("Phone_time.s." %in% names(.)) Phone_time.s. / 3600 else 0,
    Social_h = if ("Social_media.s." %in% names(.)) Social_media.s. / 3600 else 0,
    Games_h = if ("Games.s." %in% names(.)) Games.s. / 3600 else 0,
    Komputer_h = max(0, Comp_h - Social_h - Games_h)
  ) %>%
  ungroup() %>%
  group_by(Person) %>%
  summarise(
    Kroki = mean(Steps_val, na.rm = TRUE),
    Sen = mean(Sleep_h, na.rm = TRUE),
    Komputer = mean(Komputer_h, na.rm = TRUE),
    Gry = mean(Games_h, na.rm = TRUE),
    Social = mean(Social_h, na.rm = TRUE),
    Telefon = mean(Phone_h, na.rm = TRUE),
    .groups = "drop"
  )

radar_normalized <- radar_summary %>%
  mutate(across(c(Kroki, Sen, Komputer, Gry, Social, Telefon), ~ .x / max(.x, na.rm = TRUE) * 10))

colors_db <- list(
  "Gustaw"   = list(hex = "#16a34a", rgba = "rgba(22, 163, 74, 0.20)"),
  "Krzysiek" = list(hex = "#059669", rgba = "rgba(5, 150, 105, 0.20)"),
  "Łukasz"   = list(hex = "#0ea5e9", rgba = "rgba(14, 165, 233, 0.18)")
)

race_data <- df_raw_all %>%
  mutate(
    Date = as.Date(Date),
    Steps = as.numeric(Steps),
    Sleep_h = (`Sleep_time[s]` / 3600),
    Screen_h = ((`Comp_time[s]` + `Phone_time[s]`) / 3600)
  ) %>%
  select(Date, Person, Steps, Sleep_h, Screen_h)

common_dates <- race_data %>% count(Date) %>% filter(n == length(persons)) %>% pull(Date)

race_data <- race_data %>%
  filter(Date %in% common_dates) %>%
  arrange(Date) %>%
  group_by(Person) %>%
  mutate(
    cum_Steps = cumsum(Steps),
    cum_Sleep = cumsum(Sleep_h),
    cum_Screen = cumsum(Screen_h)
  ) %>%
  ungroup()

home_stats <- df_raw_all_safe %>%
  mutate(
    Steps_val = if ("Steps" %in% names(.)) Steps else NA_real_,
    Sleep_h = if ("Sleep_time.s." %in% names(.)) Sleep_time.s. / 3600 else if ("Sleep_time.s" %in% names(.)) Sleep_time.s / 3600 else NA_real_,
    Phone_h = if ("Phone_time.s." %in% names(.)) Phone_time.s. / 3600 else if ("Phone_time.s" %in% names(.)) Phone_time.s / 3600 else NA_real_,
    Comp_h = if ("Comp_time.s." %in% names(.)) Comp_time.s. / 3600 else if ("Comp_time.s" %in% names(.)) Comp_time.s / 3600 else NA_real_,
    Social_h = if ("Social_media.s." %in% names(.)) Social_media.s. / 3600 else if ("Social_media.s" %in% names(.)) Social_media.s / 3600 else NA_real_,
    Games_h = if ("Games.s." %in% names(.)) Games.s. / 3600 else if ("Games.s" %in% names(.)) Games.s / 3600 else NA_real_
  ) %>%
  group_by(Person) %>%
  summarise(
    Dni = n(),
    Śr_kroki = mean(Steps_val, na.rm = TRUE),
    Śr_sen_h = mean(Sleep_h, na.rm = TRUE),
    Śr_ekran_h = mean(Phone_h + Comp_h, na.rm = TRUE),
    Śr_social_h = mean(Social_h, na.rm = TRUE),
    Śr_gry_h = mean(Games_h, na.rm = TRUE),
    .groups = "drop"
  )

desc_home <- "Aplikacja prezentuje interaktywny wgląd w osobiste dane o aktywności fizycznej, czasie ekranowym i odpoczynku. Analiza skupia się na relacjach między ruchem a użytkowaniem technologii, uwzględniając statystyki kroków, snu, mediów społecznościowych oraz gier mobilnych. Dane pokazują dynamikę zmian i różnice w nawykach na przestrzeni całego okresu pomiarowego."
desc_race <- "Animacja przedstawia przyrost wybranych statystyk w czasie. Pozwala śledzić skumulowaną sumę kroków, czasu przed ekranem lub snu dla każdego z nas dzień po dniu. Dzięki wizualizacji możemy dowiedzieć się który z nas był liderem w danej dziedzinie od początku zbierania danych, do danego dnia."
desc_river <- "Wizualizacja to wykres strumieniowy przedstawiający dobowy podział czasu na sen, czas z telefonem, komputerem oraz pozostałe aktywności. Animacja obrazuje zmiany w strukturze dnia wybranej osoby, wyświetlając dane w ruchomym, 4-dniowym oknie czasowym."
desc_radar <- "Wykresy pokazują profile aktywności przedstawione na wykresach radarowych w skali od 0 do 10. Wartość maksymalna przypisana jest osobie z najwyższym wynikiem w danej kategorii, co pozwala na porównanie naszych nawyków i stylów życia."
desc_awake <- "Analiza dobowego czasu aktywności od momentu pobudki do faktycznego pójścia spać. Wykres automatycznie wyróżnia kolorem czerwonym przypadki deprywacji snu (powyżej 18h na nogach) i wskazuje najdłuższe maratony aktywności dla każdego z nas."

ui <- page_sidebar(
  theme = theme_app,
  title = "Analiza Aktywności",
  header = tagList(tags$style(HTML(css_app))),
  sidebar = sidebar(
    width = 380,
    navset_pill_list(
      id = "page",
      nav_panel("Ekran główny", value = "home"),
      nav_panel("Czuwanie", value = "awake"),
      nav_panel("Rzeka czasu", value = "river"),
      nav_panel("Statystyki postaci", value = "radar"),
      nav_panel("Wyścig", value = "race")
    ),
    hr(),
    conditionalPanel(
      condition = "input.page === 'home'",
      selectInput("home_user", "Użytkownik:", choices = persons)
    ),
    conditionalPanel(
      condition = "input.page === 'awake'",
      selectInput("awake_user", "Użytkownik:", choices = persons),
      uiOutput("awake_marathon"),
      hr(),
      div(tags$span(class = "legend-dot", style = "color:#16a34a;", "● Norma (< 18h)")),
      div(tags$span(class = "legend-dot", style = "color:#ef4444;", "● Deprywacja (> 18h)"))
    ),
    conditionalPanel(
      condition = "input.page === 'river'",
      selectInput("river_user", "Użytkownik:", choices = persons)
    ),
    conditionalPanel(
      condition = "input.page === 'race'",
      selectInput(
        "race_category",
        "Wybierz dane:",
        choices = c("Kroki" = "cum_Steps", "Sen (godziny)" = "cum_Sleep", "Ekran (godziny)" = "cum_Screen")
      )
    )
  ),
  uiOutput("main_view")
)

server <- function(input, output, session) {
  
  output$main_view <- renderUI({
    req(input$page)
    
    switch(
      input$page,
      
      "home" = div(
        class = "view",
        tags$h1(class = "page-title", "Ekran główny"),
        card(
          card_header("Opis"),
          card_body(div(class = "small-muted", desc_home))
        ),
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header("Podsumowanie użytkownika"),
            card_body(uiOutput("home_kpi"))
          ),
          card(
            card_header("Mapa dashboardu"),
            card_body(
              div(class = "small-muted",
                  tags$ul(
                    tags$li("Czuwanie: maratony aktywności i deprywacja snu"),
                    tags$li("Rzeka czasu: animacja zmiany struktury doby w oknie 4-dniowym"),
                    tags$li("Statystyki postaci: porównanie statystyk między użytkownikami"),
                    tags$li("Wyścig: wizualizacja porównawcza dystrybuant wybranej statystyki")
                  )
              )
            )
          )
        )
      ),
      
      "awake" = div(
        class = "view",
        tags$h1(class = "page-title", "Czuwanie"),
        card(
          card_header("Opis"),
          card_body(div(class = "small-muted", desc_awake))
        ),
        card(
          full_screen = TRUE,
          card_header(tags$div(class = "neon-border", "Czas aktywności (od pobudki do zaśnięcia)")),
          plotlyOutput("intervalPlot", height = "680px")
        )
      ),
      
      "river" = div(
        class = "view",
        tags$h1(class = "page-title", "Rzeka czasu"),
        card(
          card_header("Opis"),
          card_body(div(class = "small-muted", desc_river))
        ),
        card(
          full_screen = TRUE,
          card_header(textOutput("river_title")),
          htmlOutput("river_iframe", container = div, class = "river-container")
        )
      ),
      
      "radar" = div(
        class = "view",
        tags$h1(class = "page-title", "Statystyki postaci"),
        card(
          card_header("Opis"),
          card_body(div(class = "small-muted", desc_radar))
        ),
        layout_columns(
          col_widths = c(4, 4, 4),
          height = "680px",
          card(
            card_header("Gustaw", style = "color:#16a34a; border-bottom:2px solid rgba(22,163,74,0.55);"),
            plotlyOutput("plot_Gustaw", height = "100%")
          ),
          card(
            card_header("Krzysiek", style = "color:#059669; border-bottom:2px solid rgba(5,150,105,0.55);"),
            plotlyOutput("plot_Krzysiek", height = "100%")
          ),
          card(
            card_header("Łukasz", style = "color:#0ea5e9; border-bottom:2px solid rgba(14,165,233,0.55);"),
            plotlyOutput("plot_Lukasz", height = "100%")
          )
        )
      ),
      
      "race" = div(
        class = "view",
        tags$h1(class = "page-title", "Wyścig"),
        card(
          card_header("Opis"),
          card_body(div(class = "small-muted", desc_race))
        ),
        card(
          full_screen = TRUE,
          card_header("Wyścig"),
          plotlyOutput("racePlot", height = "680px")
        )
      )
    )
  })
  
  output$home_kpi <- renderUI({
    req(input$home_user)
    s <- home_stats %>% filter(Person == input$home_user)
    if (nrow(s) == 0) return(div(class = "small-muted", "Brak danych."))
    layout_columns(
      col_widths = c(6, 6),
      value_box("Dni danych", as.integer(s$Dni)),
      value_box("Śr. kroki", format(round(s$Śr_kroki, 0), big.mark = " ")),
      value_box("Śr. sen", paste0(round(s$Śr_sen_h, 1), " h")),
      value_box("Śr. ekran", paste0(round(s$Śr_ekran_h, 1), " h"))
    )
  })
  
  awake_user_data <- reactive({
    req(input$awake_user)
    interval_data %>% filter(Person == input$awake_user)
  })
  
  output$awake_marathon <- renderUI({
    df <- awake_user_data()
    if (nrow(df) == 0) return(NULL)
    max_awake <- max(df$Awake_Duration, na.rm = TRUE)
    max_date <- df$Date[which.max(df$Awake_Duration)][1]
    div(
      class = "kpi-box",
      div(class = "kpi-title", "Najdłuższy maraton:", paste0(round(max_awake, 1), " h")),
      div(class = "small-muted", paste("Dnia:", max_date))
    )
  })
  
  output$intervalPlot <- renderPlotly({
    df <- awake_user_data()
    req(nrow(df) > 0)
    color_palette <- c("Norma" = "#16a34a", "Deprywacja (>18h)" = "#ef4444")
    
    p <- plot_ly(df) %>%
      add_segments(
        x = ~Date, xend = ~Date,
        y = ~Wake_Num, yend = ~Next_Sleep_Num,
        split = ~Status,
        color = ~Status,
        colors = color_palette,
        line = list(width = 4),
        hoverinfo = "none",
        showlegend = FALSE
      ) %>%
      add_trace(
        x = ~Date, y = ~Wake_Num,
        type = "scatter", mode = "markers",
        marker = list(symbol = "circle-open", size = 8, color = "rgba(15,23,42,0.92)", line = list(width = 2, color = "rgba(255,255,255,0.70)")),
        text = ~Tooltip, hoverinfo = "text",
        showlegend = FALSE
      ) %>%
      add_trace(
        x = ~Date, y = ~Next_Sleep_Num,
        type = "scatter", mode = "markers",
        split = ~Status,
        color = ~Status,
        colors = color_palette,
        marker = list(symbol = "circle", size = 10),
        text = ~Tooltip, hoverinfo = "text",
        showlegend = FALSE
      ) %>%
      layout(
        yaxis = list(
          title = list(text = "Godzina dnia", standoff = 30),
          tickmode = "array",
          tickvals = seq(6, 30, by = 2),
          ticktext = c("06:00","08:00","10:00","12:00","14:00","16:00","18:00","20:00","22:00","00:00","02:00","04:00","06:00"),
          gridcolor = "rgba(15,23,42,0.08)",
          linecolor = "rgba(15,23,42,0.18)"
        ),
        margin = list(l = 110, r = 30, t = 45, b = 55)
      ) %>%
      config(displayModeBar = FALSE)
    
    apply_plotly_light(p, x_title = "Data", y_title = "Godzina dnia")
  })
  
  output$river_title <- renderText({
    req(input$river_user)
    paste("Struktura doby -", input$river_user)
  })
  
  output$river_iframe <- renderUI({
    req(input$river_user)
    html <- tryCatch(generuj_rzeke(input$river_user))
    tags$iframe(
      srcdoc = paste0(river_iframe_css, html),
      width = "100%",
      height = "720px",
      style = "border:none; background: transparent;"
    )
  })
  
  create_radar <- function(person_name) {
    stats <- radar_normalized %>% filter(Person == person_name)
    raw_stats <- radar_summary %>% filter(Person == person_name)
    if (nrow(stats) == 0) return(NULL)
    
    col <- if (person_name %in% names(colors_db)) colors_db[[person_name]] else list(hex = "#16a34a", rgba = "rgba(22,163,74,0.18)")
    categories <- c("Kroki", "Sen", "Komputer", "Gry", "Social", "Telefon")
    values_norm <- c(stats$Kroki, stats$Sen, stats$Komputer, stats$Gry, stats$Social, stats$Telefon)
    values_raw <- c(raw_stats$Kroki, raw_stats$Sen, raw_stats$Komputer, raw_stats$Gry, raw_stats$Social, raw_stats$Telefon)
    categories <- c(categories, categories[1])
    values_norm <- c(values_norm, values_norm[1])
    values_raw <- c(values_raw, values_raw[1])
    
    tooltip_text <- sapply(seq_along(values_raw), function(i) {
      cat_name <- categories[i]
      val_r <- values_raw[i]
      val_n <- values_norm[i]
      unit <- if (cat_name == "Kroki") "" else "h"
      val_fmt <- if (cat_name == "Kroki") round(val_r, 0) else round(val_r, 1)
      paste0(cat_name, "<br>Wynik: ", round(val_n, 1), "/10<br>Średnia: ", val_fmt, unit)
    })
    
    p <- plot_ly(
      type = "scatterpolar",
      r = values_norm,
      theta = categories,
      fill = "toself",
      mode = "lines+markers",
      line = list(color = col$hex, width = 3),
      fillcolor = col$rgba,
      marker = list(color = "rgba(15,23,42,0.95)", size = 5),
      hoverinfo = "text",
      text = tooltip_text
    ) %>%
      layout(
        polar = list(
          bgcolor = "rgba(0,0,0,0)",
          radialaxis = list(
            visible = TRUE,
            range = c(0, 10),
            showticklabels = FALSE,
            gridcolor = "rgba(15,23,42,0.10)",
            linecolor = "rgba(15,23,42,0.18)"
          ),
          angularaxis = list(
            tickfont = list(size = 12, color = "rgba(15,23,42,0.90)"),
            gridcolor = "rgba(15,23,42,0.10)",
            linecolor = "rgba(15,23,42,0.22)"
          )
        ),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        showlegend = FALSE,
        margin = list(t = 35, b = 35, l = 35, r = 35)
      ) %>%
      config(displayModeBar = FALSE)
    
    apply_plotly_light(p)
  }
  
  output$plot_Gustaw <- renderPlotly({ create_radar("Gustaw") })
  output$plot_Krzysiek <- renderPlotly({ create_radar("Krzysiek") })
  output$plot_Lukasz <- renderPlotly({ create_radar("Łukasz") })
  
  output$racePlot <- renderPlotly({
    req(input$race_category)
    plot_data <- race_data %>%
      rename(Value = !!sym(input$race_category)) %>%
      group_by(Date) %>%
      mutate(rank = rank(Value, ties.method = "first")) %>%
      ungroup()
    
    colors <- c("Krzysiek" = "#059669", "Gustaw" = "#16a34a", "Łukasz" = "#0ea5e9")
    
    p <- plot_ly(
      data = plot_data,
      x = ~Value,
      y = ~rank,
      color = ~Person,
      colors = colors,
      frame = ~as.character(Date),
      text = ~Person,
      textposition = "inside",
      insidetextfont = list(color = "white", size = 15),
      type = "bar",
      orientation = "h",
      hoverinfo = "x",
      marker = list(opacity = 0.75, line = list(color = "rgba(255,255,255,0.85)", width = 1))
    ) %>%
      layout(
        xaxis = list(title = "", showgrid = TRUE, gridcolor = "rgba(15,23,42,0.08)", zeroline = FALSE, linecolor = "rgba(15,23,42,0.18)"),
        yaxis = list(title = "", showticklabels = FALSE, range = c(0.5, 3.5), autorange = FALSE, showgrid = FALSE),
        margin = list(l = 20, r = 70, t = 45, b = 125),
        showlegend = FALSE,
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      ) %>%
      animation_opts(frame = 250, transition = 250, easing = "linear", redraw = FALSE) %>%
      animation_button(label = "Start", x = 0, y = -0.02, xanchor = "left", yanchor = "top") %>%
      animation_slider(currentvalue = list(prefix = "Dzień: ", font = list(size = 14, color = "rgba(15,23,42,0.70)")), pad = list(t = 80)) %>%
      config(displayModeBar = FALSE)
    
    apply_plotly_light(p)
  })
}

shinyApp(ui, server)
