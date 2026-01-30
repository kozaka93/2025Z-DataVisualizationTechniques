library(dplyr)
library(jsonlite)
library(lubridate)
library(tidyr)

get_user_data <- function(user_name) {
  devices <- list(
    komputer = list(suffix = "_komputer.json", pattern = "window"),
    telefon  = list(suffix = "_telefon.json",  pattern = "android")
  )
  
  all_events <- list()
  
  for (dev_name in names(devices)) {
    file_path <- paste0("data/", user_name, devices[[dev_name]]$suffix)
    
    if (file.exists(file_path)) {
      raw <- fromJSON(file_path, flatten = TRUE)
      idx <- grep(devices[[dev_name]]$pattern, names(raw$buckets))
      
      if (length(idx) > 0) {
        events <- raw$buckets[[idx[1]]]$events
        
        if ("data.title" %in% names(events)) {
          events <- events %>% select(timestamp, duration, data.title)
        } else {
          events <- events %>% select(timestamp, duration)
        }
        
        events <- events %>%
          mutate(
            device = dev_name,
            czas = with_tz(as_datetime(timestamp), tzone = "Europe/Warsaw"),
            data_dzien = as.Date(czas),
            godzina = hour(czas),
            dzien_tygodnia = factor(format(czas, "%A"), 
                                    levels = c("niedziela", "sobota", "piątek", "czwartek", "środa", "wtorek", "poniedziałek")),
            tydzien_start = floor_date(data_dzien, unit = "week", week_start = 1)
          )
        all_events[[dev_name]] <- events
      }
    }
  }
  
  if(length(all_events) == 0) return(data.frame())
  
  return(bind_rows(all_events))
}