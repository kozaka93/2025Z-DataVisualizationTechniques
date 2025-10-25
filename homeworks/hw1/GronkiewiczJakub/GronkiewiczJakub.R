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
odp <- reviews %>% 
  count(reviewer_id) %>% 
  filter(n > 20) %>% 
  nrow()



## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- odp

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

odp <- reviews %>%
  mutate(
    date_poprawna = as.Date(date),
    miesiac = format(date_poprawna, "%m")
  ) %>% 
  count(miesiac) %>% 
  arrange(desc(n))


## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- odp

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

odp <- reviews %>% 
  count(listing_id) %>% 
  filter(n >= 100) %>% 
  left_join(
    listings %>% select(id, price),
    by = c("listing_id" = "id")
  ) %>% 
  arrange(desc(price))


## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- odp[1,3]

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

odp <- reviews %>%
  mutate(date = as.Date(date)) %>% 
  group_by(listing_id) %>%
  summarise(
    najwczesniejsza = min(date, na.rm = TRUE),
    najpozniejsza = max(date, na.rm = TRUE)
  ) %>%
  mutate(
    okres_aktywnosci_lata = as.numeric(najpozniejsza - najwczesniejsza) / 365.25
  ) %>% 
  summarise(
    liczba_apartamentow_10_lat = sum(okres_aktywnosci_lata >= 10, na.rm = TRUE),
    max_okres_lata = max(okres_aktywnosci_lata, na.rm = TRUE)
  )




## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- odp

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie


odp <- listings %>%
  mutate(srodek_lat = mean(latitude, na.rm = TRUE)) %>% 
  mutate(
    polozenie = ifelse(latitude > srodek_lat, "Północ", "Południe")
  ) %>%
  count(room_type, polozenie) %>%
  pivot_wider(
    names_from = polozenie, 
    values_from = n,
    values_fill = 0
  ) %>%
  mutate(
    roznica_poludnie_vs_polnoc = Południe - Północ
  ) %>% 
  select(room_type, roznica_poludnie_vs_polnoc)


## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- odp

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

odp <- reviews %>%
  mutate(
    date = as.Date(date),
    year = as.numeric(format(date, "%Y")), 
    typ_roku = ifelse(year %% 2 == 0, "Parzysty", "Nieparzysty")
  ) %>%
  
  count(listing_id, typ_roku) %>%
  
  pivot_wider(
    names_from = typ_roku,
    values_from = n,
    values_fill = 0
  ) %>%
  
  mutate(
    laczna_liczba_recenzji = Nieparzysty + Parzysty,
    wiecej_nieparzyste = Nieparzysty > Parzysty
  ) %>%
  
  filter(
    laczna_liczba_recenzji >= quantile(laczna_liczba_recenzji, 0.40) &
      laczna_liczba_recenzji <= quantile(laczna_liczba_recenzji, 0.50)
  ) %>%
  
  filter(wiecej_nieparzyste == TRUE) %>% 
  
  summarise(
    liczba_apartamentow = n(),
    laczna_liczba_recenzji_tej_grupy = sum(laczna_liczba_recenzji)
  )



## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- odp

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie
odp <- listings %>%
  filter(price > 0) %>%
  ggplot(aes(x = room_type, y = price, fill = room_type)) +
  geom_boxplot() +
  scale_y_log10(
    breaks = c(10, 25, 50, 100, 200, 500, 1000, 5000)
  ) +
  labs(
    title = "Rozkład cen w zależności od typu pokoju",
    subtitle = "(Użyto skali logarytmicznej na osi Y)",
    x = "Typ pokoju",
    y = "Cena (Skala Log)"
  )



## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- odp

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie

odp <- listings %>%
  filter(!is.na(host_name)) %>%
  mutate(
    pierwsza_litera = substr(host_name, 1, 1),
  ) %>%
  filter(grepl("^[A-Z]$", pierwsza_litera)) %>%
  ggplot(aes(x = pierwsza_litera)) +
  geom_bar(fill = "lightblue") +
  labs(
    title = "Rozkład pierwszych liter imion hostów",
    x = "Pierwsza litera imienia",
    y = "Liczba hostów"
  )


## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- odp


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

odp <- listings %>%
  filter(is.na(price)) %>%
  ggplot(aes(x = longitude, y = latitude)) +
  stat_density_2d_filled() +
  labs(
    title = "Mapa gęstości apartamentów w Seattle bez ceny (price = NA)",
    x = "Długość geograficzna",
    y = "Szerokość geograficzna",
    fill = "Gęstość"
  )

odp
odp <- "NIE"
## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- odp



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
saveRDS(solutions, file = "GronkiewiczJakub.rds")
