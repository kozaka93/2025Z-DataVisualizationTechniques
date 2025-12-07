# Praca domowa numer 4 Wiktoria Postek

# Link do oryginalnej wizualizacji:
# https://x.com/kingseesdaworld/status/1655921269966008321/photo/1

# Link do zestawu danych w repozytorium TidyTuesday:
# https://github.com/rfordatascience/tidytuesday/tree/main/data/2023/2023-04-25

# Jakie elementy wykresu wymagają poprawy?
# 1. Zła forma wykresu - zastosowano wykres typu radial bar, gdzie odbiorca może mieć trudności z prawidłowym odczytaniem długości danych słupków,
#    a także porównaniem wartości między danymi krajami oraz kategoriami.
# 2. Nadmiar kolorów, napisów i dodatków - zbyt duża ich ilość rozprasza uwagę odbiorcy i obniża czytelność wykresu, odwraca uwagę od danych.
#    (Ponadto flagi państw są małe i nieczytelne)



library(tidytuesdayR)
library(dplyr)
library(tidytext)
library(ggplot2)

tuesdata <- tidytuesdayR::tt_load(2023, week = 17)

winners <- tuesdata$winners
london_marathon <- tuesdata$london_marathon

winners_summary <- winners %>% 
  group_by(Category, Nationality) %>% 
  summarise(n = n()) %>% 
  mutate(Category = factor(Category,
                           levels = c("Men", "Wheelchair Men", "Women", "Wheelchair Women")))

p <- ggplot(winners_summary, aes(x = n,
                                 y = reorder_within(Nationality, n, Category))) +
              geom_col(fill = "darkblue") +
              facet_wrap(~Category, scales = "free_y", ncol = 2) +
              scale_y_reordered() +
              labs(title = "Number of London Marathon Winners by country",
                   x = "Number of wins",
                   y = "Country",
                   caption = "Data: TidyTuesday 2023-04-25, London Marathon winners") +
              theme_minimal(base_size = 12) +
              theme(strip.text = element_text(face = "bold"),
                    axis.text.y = element_text(size = 8),
                    panel.spacing = unit(1, "lines"),
                    plot.caption = element_text(hjust = 0),
                    plot.background  = element_rect(fill = "whitesmoke", colour = NA),
                    panel.background = element_rect(fill = "whitesmoke", colour = NA),)
p

# Przygotowany wykres jest lepszy od oryginału, ponieważ:
# 1. Poziomy wykres słupkowy jest prostszy w odbiorze, dzięki czemu można łatwo porównać liczbę zwycięstw między krajami, a także czterema kategoriami.
# 2. Dane są posortowane od największej do najmniejszej liczby zwycięstw, co ułatwia szybkie zidentyfikowanie dominujących krajów.
# 3. Nie ma nadmiaru kolorów oraz zbędnych ozdobników, dzięki czemu odbiorca może się skupić na samych danych, a wykres jest dużo bardziej czytelny, niż wykres radialny.
