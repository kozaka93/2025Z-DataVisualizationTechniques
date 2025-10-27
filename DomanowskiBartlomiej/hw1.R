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
#View(reviews)
listings <- read.csv("listings.csv")
#View(listings)
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
(ans_01 <- (reviews %>% 
  group_by(reviewer_id) %>% 
  summarise(reviews_counter = n()) %>% 
  filter(reviews_counter > 20) %>% 
  summarise(number_of_rows=n()))[[1]])




## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- ans_01

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
reviews <- reviews %>% 
  mutate(date = as.Date(date))


(ans_02 <- (reviews %>% 
   mutate(month = format(date, "%B")) %>% 
   group_by(month) %>% 
   summarise(cnt = n()) %>% 
   arrange(-cnt) %>% 
   head(3) %>% 
   select(month)))
  



## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- ans_02


# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

num_of_reviews_from_revies <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(num_of_reviews = n()) %>% 
  rename(id = listing_id)

ans_03 <- (listings %>% 
  left_join(num_of_reviews_from_revies, by = 'id') %>% 
  filter(num_of_reviews > 100) %>% 
  arrange(-price) %>% 
  head(1) %>%  
  select(price))[[1]]


## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- ans_03

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie
longer_than_10 <- reviews %>% 
  inner_join(listings, join_by(listing_id == id)) %>% 
  group_by(id) %>% 
  summarise(min_date = min(date)) %>% 
  mutate(years = as.numeric(as.Date("2025-10-22", format="%Y-%m-%d")- as.Date(min_date, format="%Y-%m-%d"))/365) %>% 
  filter(years > 10) %>% 
  arrange(-years)

how_many <- longer_than_10 %>% 
  unique() %>% 
  summarise(count = n())

max_years <- longer_than_10 %>% 
  summarise(longest = max(as.integer(years)))

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- c(how_many, max_years)

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie

mean_lat <- (listings %>%  
  summarise(mean_lat = mean(latitude)))[[1]]

ans_05 <- listings %>% 
  mutate(side = ifelse(latitude < mean_lat,"south", "north")) %>% 
  group_by(room_type, side) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = side, values_from = count, values_fill = 0) %>% 
  mutate(how_many_more_south = south - north)


## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- ans_05

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

correct_apts <- listings %>% 
  filter(number_of_reviews >= quantile(number_of_reviews, 0.4) & number_of_reviews <= quantile(number_of_reviews, 0.5)) %>% 
  rename(listing_id = id)

correct_apts_id <- correct_apts$listing_id
  
apt_with_more_odd_reviews <- reviews %>% 
  filter(listing_id %in% correct_apts_id) %>% 
  mutate(year = as.numeric(format(date, "%Y")), 
         parity = ifelse(year %% 2 == 0, "even", "odd")) %>% 
  group_by(listing_id, parity) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = parity, values_from = count, values_fill = 0) %>% 
  mutate(total_reviews = even + odd) %>% 
  filter(odd > even) 
  
ans_06 <- apt_with_more_odd_reviews %>%   
  summarise(tmp = sum(total_reviews)) %>% 
  summarise(how_many = n(), total_number_of_reviews = sum(tmp))


## Odpowiedz przypisana do parity## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- ans_06

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie
ans_07 <- listings %>%
  filter(!is.na(price)) %>%
  group_by(room_type) %>%
  summarise(
    meann = mean(price),
    mediann = median(price),
    mini = min(price),
    maxi = max(price),
    .groups = "drop"
  )

(plot_07 <- ggplot(listings, aes(x = room_type, y = price)) + 
  geom_boxplot() + 
  labs(title = "Rozkład cen apartamentów w zależności od typu pokoju", 
       x = "Typ pokoju", 
       y = "Cena apartamentu (log)") + 
  scale_y_log10()) #skala log dla lepszej czytelności

'''
Różni się w zależności od typu pokoju, bo: 
Entire home/apt -> ma dosyć wysokie ceny, ale jest bardzo dużo skrajności 
gdzie ceny bardzo odstają i są bardzo wysokie 

Hotel room - tutaj jest ewidentnie największa rozpiętość cen oraz najwyższa 
mediana cen ogólnie ceny należą do wysokich 

Private room - ewidentnie tańsze i zauważalnie niższa mediana cen z kilkoma
odstjącymi droższymi przypadkami 

Shared room - najtańsza opcja ze wszystkich, tutaj ceny są najbardziej skupione, 
najmniej się zmieniają
'''


## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- ans_07

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
ans_08 <-listings %>% 
  mutate(first_name_letter = substr(host_name,1, 1)) %>% 
  group_by(first_name_letter) %>%  
  summarise(count = n()) %>% 
  filter(grepl("[A-Z]", first_name_letter)) #filter out 2
  
(plot_08 <- ggplot(ans_08, aes(x = first_name_letter, y = count)) + 
  geom_col(color = "#DF5AAA", fill = "pink") + 
  labs(title = "Rozkład pierwszych liter hostów", 
       x = "Pierwsza litera imienia hosta", 
       y = "Ilość wystąpnień"))

'''
Rozkład nie jest równomierny, bo ewidentnie dominują litery A, J, M, S.
Część liter występuje bardzo rzadko.
'''


## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- ans_08


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie
ans_09 <- listings %>% 
  filter(is.na(price))

(plot_09 <- ggplot(ans_09, aes(x = latitude, y = longitude)) + 
  geom_point() + 
  labs(title = "Rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych", 
       x = "Szerokość geograficzna", 
       y = "Długość geograficzna"))

'''
Nie, rozkład nie jest równomierny. Apartementy są raczej skupione w różnych
cześciach miast, np. duże skupienie jest w centrum oraz na wschodzie, lecz 
nie mieści się to w granicy równomierności. Braki cen występują, zatem w kilku (np. centrum)
miejscach
'''

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- ans_09



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

saveRDS(solutions, file = "DomanowskiBartlomiej.rds")

