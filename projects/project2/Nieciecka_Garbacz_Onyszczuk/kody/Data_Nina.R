## Biblioteki -----------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(plotly)
library(lubridate)

## Wczytywanie danych --------------------------------------------------------- 
phone_data <- read.csv("Data_csv/dane_Nina/Nina_telefon.csv")
laptop_data <- read.csv("Data_csv/dane_Nina/Nina_afk_komputer.csv")

## Phone data -----------------------------------------------------------------
phone_data <- phone_data %>% 
  select(timestamp, duration, data.app)
colnames(phone_data)[c(2,3)] <- c('phone_duration', 'phone_app')

phone_data <- phone_data %>% 
  mutate(timestamp = ymd_hms(timestamp, tz = "Europe/Warsaw"),
         date = as.Date(timestamp))

## Laptop data ----------------------------------------------------------------
colnames(laptop_data)[2] <- c('laptop_duration')

laptop_data <- laptop_data %>% 
  filter(status == 'not-afk') %>% 
  mutate(timestamp = ymd_hms(timestamp, tz = "Europe/Warsaw")) %>% 
  select(!status)

laptop_data <- laptop_data %>% 
  group_by(timestamp) %>% 
  summarise(laptop_duration = max(laptop_duration), .groups = 'drop')

## Screen time ----------------------------------------------------------------
phone_screentime <- phone_data %>% 
  mutate(timestamp = ymd_hm(format(timestamp, '%Y-%m-%d %H:%M'))) %>% 
  group_by(timestamp) %>% 
  summarise(phone_duration = sum(phone_duration, na.rm = TRUE), .groups = 'drop')

laptop_screentime <- laptop_data %>% 
  mutate(timestamp = ymd_hm(format(timestamp, '%Y-%m-%d %H:%M'))) %>% 
  group_by(timestamp) %>% 
  summarise(laptop_duration = sum(laptop_duration, na.rm = TRUE), .groups = 'drop')

screentime <- full_join(phone_screentime, laptop_screentime, by= 'timestamp')

screentime[is.na(screentime)] <- 0

screentime <- screentime %>% 
  mutate(total_duration = case_when(phone_duration == 0 ~laptop_duration,
                                    laptop_duration == 0 ~phone_duration,
                                    phone_duration > laptop_duration ~phone_duration,
                                    TRUE ~laptop_duration))
screentime <- screentime %>% 
  mutate(date = date(timestamp)) %>% 
  group_by(date) %>% 
  summarise(phone_duration = sum(phone_duration),
            laptop_duration = sum(laptop_duration),
            total_duration = sum(total_duration), .groups = 'drop')

## Sleep ----------------------------------------------------------------------
# Alarm clock -----------------------------------------------------------------
morn <- phone_data %>% 
  filter(!(phone_app %in% c('One UI Home', 'Software update'))) %>% # dane systemowe
  filter(timestamp >= ymd_hms(paste(date, '5:15:00'), tz = 'Europe/Warsaw'))

segments <- morn %>% 
  group_by(date) %>% 
  arrange(timestamp) %>% 
  mutate(segment = (phone_app != lag(phone_app, default = first(phone_app))),
         segment_number = cumsum(segment)) %>% 
  ungroup()

alarm_clock <- segments %>% 
  filter(phone_app == 'Clock', segment_number == 0) %>% 
  group_by(date) %>% 
  summarise(clock_start = format(min(timestamp), '%H:%M:%S'), 
            clock_end = format(max(timestamp), '%H:%M:%S')) %>% 
  ungroup() %>% 
  mutate(clock_start = hms::as_hms(clock_start),
         clock_end = hms::as_hms(clock_end),
         alarm_duration = clock_end - clock_start)

# Sleep duration --------------------------------------------------------------
sleep <- phone_data %>% 
  group_by(date) %>% 
  summarise(
    before_midnight = {
      midnight <- timestamp[timestamp <= ymd_hms(paste(date, '23:59:59'), tz = 'Europe/Warsaw')]
      format(max(midnight), '%H:%M:%S')
    },
    after_midnight = {
      bedtime <- timestamp[timestamp <= ymd_hms(paste(date, '5:15:00'), tz = 'Europe/Warsaw')]
      if (length(bedtime) == 0) NA_character_ else format(max(bedtime), '%H:%M:%S')
    },
    awakening = {
      morning <- timestamp[timestamp > ymd_hms(paste(date, '5:15:00'), tz = 'Europe/Warsaw')]
      format(min(morning), '%H:%M:%S')
    },
    .groups = 'drop'
  )

sleep <- sleep %>% 
  left_join(alarm_clock, by = 'date') %>% 
  mutate(before_midnight = hms::as_hms(before_midnight),
         after_midnight = hms::as_hms(after_midnight),
         awakening = hms::as_hms(awakening),
         awakening = if_else(is.na(clock_end), awakening, clock_end)) %>% 
  select(!c(clock_start, clock_end))

sleep <- sleep %>% 
  mutate(before_midnight = lag(before_midnight))

sleep <- sleep[-c(1, nrow(sleep)),] # niepełne dane - dzień instalacji programu

sleep <- sleep %>%
  mutate(sleep_time = if_else(is.na(after_midnight), 
                              awakening + dhours(24) - before_midnight,
                              awakening - after_midnight)) %>% 
  select(date, sleep_time, alarm_duration)

# Zapis csv -------------------------------------------------------------------
# write.csv(screentime, "screentime_nina.csv", row.names = FALSE)
# write.csv(sleep, 'sleep_nina.csv', row.names = FALSE)


