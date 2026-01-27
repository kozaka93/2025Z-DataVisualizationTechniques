library(shiny)
library(leaflet)
library(jsonlite)
library(stringr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plotly)

moje_kolory <- c(
  "Samochód" = "#F1C40F",
  "Pociąg podmiejski" = "#8E44AD",
  "Pociąg dalekobieżny (IC)" = "#5B2C6F",
  "Tramwaj" = "#F1C4ED",
  "Pieszo" = "#34960F",
  "Metro" = "#F1D0BF",
  "Autobus" = "#8D7470",
  "Rower" = "#2ECC71",
  "Inne" = "#7F8C8D",
  "Samolot" = "#1ABC9C",
  "Karol" = "#0505BB",
  "Karolina" = "#DD0708",
  "Ignacy" = "#2B2C2F"
)

choose_existing <- function(candidates) {
  for (p in candidates) if (file.exists(p)) return(p)
  candidates[1]
}

IGNACY_JSON   <- choose_existing(c("IgnacyTimeline.json",   "TimelineIgnacy.json"))
KAROLINA_JSON <- choose_existing(c("KarolinaTimeline.json", "TimelineKarolina.json"))
KAROL_JSON    <- choose_existing(c("KarolTimeline.json",    "TimelineKarol.json"))

stopifnot(file.exists(IGNACY_JSON), file.exists(KAROLINA_JSON), file.exists(KAROL_JSON))

# oczyszczanie danych
karol <- fromJSON(KAROL_JSON)
karol <- as.data.frame(karol$semanticSegments)
karol <- karol %>% filter(!is.na(activity$topCandidate$type))
karol$startTime <- ymd_hms(karol$startTime, tz = "Europe/Warsaw")
karol$endTime   <- ymd_hms(karol$endTime, tz = "Europe/Warsaw")
karol <- karol %>% filter(as.Date(startTime) >= as.Date("2025-12-06"))
karol$time_spent_minutes <- as.numeric(difftime(karol$endTime, karol$startTime, units = "mins"))
karol$day_of_the_week <- wday(karol$startTime, label = TRUE, abbr = FALSE)
karol <- karol %>%
  mutate(
    mean_of_transport = case_when(
      activity$topCandidate$type == "IN_PASSENGER_VEHICLE" ~ "Samochód",
      activity$topCandidate$type == "WALKING"              ~ "Pieszo",
      activity$topCandidate$type == "IN_BUS"               ~ "Autobus",
      activity$topCandidate$type == "IN_TRAM"              ~ "Tramwaj",
      activity$topCandidate$type == "IN_SUBWAY"            ~ "Metro",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters >  50000 ~ "Pociąg dalekobieżny (IC)",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters <= 50000 ~ "Pociąg podmiejski",
      activity$topCandidate$type == "FLYING"               ~ "Samolot",
      TRUE ~ NA_character_
    )
  ) %>%
  mutate(date_wo_time = as.Date(startTime))

karolina <- fromJSON(KAROLINA_JSON)
karolina <- as.data.frame(karolina$semanticSegments)
karolina <- karolina %>% filter(!is.na(activity$topCandidate$type))
karolina$startTime <- ymd_hms(karolina$startTime, tz = "Europe/Warsaw")
karolina$endTime   <- ymd_hms(karolina$endTime, tz = "Europe/Warsaw")
karolina <- karolina %>% filter(as.Date(startTime) >= as.Date("2025-12-06"))
karolina$time_spent_minutes <- as.numeric(difftime(karolina$endTime, karolina$startTime, units = "mins"))
karolina$day_of_the_week <- wday(karolina$startTime, label = TRUE, abbr = FALSE)
karolina <- karolina %>%
  mutate(
    mean_of_transport = case_when(
      activity$topCandidate$type == "IN_PASSENGER_VEHICLE" ~ "Samochód",
      activity$topCandidate$type == "WALKING"              ~ "Pieszo",
      activity$topCandidate$type == "IN_BUS"               ~ "Autobus",
      activity$topCandidate$type == "IN_TRAM"              ~ "Tramwaj",
      activity$topCandidate$type == "IN_SUBWAY"            ~ "Metro",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters >  50000 ~ "Pociąg dalekobieżny (IC)",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters <= 50000 ~ "Pociąg podmiejski",
      activity$topCandidate$type == "FLYING"               ~ "Samolot",
      TRUE ~ NA_character_
    )
  ) %>%
  mutate(date_wo_time = as.Date(startTime))

ignacy <- fromJSON(IGNACY_JSON)
ignacy <- as.data.frame(ignacy$semanticSegments)
ignacy <- ignacy %>% filter(!is.na(activity$topCandidate$type))
ignacy$startTime <- ymd_hms(ignacy$startTime, tz = "Europe/Warsaw")
ignacy$endTime   <- ymd_hms(ignacy$endTime, tz = "Europe/Warsaw")
ignacy <- ignacy %>% filter(as.Date(startTime) >= as.Date("2025-12-06"))
ignacy$time_spent_minutes <- as.numeric(difftime(ignacy$endTime, ignacy$startTime, units = "mins"))
ignacy$day_of_the_week <- wday(ignacy$startTime, label = TRUE, abbr = FALSE)
ignacy <- ignacy %>%
  mutate(
    mean_of_transport = case_when(
      activity$topCandidate$type == "IN_PASSENGER_VEHICLE" ~ "Samochód",
      activity$topCandidate$type == "WALKING"              ~ "Pieszo",
      activity$topCandidate$type == "IN_BUS"               ~ "Autobus",
      activity$topCandidate$type == "IN_TRAM"              ~ "Tramwaj",
      activity$topCandidate$type == "IN_SUBWAY"            ~ "Metro",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters >  50000 ~ "Pociąg dalekobieżny (IC)",
      activity$topCandidate$type == "IN_TRAIN" & activity$distanceMeters <= 50000 ~ "Pociąg podmiejski",
      activity$topCandidate$type == "FLYING"               ~ "Samolot",
      TRUE ~ NA_character_
    )
  ) %>%
  mutate(date_wo_time = as.Date(startTime))

karol$osoba    <- "Karol"
karolina$osoba <- "Karolina"
ignacy$osoba   <- "Ignacy"
dane_all <- bind_rows(karol, karolina, ignacy)

date_min_all <- min(dane_all$date_wo_time, na.rm = TRUE)
date_max_all <- max(dane_all$date_wo_time, na.rm = TRUE)

dostepne_kategorie <- sort(unique(na.omit(dane_all$mean_of_transport)))

parse_iso_time_num <- function(x) {
  if (is.null(x) || length(x) == 0) return(NA_real_)
  x <- as.character(x[1])
  if (!nzchar(x)) return(NA_real_)
  x2 <- sub("Z$", "+00:00", x)
  x2 <- sub("([+-]\\d\\d):(\\d\\d)$", "\\1\\2", x2)
  t <- as.POSIXct(x2, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC")
  as.numeric(t)
}

parse_point_vec <- function(x) {
  x <- str_replace_all(as.character(x), "°", "")
  x <- str_squish(x)
  m <- str_match(x, "(-?\\d+(?:\\.\\d+)?)\\s*,\\s*(-?\\d+(?:\\.\\d+)?)")
  lat <- suppressWarnings(as.numeric(m[, 2]))
  lon <- suppressWarnings(as.numeric(m[, 3]))
  list(lat = lat, lon = lon)
}

timelinePath_to_segment <- function(tp) {
  if (is.null(tp)) return(NULL)
  
  pts <- NULL; tim <- NULL
  
  if (is.data.frame(tp) && all(c("point", "time") %in% names(tp))) {
    pts <- tp$point; tim <- tp$time
  } else if (is.list(tp) && !is.null(tp$point) && !is.null(tp$time) &&
             (is.atomic(tp$point) || is.character(tp$point)) &&
             (is.atomic(tp$time)  || is.character(tp$time))) {
    pts <- tp$point; tim <- tp$time
  } else if (is.list(tp) && length(tp) > 1 && is.list(tp[[1]]) &&
             all(c("point", "time") %in% names(tp[[1]]))) {
    pts <- vapply(tp, function(e) as.character(e$point)[1], NA_character_)
    tim <- vapply(tp, function(e) as.character(e$time)[1],  NA_character_)
  } else {
    return(NULL)
  }
  
  ok0 <- !is.na(pts) & pts != "" & !is.na(tim) & tim != ""
  pts <- pts[ok0]; tim <- tim[ok0]
  if (length(pts) < 2) return(NULL)
  
  p <- parse_point_vec(pts)
  lat <- suppressWarnings(as.numeric(p$lat))
  lon <- suppressWarnings(as.numeric(p$lon))
  tt  <- vapply(tim, parse_iso_time_num, numeric(1))
  
  ok <- is.finite(lat) & is.finite(lon) & is.finite(tt)
  lat <- lat[ok]; lon <- lon[ok]; tt <- tt[ok]
  if (length(lat) < 2) return(NULL)
  
  o <- order(tt)
  list(t = tt[o], lat = lat[o], lon = lon[o])
}

extract_segments_from_json <- function(path) {
  raw <- fromJSON(path, simplifyVector = FALSE)
  segs <- raw$semanticSegments
  out <- list()
  if (is.null(segs) || length(segs) == 0) return(out)
  
  for (s in segs) {
    seg <- timelinePath_to_segment(s$timelinePath)
    if (!is.null(seg)) out[[length(out) + 1]] <- seg
  }
  out
}

prep_person <- function(path) {
  segs <- extract_segments_from_json(path)
  segs <- segs[!vapply(segs, is.null, logical(1))]
  if (length(segs) == 0) {
    return(list(has_data = FALSE, segments = list(),
                seg_t0 = numeric(0), seg_t1 = numeric(0),
                tmin = NA_real_, tmax = NA_real_,
                init_lat = NA_real_, init_lon = NA_real_))
  }
  
  seg_t0 <- vapply(segs, function(s) min(s$t), numeric(1))
  o <- order(seg_t0)
  segs <- segs[o]
  seg_t0 <- vapply(segs, function(s) min(s$t), numeric(1))
  seg_t1 <- vapply(segs, function(s) max(s$t), numeric(1))
  
  list(
    has_data = TRUE,
    segments = segs,
    seg_t0 = seg_t0,
    seg_t1 = seg_t1,
    tmin = seg_t0[1],
    tmax = max(seg_t1),
    init_lat = segs[[1]]$lat[1],
    init_lon = segs[[1]]$lon[1]
  )
}

position_from_segments_fast <- function(segs, seg_t0, seg_t1, t_now) {
  n <- length(segs)
  if (n == 0 || !is.finite(t_now)) return(NULL)
  
  if (t_now <= seg_t0[1]) {
    s <- segs[[1]]
    return(list(lat = s$lat[1], lon = s$lon[1]))
  }
  
  k <- findInterval(t_now, seg_t0)
  if (k < 1) k <- 1
  if (k > n) k <- n
  
  s <- segs[[k]]
  if (t_now <= seg_t1[k]) {
    tt <- s$t
    j <- findInterval(t_now, tt)
    if (j <= 0) return(list(lat = s$lat[1], lon = s$lon[1]))
    if (j >= length(tt)) return(list(lat = s$lat[length(tt)], lon = s$lon[length(tt)]))
    if (tt[j + 1] == tt[j]) return(list(lat = s$lat[j], lon = s$lon[j]))
    w <- (t_now - tt[j]) / (tt[j + 1] - tt[j])
    return(list(
      lat = s$lat[j] + w * (s$lat[j + 1] - s$lat[j]),
      lon = s$lon[j] + w * (s$lon[j + 1] - s$lon[j])
    ))
  }
  
  npt <- length(s$t)
  list(lat = s$lat[npt], lon = s$lon[npt])
}

time_num_from_date_hm <- function(day_date, hour, minute) {
  if (is.null(day_date)) return(NA_real_)
  hh <- suppressWarnings(as.integer(hour))
  mm <- suppressWarnings(as.integer(minute))
  if (!is.finite(hh) || !is.finite(mm)) return(NA_real_)
  if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return(NA_real_)
  stamp <- sprintf("%s %02d:%02d:00", as.character(day_date), hh, mm)
  as.numeric(as.POSIXct(stamp, tz = "Europe/Warsaw"))
}

P <- list(
  Ignacy   = prep_person(IGNACY_JSON),
  Karolina = prep_person(KAROLINA_JSON),
  Karol    = prep_person(KAROL_JSON)
)

tmins <- vapply(P, function(x) x$tmin, numeric(1))
tmaxs <- vapply(P, function(x) x$tmax, numeric(1))
ok <- is.finite(tmins) & is.finite(tmaxs)
stopifnot(any(ok))

global_tmin <- min(tmins[ok])
global_tmax <- max(tmaxs[ok])

tmin_waw <- as.POSIXct(global_tmin, origin = "1970-01-01", tz = "Europe/Warsaw")
tmax_waw <- as.POSIXct(global_tmax, origin = "1970-01-01", tz = "Europe/Warsaw")

day_min <- as.Date(tmin_waw)
day_max <- as.Date(tmax_waw)

desired_day  <- as.Date("2025-12-09")
init_day <- if (desired_day < day_min) day_min else if (desired_day > day_max) day_max else desired_day
init_hour <- 10L
init_min  <- 0L

inits_lat <- vapply(P, function(x) x$init_lat, numeric(1))
inits_lon <- vapply(P, function(x) x$init_lon, numeric(1))
ok2 <- is.finite(inits_lat) & is.finite(inits_lon)
init_center <- if (any(ok2)) c(lat = mean(inits_lat[ok2]), lon = mean(inits_lon[ok2])) else c(lat = 52.23, lon = 21.01)

AV <- data.frame(
  id     = c("Ignacy", "Karolina", "Karol"),
  label  = c("I", "Ka", "Ko"),
  fill   = c("#111111", "#C62828", "#1565C0"),
  stroke = c("#FFFFFF", "#FFFFFF", "#FFFFFF"),
  stringsAsFactors = FALSE
)

hours_choices   <- setNames(0:23, sprintf("%02d", 0:23))
minutes_choices <- setNames(0:59, sprintf("%02d", 0:59))

# ui
ui <- navbarPage(
  title = "Jak się poruszamy?",
  tabPanel(
    "Wykresy",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          checkboxGroupInput(
            inputId = "osoby",
            label = "Wybierz osoby",
            choices = c("Karol", "Karolina", "Ignacy"),
            selected = c("Karol")
          ),
          
          dateRangeInput(
            inputId = "zakres_dat",
            label = "Zakres dat",
            start = date_min_all,
            end   = date_max_all,
            min   = date_min_all,
            max   = date_max_all
          ),
          
          checkboxGroupInput(
            inputId = "transport_karolina",
            label = "Środki transportu",
            choices = dostepne_kategorie,
            selected = intersect(c("Autobus","Metro","Pieszo","Pociąg podmiejski", "Samochód", "Tramwaj"), dostepne_kategorie)
          ),
          selectInput(
            inputId = "wykres1",
            label = "Pierwszy wykres",
            choices = c(
              "Dystans wg środka transportu" = "distance",
              "Czas wg środka transportu" = "time"
            )
          ),
          
          
          selectInput(
            inputId = "wykres3",
            label = "Drugi wykres",
            choices = c(
              "Średnia prędkość wg dni tygodnia" = "speed_weekday",
              "Średnia prędkość wg środka transportu" = "speed_transport"
            )
          ),
          
          
          selectInput(
            inputId = "wykres2",
            label = "Trzeci wykres",
            choices = c(
              "Średni dystans w tygodniu" = "week_distance",
              "Średni czas w tygodniu" = "week_time"
            )
          )
          
        ),
        
        mainPanel(
          plotOutput("plot1"),
          plotOutput("plot3"),
          plotOutput("plot2"),
          
          tags$hr(),
          h4("Liczba podróży w rozkładzie godzinowym"),
          plotlyOutput("transportPlotKarolina", height = "380px")
        ))
    )
  ),
  tabPanel(
    "Mapa",
    fluidPage(
      tags$head(tags$style(HTML("
        .leaflet-tooltip.avatarLabel{
          background: transparent !important;
          border: none !important;
          box-shadow: none !important;
          color: white !important;
          font-weight: 800 !important;
          font-size: 13px !important;
          padding: 0 !important;
        }
        .leaflet-tooltip.avatarLabel:before{ display:none !important; }
      "))),
      fluidRow(
        column(
          4,
          wellPanel(
            dateInput("map_day", "Data", value = init_day, min = day_min, max = day_max, format = "yyyy-mm-dd"),
            fluidRow(
              column(6, selectInput("map_hour", "Godzina", choices = hours_choices, selected = init_hour)),
              column(6, selectInput("map_min",  "Minuty",  choices = minutes_choices, selected = init_min))
            ),
            tags$hr(),
            tags$b("Skocz o"),
            fluidRow(
              column(3, actionButton("back60", "−1 godz.")),
              column(3, actionButton("back15", "−15 min")),
              column(3, actionButton("fwd15",  "+15 min")),
              column(3, actionButton("fwd60",  "+1 godz."))
            ),
            tags$hr(),
            selectInput(
              "speed", "Prędkość",
              choices = c("1x"=1, "2x"=2, "5x"=5, "60x"=60, "144x"=144, "1440x"=1440),
              selected = 144
            ),
            tags$hr(),
            actionButton("play_btn",  "Play",  class = "btn btn-primary"),
            actionButton("pause_btn", "Pause", class = "btn btn-secondary"),
            actionButton("reset_btn", "Reset", class = "btn btn-danger"),
            tags$hr(),
            verbatimTextOutput("status_map"),
            tags$hr(),
            tags$div(tags$b("Idź do:")),
            fluidRow(
              column(4, actionButton("goto_ignacy",   "Ignacy")),
              column(4, actionButton("goto_karolina", "Karolina")),
              column(4, actionButton("goto_karol",    "Karol"))
            )
          )
        ),
        column(8, leafletOutput("map", height = "700px"))
      )
    )
  )
)

# SERVER
server <- function(input, output, session) {

  dane_filtrowane <- reactive({
    req(input$zakres_dat, input$osoby)
    
    df <- dane_all %>%
      filter(
        date_wo_time >= input$zakres_dat[1],
        date_wo_time <= input$zakres_dat[2],
        osoba %in% input$osoby
      ) %>%
      filter(!is.na(mean_of_transport))
    
    if (!is.null(input$transport_karolina)) {
      df <- df %>% filter(mean_of_transport %in% input$transport_karolina)
    }
    
    df
  })
  
  output$plot1 <- renderPlot({
    df <- dane_filtrowane()
    if (input$wykres1 == "distance") {
      df %>%
        group_by(osoba, mean_of_transport) %>%
        summarise(distance = sum(activity$distanceMeters, na.rm = TRUE), .groups = "drop") %>%
        ggplot(aes(x = reorder(mean_of_transport, -distance), y = distance / 1000, fill = osoba)) +
        geom_col(position = "dodge") +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "Czym pokonaliśmy największy dystans?",
          x = "Środek transportu",
          y = "Dystans [km]",
          fill = ""
        )
    } else {
      df %>%
        group_by(mean_of_transport) %>%
        summarise(total_time = sum(time_spent_minutes, na.rm = TRUE), .groups = "drop") %>%
        ggplot(aes(x = reorder(mean_of_transport, -total_time), y = total_time / 60, fill = osoba)) +
        geom_col(position = "dodge") +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "W czym spędziliśmy najwięcej czasu?",
          x = "Środek transportu",
          y = "Czas [h]",
          fill = ""
        )
    }
  })
  
  
  output$plot3 <- renderPlot({
    df <- dane_filtrowane()
    if (input$wykres3 == "speed_weekday") {
      df %>%
        group_by(osoba, day_of_the_week) %>%
        summarise(
          total_distance_km = sum(activity$distanceMeters, na.rm = TRUE) / 1000,
          total_time_h      = sum(time_spent_minutes, na.rm = TRUE) / 60,
          avg_speed         = total_distance_km / total_time_h,
          .groups = "drop"
        ) %>%
        ggplot(aes(x = day_of_the_week, y = avg_speed,fill=osoba)) +
        geom_col(position = "dodge") +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "Średnia prędkość wg dnia tygodnia",
          x = "Dzień tygodnia",
          y = "Prędkość [km/h]"
        ) + theme(legend.position = "none")
    } else {
      df %>%
        group_by(osoba, mean_of_transport) %>%
        summarise(
          total_distance_km = sum(activity$distanceMeters, na.rm = TRUE) / 1000,
          total_time_h      = sum(time_spent_minutes, na.rm = TRUE) / 60,
          avg_speed         = total_distance_km / total_time_h,
          .groups = "drop"
        ) %>%
        ggplot(aes(x = mean_of_transport, y = avg_speed,fill=osoba)) +
        geom_col(position = "dodge") +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "Średnia prędkość wg środka transportu",
          x = "Środek transportu",
          y = "Prędkość [km/h]"
        ) + theme(legend.position = "none")
    }
  })
  
  output$plot2 <- renderPlot({
    df <- dane_filtrowane()
    if (input$wykres2 == "week_distance") {
      df %>%
        group_by(day_of_the_week, mean_of_transport, date_wo_time) %>%
        summarise(total_distance = sum(activity$distanceMeters, na.rm = TRUE), .groups = "drop") %>%
        group_by(day_of_the_week, mean_of_transport) %>%
        summarise(average_distance = mean(total_distance), .groups = "drop") %>%
        ggplot(aes(x = day_of_the_week, y = average_distance / 1000, fill = mean_of_transport)) +
        geom_col() +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "Rozkład tego czym się poruszamy w ciągu tygodnia",
          x = "Dzień tygodnia",
          y = "Średni dystans [km]"
        ) + theme(legend.position = "none")
    } else {
      df %>%
        group_by(day_of_the_week, mean_of_transport, date_wo_time) %>%
        summarise(total_time = sum(time_spent_minutes, na.rm = TRUE), .groups = "drop") %>%
        group_by(day_of_the_week, mean_of_transport) %>%
        summarise(average_time = mean(total_time), .groups = "drop") %>%
        ggplot(aes(x = day_of_the_week, y = average_time / 60, fill = mean_of_transport)) +
        geom_col() +
        scale_fill_manual(values = moje_kolory) +
        labs(
          title = "Rozkład tego czym się poruszamy w ciągu tygodnia",
          x = "Dzień tygodnia",
          y = "Średni czas [h]"
        ) + theme(legend.position = "none")
    }
  })
  
  dane_godzinowe <- reactive({
    req(input$zakres_dat, input$osoby)
    
    df <- dane_all %>%
      filter(
        date_wo_time >= input$zakres_dat[1],
        date_wo_time <= input$zakres_dat[2],
        osoba %in% input$osoby
      ) %>%
      filter(!is.na(mean_of_transport))
    
    if (!is.null(input$transport_karolina)) {
      df <- df %>% filter(mean_of_transport %in% input$transport_karolina)
    }
    
    df %>%
      mutate(hour_start = hour(startTime)) %>%
      group_by(osoba, mean_of_transport, hour_start) %>%
      summarise(liczba_przejazdow = n(), .groups = "drop") %>%
      mutate(
        moj_tekst = paste0(
          "Godzina: ", sprintf("%02d", hour_start), ":00\n",
          "Transport: ", mean_of_transport, "\n",
          "Liczba podróży: ", liczba_przejazdow
        )
      )
  })
  
  output$transportPlotKarolina <- renderPlotly({
    data <- dane_godzinowe()
    
    p <- ggplot(
      data,
      aes(
        x = hour_start,
        y = liczba_przejazdow,
        fill = mean_of_transport,
        text = moj_tekst
      )
    ) +
      geom_col(position = "stack", width = 0.8, alpha = 0.9) +
      facet_wrap(~osoba, ncol = 1) +
      scale_x_continuous(breaks = 0:23, name = "Godzina") +
      scale_y_continuous(name = "Liczba rozpoczętych podróży") +
      scale_fill_manual(values = moje_kolory) +
      theme_minimal() +
      theme(legend.position = "bottom") +
      labs(fill = "Środek transportu")
    
    ggplotly(p, tooltip = "text") %>% layout(
        legend = list(
          orientation = "h",
          x = 0.5, xanchor = "center",
          y = 1.1, yanchor = "bottom"
        )
      )
  })
  
  # MAPAA
  rv <- reactiveValues(
    playing = FALSE,
    t_num = global_tmin,
    start_num = global_tmin,
    last_real = as.numeric(Sys.time()),
    slot = list(Ignacy = 1L, Karolina = 1L, Karol = 1L),
    last_pos = list(),
    zoom = 12
  )
  
  tick <- reactiveTimer(250)
  
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = TRUE, preferCanvas = TRUE)) %>%
      addTiles() %>%
      setView(lng = init_center["lon"], lat = init_center["lat"], zoom = 12)
  })
  
  observeEvent(input$map_zoom, {
    z <- suppressWarnings(as.numeric(input$map_zoom))
    if (is.finite(z)) rv$zoom <- z
  }, ignoreInit = TRUE)
  
  get_pos_now <- function(id) {
    pp <- P[[id]]
    if (!isTRUE(pp$has_data)) return(NULL)
    pos <- position_from_segments_fast(pp$segments, pp$seg_t0, pp$seg_t1, rv$t_num)
    if (is.null(pos) || !is.finite(pos$lat) || !is.finite(pos$lon)) return(NULL)
    pos
  }
  
  get_pos_always <- function(id) {
    pos <- get_pos_now(id)
    if (!is.null(pos)) return(pos)
    
    if (!is.null(rv$last_pos[[id]]) &&
        is.finite(rv$last_pos[[id]]$lat) && is.finite(rv$last_pos[[id]]$lon)) {
      return(rv$last_pos[[id]])
    }
    
    pp <- P[[id]]
    if (isTRUE(pp$has_data) && length(pp$segments) >= 1) {
      s <- pp$segments[[1]]
      if (length(s$lat) >= 1 && length(s$lon) >= 1 && is.finite(s$lat[1]) && is.finite(s$lon[1])) {
        return(list(lat = s$lat[1], lon = s$lon[1]))
      }
    }
    NULL
  }
  
  go_to_person <- function(id) {
    p <- get_pos_always(id)
    if (is.null(p)) return()
    leafletProxy("map") %>% setView(lng = p$lon, lat = p$lat, zoom = rv$zoom)
  }
  
  draw_or_move <- function() {
    proxy <- leafletProxy("map")
    positions <- list()
    
    for (i in seq_len(nrow(AV))) {
      id <- AV$id[i]
      pos <- get_pos_always(id)
      if (is.null(pos)) next
      positions[[id]] <- pos
      
      old_slot <- rv$slot[[id]]
      if (is.null(old_slot) || !old_slot %in% c(1L, 2L)) old_slot <- 1L
      new_slot <- if (old_slot == 1L) 2L else 1L
      
      old_id <- paste0(id, "__", old_slot)
      new_id <- paste0(id, "__", new_slot)
      
      proxy <- proxy %>% addCircleMarkers(
        lng = pos$lon, lat = pos$lat,
        radius = 10,
        color = AV$stroke[i], weight = 2,
        fillColor = AV$fill[i], fillOpacity = 0.85,
        layerId = new_id,
        label = AV$label[i],
        labelOptions = labelOptions(noHide = TRUE, direction = "center", className = "avatarLabel")
      )
      
      proxy <- proxy %>% removeMarker(layerId = old_id)
      rv$slot[[id]] <- new_slot
    }
    
    rv$last_pos <- positions
  }
  
  observeEvent(TRUE, {
    tn <- time_num_from_date_hm(init_day, init_hour, init_min)
    if (!is.finite(tn)) tn <- global_tmin
    tn <- min(max(tn, global_tmin), global_tmax)
    
    rv$t_num <- tn
    rv$start_num <- tn
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, once = TRUE)
  
  # wybór daty i godziny
  observeEvent(list(input$map_day, input$map_hour, input$map_min), {
    tn <- time_num_from_date_hm(input$map_day, input$map_hour, input$map_min)
    if (!is.finite(tn)) return()
    tn <- min(max(tn, global_tmin), global_tmax)
    rv$t_num <- tn
    rv$start_num <- tn
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = FALSE)
  
  observeEvent(input$back15, {
    rv$t_num <- max(global_tmin, rv$t_num - 15 * 60)
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = TRUE)
  
  observeEvent(input$fwd15, {
    rv$t_num <- min(global_tmax, rv$t_num + 15 * 60)
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = TRUE)
  
  observeEvent(input$back60, {
    rv$t_num <- max(global_tmin, rv$t_num - 60 * 60)
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = TRUE)
  
  observeEvent(input$fwd60, {
    rv$t_num <- min(global_tmax, rv$t_num + 60 * 60)
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = TRUE)
  
  # Idź do:
  observeEvent(input$goto_ignacy,   { go_to_person("Ignacy")   }, ignoreInit = TRUE)
  observeEvent(input$goto_karolina, { go_to_person("Karolina") }, ignoreInit = TRUE)
  observeEvent(input$goto_karol,    { go_to_person("Karol")    }, ignoreInit = TRUE)
  
  observeEvent(input$play_btn, {
    rv$playing <- TRUE
    rv$last_real <- as.numeric(Sys.time())
  }, ignoreInit = TRUE)
  
  observeEvent(input$pause_btn, {
    rv$playing <- FALSE
  }, ignoreInit = TRUE)
  
  observeEvent(input$reset_btn, {
    rv$playing <- FALSE
    rv$t_num <- rv$start_num
    rv$last_real <- as.numeric(Sys.time())
    draw_or_move()
  }, ignoreInit = TRUE)
  
  # timer mapy
  observeEvent(tick(), {
    if (!isTRUE(rv$playing)) return()
    
    now <- as.numeric(Sys.time())
    dt <- now - rv$last_real
    rv$last_real <- now
    if (!is.finite(dt) || dt <= 0) return()
    
    sp <- suppressWarnings(as.numeric(input$speed))
    if (!is.finite(sp) || sp <= 0) sp <- 1
    
    rv$t_num <- rv$t_num + dt * sp
    
    if (rv$t_num >= global_tmax) {
      rv$t_num <- global_tmax
      rv$playing <- FALSE
    }
    
    draw_or_move()
  })
  
  output$status_map <- renderText({
    t_waw <- as.POSIXct(rv$t_num, origin = "1970-01-01", tz = "Europe/Warsaw")
    paste0(
      "Tryb: ", if (isTRUE(rv$playing)) "PLAY" else "PAUZA", "\n",
      "Czas (Warszawa): ", format(t_waw, "%Y-%m-%d %H:%M:%S")
    )
  })
}

shinyApp(ui, server)
