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

View(reviews)
View(listings)

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

stats <- reviews %>% 
  count(reviewer_id) %>% 
  filter(n>20) %>% 
  summarise(ilosc_recenzentow = n())
stats

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- stats

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

miesiace <- reviews %>%
  mutate(miesiac = format(as.Date(date),"%m")) %>% 
  group_by(miesiac)%>%
  summarise(recenzje = n()) %>% 
  top_n(3,recenzje) %>% 
  select(miesiac)

miesiace

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- miesiace

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

ponad100rec <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(n = n()) %>% 
  filter(n>100)


cena <- listings %>% 
  filter(id %in% ponad100rec$listing_id) %>% 
  slice_max(price)

cena <- cena$price  
cena

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- cena

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

ponad10lat <- reviews %>%
  filter(as.Date(date) < Sys.Date() - 3652) %>% 
  group_by(listing_id) %>% 
  summarise(ponad_10_lat = n()) %>% 
  count()

ponad10lat

#najstarsze

najstarsze <- reviews %>% 
  slice_min(as.Date(date))

najstarsze

rok <- as.numeric(substr(najstarsze$date,1,4))
rok_teraz <- as.numeric(format(Sys.Date(), "%Y"))
ile_na_rynku <- rok_teraz-rok
ile_na_rynku

razem <- c(ponad10lat,ile_na_rynku)
razem

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- razem

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie

ile_wiecej <- listings %>% 
  group_by(room_type) %>% 
  summarise(srednia = mean(latitude, na.rm = TRUE), 
            poludnie = sum(latitude < srednia), 
            polnoc = sum(latitude > srednia),
            roznica = poludnie - polnoc) %>%
  mutate(gdzie_wiecej = case_when(
        roznica > 0 ~ "południe",
        roznica < 0 ~ "północ", 
        roznica == 0 ~ "tyle samo")) %>% 
  select(room_type,gdzie_wiecej)


ile_wiecej
## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- ile_wiecej

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

View(listings)

n_reviews <- reviews %>%
  group_by(listing_id) %>%
  summarise(n = n())

decyle_45 <- quantile(n_reviews$n, probs = c(0.4, 0.5))

apartamenty <- n_reviews %>%
  filter(n >= decyle_45[1], n <= decyle_45[2])

policzone <- reviews %>%
  mutate(year = as.numeric(format(as.Date(date), "%Y"))) %>%
  filter(listing_id %in% apartamenty$listing_id) %>%
  group_by(listing_id) %>%
  summarise(
    nieparzyste = sum(year %% 2 == 1, na.rm = TRUE),
    parzyste = sum(year %% 2 == 0, na.rm = TRUE)
  ) %>%
  filter(nieparzyste > parzyste) %>%
  summarise(
    l_apartamentow = n(),
    liczba_recenzji_wiecej = sum(nieparzyste))
  

policzone

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- policzone

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

lista_rozklad <- listings %>%
  drop_na(price, room_type)%>%
  group_by(room_type) %>%
  summarise(ile = n(),
            srednia = mean(price, na.rm = TRUE),
            mediana = median(price, na.rm = TRUE),
            odchylenie_std = sd(price, na.rm = TRUE),
            min = min(price, na.rm = TRUE),
            Q1 = quantile(price, 0.25, na.rm = TRUE),
            Q3 = quantile(price, 0.75, na.rm = TRUE),
            max = max(price, na.rm = TRUE),
            zakres = max - min)

listings %>% 
  drop_na(price, room_type) %>% 
  ggplot(aes(x = room_type, y = price)) +
  geom_boxplot() +  
  scale_y_log10() +
  labs(title = "Rozkład cen apartamentów w zależności od typu pokoju",
       x = "Typ pokoju", y = "Cena")

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- lista_rozklad

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie

ile_hostow <- listings%>%
  drop_na(host_name)%>%
  mutate(pierwsza_litera = toupper(substr(host_name, 1, 1))) %>%
  filter(pierwsza_litera %in% LETTERS) %>%
  count(pierwsza_litera) %>%
  arrange(desc(n))

ile_hostow

ggplot(ile_hostow, aes(x = reorder(pierwsza_litera,-n), y=n)) +
  geom_col() +
  labs(title="Rozkład pierwszych liter hostów" ,x="Pierwsza litera nazwy hosta", y="Liczba hostów")

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- ile_hostow


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

rozklad_brakow <- listings %>%
  group_by(neighbourhood) %>%
  summarise(
    brak_ceny = sum(is.na(price)),
    liczba_apartamentow = n()
  ) %>%
  mutate(braki = brak_ceny / liczba_apartamentow)

rozklad_brakow

ggplot(rozklad_brakow,aes(x = reorder(neighbourhood, braki), y = braki)) +
  geom_col() + coord_flip() + labs(x="Dzielnica", y="Frakcja brakujących cen", title="Rozkład brakujących cen w zależności od dzielnicy w Seattle")
  


## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- rozklad_brakow



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
saveRDS(solutions, file = "KozlowskaBarbara.rds")


