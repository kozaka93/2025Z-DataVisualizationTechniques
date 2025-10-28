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

more_than_20 <- reviews %>% 
  group_by(reviewer_id) %>% 
  summarise(reviews_number = n(), .groups = "drop") %>% 
  filter(reviews_number > 20) %>% 
  nrow()
# Na początku grupujemy względem reviewer_id, a następnie liczymy liczbę 
# recenzji danej osoby i filtrujemy, aby zostali tylko ci, którzy wystawili 
# powyżej 20 recenzji. Wynik to liczba wierszy ramki danych zawierającej 
# tylko recenzentów, którzy wystawili ponad 20 opinii - 32.

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- more_than_20

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
top_months <- reviews %>% 
  mutate(month = format(as.Date(date), "%B")) %>% 
  group_by(month) %>% 
  summarize(reviews_number = n()) %>% 
  arrange(desc(reviews_number)) %>% 
  slice_head(n = 3) 
# Najpierw wyciągamy z daty nazwę miesiąca i grupujemy względem jej, a następnie
# liczymy liczbę recenzji w poszczególnych miesiącach i względem jej sortujemy.
# Na koniecnwybieramy miesiące z największą liczbą recenzji, tutaj np. wzięłam 
# 3 - sierpień, czerwiec, lipiec.

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- top_months$month
  
# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie
#Tworzymy tabelę, która przechowuje id apartamentów z min 100 recenzjami.
apartments <- reviews %>%
  group_by(listing_id) %>% 
  summarise(reviews_number = n()) %>% 
  filter(reviews_number >= 100)

# Na podstawie tabeli apartments znajdujemy najwyższą cenę za apartament.
# z min 100 recenzjami
max_price <- listings %>% 
  filter(id %in% apartments$listing_id) %>% 
  top_n(1, price)
#Maksymalna cena to 1012 zł.

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- max_price$price

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie
# Filtrujemy apartamenty, które są na rynku dłużej niż 10 lat. W tym celu
# policzyłam różnicę między dzisiejszą datą a datą najstarszej opinii o danym
# apartamencie, a następnie przefiltrowałam, zostawiając tylko te id apartamentów,
# dla których liczba lat na rynku była większa niż 10, oraz posortowałam malejąco.

apartments_min_10 <- reviews %>%
  mutate(date = as.Date(date)) %>%                          
  group_by(listing_id) %>%
  summarise(
    min_date = min(date, na.rm = TRUE),
    ile_lat  = as.numeric(difftime(Sys.Date(), min_date, units = "days")) / 365,
    .groups = "drop"
  ) %>%
  filter(ile_lat > 10) %>%
  arrange(desc(ile_lat))


## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- c(nrow(apartments_min_10), apartments_min_10$ile_lat[1])

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
# Tworzymy zmienną przechowującą środek 
middle <- mean(listings$latitude, na.rm = TRUE)

# Dodajemy kolumnę określającą położenie względem środka, następnie grupujemy względem
# typu apartamentu i liczymy różnicę między liczbą apartamentów na południu i na północy.
south_vs_north <- listings %>% 
  mutate(region = if_else(latitude < middle, "south", "north")) %>% 
  group_by(room_type) %>% 
  summarise(difference = sum(region == "south") - sum(region == "north"), 
            .groups = "drop") %>% 
  arrange(room_type)
# Wyniki dodatnie oznaczają, że więcej jest apartamentów danego typu na południu, 
# a ujemne - na północy.

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- north_vs_south

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie
decyl_4 <- quantile(listings$number_of_reviews, 0.4, na.rm = TRUE)
decyl_5 <- quantile(listings$number_of_reviews, 0.5, na.rm = TRUE)

filtered_listings <- listings %>%
  filter(number_of_reviews >= decyl_4 & number_of_reviews <= decyl_5) %>% 
  select(id)

more_odd <- reviews %>%
  filter(listing_id %in% filtered_listings$id) %>%
  mutate(year = as.integer(format(as.Date(date), "%Y"))) %>%
  group_by(listing_id) %>%
  summarise(
    odd  = sum(year %% 2 == 1),
    even = sum(year %% 2 == 0),
    diff = odd - even,
    .groups = "drop"
  ) %>%
  filter(diff > 0) %>% 
  select(listing_id, diff)

n_apartments <- nrow(more_odd)

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- list(n_apartments, more_odd)

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie
#Stworzymy tabelę, która będzie zawierała dane przedstawione na wykresie
price_distrib_by_type <- listings %>% 
  group_by(room_type) %>% 
  summarise(min_price = min(price, na.rm = TRUE),
            quantile_25 = quantile(price, 0.25, na.rm = TRUE),
            median = median(price, na.rm = TRUE),
            quantile_75 = quantile(price, 0.75, na.rm = TRUE),
            max_price = max(price, na.rm = TRUE))

#Tworzymy wykres skrzynkowy ilustrujący dane z tabeli
ggplot(listings, aes(x = room_type, y = price)) +
  geom_boxplot(na.rm = TRUE, outlier.color = "red") +
  scale_y_log10() +
  labs(x = "Typ pokoju", y = "Cena (log10)", title = "Ceny wg typu pokoju (skala log)")
#Hotel room ma najwyższą medianę, a standardowe ceny (wewnątrz pudełka) są najbardziej zróżnicowane. 
#Entire home/apt ma największy rozrzut cenowy ofert, co sugeruja długie "wąsy" i wiele outlierów.
#Private room cechuje niższa mediana, a środkowe 50% apartamentów mieści się w wąskim przedziale cen,
#natomiast shared room ma najniższą medianę i stosunkowo wąski rozkład cen.

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- price_distrib_by_type

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
letter_distribution <- listings %>%
  filter(!is.na(host_name), host_name != "") %>%
  mutate(first_letter = substr(host_name, 1, 1)) %>%
  filter(first_letter >= "A", first_letter <= "Z") %>% 
  group_by(first_letter) %>% 
  summarize(count = n())

ggplot(letter_distribution, aes(x = first_letter, y = count)) +
  geom_col(fill = 'navy') +
  labs(title = "Rozkład pierwszej litery imienia hosta",
       x = "Pierwsza litera",
       y = "Liczba hostów")
# Najpopularniejze litery to M, J, A (z ponad 600 obserwacjami), natomiast 
# najmniej popularne - Q, U, X (poniżej 10 obserwacji dla każdej z liter).
## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- letter_distribution


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie
apartments_without_price <- listings %>% 
  filter(is.na(price)) %>% 
  select(neighbourhood_group, latitude, longitude, price)

ggplot(apartments_without_price, aes(x = longitude, y = latitude)) +
  geom_point(alpha = 0.5) +
  geom_density_2d(color = "red", linetype = "dashed", size = 0.6) + 
  labs(title = "Apartamenty bez ceny w Seattle – rozkład",
       x = "Długość geograficzna",
       y = "Szerokość geograficzna")

# Rozkład apartamentów nie jest równomierny, występuje parę skupisk, 
# a zageszczenia punktów widoczne są na układzie poziomic.

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- apartments_without_price



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
saveRDS(solutions, file = "TarlowskaZofia.rds")



