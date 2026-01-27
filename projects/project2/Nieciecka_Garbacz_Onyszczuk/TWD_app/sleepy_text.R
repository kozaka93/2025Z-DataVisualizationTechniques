sleepy_text <- function(user, date){
  
  # Wczytanie ramek danych ----------------------------------------------------
  if (user == "Nina"){
    sleep <- read.csv("data/barplot/sleep/sleep_nina.csv")
  } else if (user == "Ania") {
    sleep <- read.csv("data/barplot/sleep/sleep_ania.csv")
  } else {
    sleep <- read.csv("data/barplot/sleep/sleep_karolina.csv")
  }
  
  # Zmiana typu danych --------------------------------------------------------
  sleep$date <- as.Date(sleep$date)
  
  # Ograniczenie względem daty ------------------------------------------------
  selected_sleep <- sleep[sleep$date >= date[[1]] & sleep$date <= date[[2]],]
  
  shiny::validate(need(nrow(selected_sleep) > 0, "Brak danych w wybranym zakresie."))
  
  alarm_mean = paste0("<div style='margin-left: 20px; font-size: 22px;'>",
                      "Średni czas wstawania z alarmem w wybranym zakresie: <span style='color: #4ebce2; font-weight: bold;'>",
                      round(mean(selected_sleep$alarm_duration, na.rm = TRUE)/60), ' min</span></div>')
  alarm_max = paste0("<div style='margin-left: 20px; font-size: 22px;'>",
                     "Najdłuższy czas wstawania z alarmem w wybranym zakresie: <span style='color: #4ebce2; font-weight: bold;'>",
                     round(max(selected_sleep$alarm_duration, na.rm = TRUE)/60), ' min</span></div>')
  
  c(alarm_mean, alarm_max)
}