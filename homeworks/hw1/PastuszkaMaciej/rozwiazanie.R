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
reviewers_20 <- reviews %>% 
  group_by(reviewer_id) %>% 
  summarise(number_of_reviews = n()) %>% 
  filter(number_of_reviews > 20)

ans1 <- reviewers_20 %>% 
  pull(number_of_reviews) %>% 
  length()

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- ans1

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
months <- reviews %>% 
  mutate(
    date = as.Date(date, format = "%Y-%m-%d"),
    month = month.name[as.numeric(format(date, "%m"))]
  ) %>% 
  group_by(month) %>% 
  summarise(number_of_reviews = n()) 

# 6 miesiecy w ktorych wystawiano najwiecej recenzji
top6_months <- months %>% 
  arrange(desc(number_of_reviews)) %>% 
  slice_head(n = 6) %>% 
  pull(month)


## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- top6_months

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy założeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie
# apartamenty z co najmniej 100 recenzjami
apartaments100 <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(number_of_reviews = n()) %>% 
  filter(number_of_reviews >= 100) %>% 
  select(listing_id)
  
prices <- listings %>% 
  select(id, price)

apartaments100 <- apartaments100 %>% 
  left_join(prices,
            by = c("listing_id" = "id")
            ) %>% 
  filter(!is.na(price))

biggest_price <- apartaments100 %>% 
  top_n(n=1, wt=price) %>% 
  pull(price)

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- biggest_price

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie
days_in_year <- 365.25

apartaments10years <- reviews %>% 
  mutate(date = as.Date(date, format="%Y-%m-%d")) %>% 
  group_by(listing_id) %>% 
  summarise(first = min(date),
            last = max(date),
            .groups="drop") %>% 
  mutate(number_of_days = as.numeric(difftime(last, first, units="days")),
         number_of_years = number_of_days / days_in_year) %>% 
  summarise(
    over10 = sum(number_of_years > 10),
    max_years = max(number_of_years)
  )


## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- apartaments10years

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
middle_lat <- mean(listings$latitude)

pos <- listings %>% 
  mutate(where = ifelse(latitude > middle_lat, "north", "south")) %>% 
  group_by(room_type) %>% 
  summarise(south_dominance = sum(where == "south") - sum(where == "north"))

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- pos

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

d <- quantile(listings$number_of_reviews, probs=c(0.4, 0.5), na.rm=TRUE)
d4 <- as.numeric(d["40%"])
d5 <- as.numeric(d["50%"])

apartaments45ids <- listings %>% 
  filter(number_of_reviews >= d4 & number_of_reviews <= d5) %>% 
  pull(id)

apartaments45reviews <- reviews %>% 
  filter(listing_id %in% apartaments45ids) %>% 
  mutate(date = as.Date(date, format="%Y-%m-%d"),
         year = as.numeric(format(date, "%Y"))) %>% 
  group_by(listing_id) %>% 
  summarize(odd_year_dominanace = sum(year %% 2 == 1) - sum(year %% 2 == 0), .groups="drop") %>% 
  filter(odd_year_dominanace > 0)

liczba_apartamentow <- nrow(apartaments45reviews)
## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- apartaments45reviews

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

roomtypeprice <- listings %>% 
  filter(!is.na(price)) %>% 
  select(room_type, price)

ggplot(data = roomtypeprice, aes(x=room_type, y=price)) +
  geom_boxplot() + 
  scale_y_log10() +
  labs(
    title = "Rozkład cen apartamentów w zależności od typu pokoju",
    x = "Typ pokoju",
    y = "Cena"
  )
# entire home/apt -najwiecej wartosci odstajacych, w tym najdrozsze oferty 
# siegajace prawie 10000. Hotel room -najwyzsza mediana, szerokie pudelko, stad
# oferty sa zroznicowane. Private room i Shared room 2 najnizsze mediany
## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- roomtypeprice

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
firstletters <- listings %>% 
  filter(!is.na(host_name)) %>% 
  mutate(first_letter = toupper(substr(host_name, 1, 1))) %>% 
  group_by(first_letter) %>% 
  summarise(occurences = n(), .groups = "drop") %>% 
  filter(first_letter %in% LETTERS)

ggplot(data=firstletters, 
       aes(x=reorder(first_letter, -occurences),
           y=occurences
       )) +
  geom_col() +
  labs(
    x = "pierwsza litera hosta",
    y = "liczba wystapien"
  )

# mozna zauwazyc ze nie liczac litery "A" samogloski raczej nie sa pierwszymi 
# literami nazw hostow

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- firstletters


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie




## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- NA



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
saveRDS(solutions, file = "PastuszkaMaciej.rds")


