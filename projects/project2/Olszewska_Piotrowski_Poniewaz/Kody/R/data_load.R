load_screen_data <- function() {
  df <- read.csv(
    "data/aplikacje.csv",
    encoding = "UTF-8",
    check.names = FALSE,
    sep = ";"
  )
  
  df <- df %>% rename(date = data, minuty = czas_min)
  
  if (is.character(df$minuty)) {
    df$minuty <- as.numeric(gsub(",", ".", df$minuty))
  }
  
  df$powiadomienia <- as.numeric(df$powiadomienia)
  
  df$date <- as.Date(df$date, format = "%d.%m.%Y")
  df
}


load_caffeine_data <- function() {
  
  kofeina_na_100ml <- c(
    "kawa" = 40,
    "herbata" = 32,
    "energetyk" = 32
  )
  
  df <- read.csv(
    "data/kofeina.csv",
    sep = ";",
    encoding = "UTF-8",
    stringsAsFactors = FALSE
  )
  
  df %>%
    mutate(
      imie = tools::toTitleCase(imie),
      ilosc_ml = as.numeric(ilosc_ml),
      godzina_h = as.numeric(substr(godzina, 1, 2)),
      kofeina_mg = ilosc_ml / 100 * kofeina_na_100ml[typ],
      date = as.Date(data, format = "%d.%m.%Y")
    )
}


load_sleep_data <- function() {
  d <- read.csv(
    "data/sen.csv",
    sep = ";",
    stringsAsFactors = FALSE,
    encoding = "UTF-8"
  )
  
  d %>%
    mutate(
      date = as.Date(data, format = "%d.%m.%Y"),
      bed_min  = as.integer(substr(pojscie_spac, 1, 2)) * 60 +
        as.integer(substr(pojscie_spac, 4, 5)),
      wake_min = as.integer(substr(wstanie, 1, 2)) * 60 +
        as.integer(substr(wstanie, 4, 5)),
      bed_h  = bed_min / 60,
      wake_h = wake_min / 60,
      imie = tools::toTitleCase(imie),
      data_label = format(date, "%d.%m")
    )
}

