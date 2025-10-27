###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           PRACA DOMOWA 1            ###
###########################################

# Ładowanie pakietów-----------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)

# Ładowanie danych --------------------------------------------------------
reviews <- read.csv("reviews.csv")
listings <- read.csv("listings.csv")

# Instrukcja --------------------------------------------------------------

# Poniższe zadania wymagają obróbki danych. W tym celu należy wykorzystać pakiet
# dplyr i tidyr. Wynik z każdego zadania należy przypisać do zdefiniowanej nazwy
# ANS_TASK_0X. Kod utworzonych wykresów należy pozostawić w pliku .R, nie należy
# zapisywać wykresów.
# Po wykonaniu wszystkich zdań należy wykonać kod oznaczony nagłówkiem 
# "Zapisanie rozwiązań do plik .RDS".



# Zadanie 1 (0.5) ---------------------------------------------------------
# Ilu recenzentów wystawiło więcej niż 20 opinii?

## Rozwiązanie
ans1 <- reviews %>% 
  group_by(reviewer_id) %>% 
  summarise(n = n()) %>% 
  filter(n > 20) %>% 
  summarise(total_reviewers = n())

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- ans1[[1]]

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
reviews$date <- as.Date(reviews$date)
reviews$month <- format(reviews$date, "%m")
reviews$month = as.numeric(reviews$month)

ans2 <- reviews %>% 
  group_by(month) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  head(3)

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- ans2$month

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie
listings_count <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(n = n()) %>% 
  rename(id = listing_id)

merged_listings <- merge(listings, listings_count, by = "id")

ans3 <- merged_listings %>% 
  filter(n > 100) %>% 
  top_n(1, price)

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- ans3$price

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie
reviews$how_long = as.numeric(difftime(Sys.Date(), reviews$date, units = "days")) / 365.25

ans4 <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(max_how_long = max(how_long)) %>% 
  filter(max_how_long > 10)
ans4 <- c(length(ans4$listing_id), max(ans4$max_how_long))
names(ans4) <- c("liczba", "największy staż")

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- ans4

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
latitude_mean <- mean(listings$latitude)

ans5 <- listings %>%
  mutate(region = ifelse(latitude < latitude_mean, "south", "north")) %>%
  group_by(room_type, region) %>%
  summarise(count = n()) %>% 
  pivot_wider(names_from = region, values_from = count) %>% 
  mutate(north = replace_na(north, 0),
         south = replace_na(south, 0),
         diff = south - north)

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- ans5[c("room_type", "diff")]

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie
reviews$year <- format(reviews$date, "%y")
reviews$year = as.numeric(reviews$year)
quantiles <- quantile(listings$number_of_reviews, probs = c(0.4, 0.5))

apartments <- listings %>% 
  filter(quantiles[1] < number_of_reviews & number_of_reviews < quantiles[2])

ans6 <- reviews %>% 
  filter(listing_id %in% apartments$id) %>% 
  mutate(even_odd = ifelse(year %% 2 == 0, "even", "odd")) %>% 
  group_by(listing_id, even_odd) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = even_odd, values_from = count) %>% 
  filter(odd > even)

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- c(length(ans6$listing_id), head(ans6))

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie
ans7 <-listings %>% 
  filter(price < 2500) %>% 
  ggplot(aes(y = room_type, x = price, fill = room_type)) +
  theme(legend.position = "none") +
  geom_boxplot()

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- ans7

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
ans8 <- listings %>% 
  mutate(first_letter = substr(host_name, 1, 1)) %>% 
  group_by(first_letter) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(x = first_letter, y = count)) +
  geom_col()

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- ans8

# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie
ans9 <- listings %>% 
  filter(is.na(price)) %>% 
  ggplot(aes(y = latitude, x = longitude)) +
  geom_point(alpha = 0.6, color = "blue")

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- c(ans9, "widać na wykresie 
                 że rozkład nierównomierny, 
                 kropki zbierają się w większe
                 grupy")

# Zapisanie rozwiązań do plik .RDS ----------------------------------------


# PROSZĘ NIC NIE ZMIENIAĆ  ------------------------------------------------

solutions <- list(ANS_TASK_01, ANS_TASK_02, ANS_TASK_03, 
                  ANS_TASK_04, ANS_TASK_05, ANS_TASK_06,
                  ANS_TASK_07, ANS_TASK_08, ANS_TASK_09)

names(solutions) <- c("Task01", "Task02", "Task03", 
                      "Task04", "Task05", "Task06",
                      "Task07", "Task08", "Task09")


#   -----------------------------------------------------------------------

# Proszę zmienić tylko nazwę pliku w komendzie saveRDS na swoje Nazwisko i Imię (bez polskich znaków)
saveRDS(solutions, file = "MarekSkok.rds")

