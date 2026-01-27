library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(wordcloud)
library(RColorBrewer)
library(shinyWidgets)
library(shinyquiz)
library(fmsb)
library(forcats)
library(viridis)
library(lubridate)

source("R/data_load.R")
source("R/ui_helpers.R")
source("R/plots_all.R")
source("quiz/quiz_engine.R")

NUM_OF_QUIZ_QUESTIONS <- 8
quiz <- make_quiz(NUM_OF_QUIZ_QUESTIONS)

screen_df <- load_screen_data()
caffeine_df <- load_caffeine_data()
sleep_df <- load_sleep_data()

persons <- c("Kacper", "Emilka", "Bartek")

person_colors <- c(
  "Emilka" = "rosybrown2",
  "Kacper" = "darkolivegreen3",
  "Bartek" = "steelblue2"
)

avatars <- list(
  Kacper  = list(img = "Ferb.png",    y = "5%"),
  Emilka  = list(img = "Fretka.png",  y = "0%"),
  Bartek  = list(img = "Fineasz.png", y = "20%")
)

categories <- list(
  overview = "Overview",
  caffeine = "Spożycie kofeiny",
  sleep    = "Sen",
  screen   = "Czas ekranowy"
)

drink_variant_colors <- c(
  "herbata_czarna"  = "#cb3200",
  "herbata_zielona" = "#2E7D32",
  "herbata_oolong"  = "#f3ffa5",
  "herbata_biała"   = "#fbffea",
  
  "kawa_czarna"     = "#4E342E",
  "kawa_biała"      = "#D7CCC8",
  
  "energetyk_dzik" = "#d588fc",
  "energetyk_monster"    = "#c3c2c3"
)

drink_variant_labels <- c(
  "herbata_czarna"  = "Herbata – czarna",
  "herbata_zielona" = "Herbata – zielona",
  "herbata_oolong"  = "Herbata – oolong",
  
  "kawa_czarna"     = "Kawa – czarna",
  "kawa_biała"      = "Kawa – biała",
  
  "energetyk_dzik"       = "Energetyk - Dzik",
  "energetyk_monster"   = "Energetyk - Monster"
)

WEEKDAYS_PL <- c(
  "poniedziałek",
  "wtorek",
  "środa",
  "czwartek",
  "piątek",
  "sobota",
  "niedziela"
)