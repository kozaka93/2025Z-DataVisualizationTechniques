###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           PRACA DOMOWA 1            ###
###########################################

# Ładowanie pakietów-----------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
# Ładowanie danych --------------------------------------------------------

reviews <- read.csv("C:/Users/klemi/Documents/studia/sem3/twd/reviews.csv")
listings <- read.csv("C:/Users/klemi/Documents/studia/sem3/twd/listings.csv")

View(listings)
View(reviews)

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
ncom_by_reviewer <- reviews %>% group_by(reviewer_id) %>% 
  summarise(n_reviews = n()) %>% 
  filter(n_reviews > 20)

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- nrow(ncom_by_reviewer)

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
reviews$date <- as.Date(reviews$date)
reviews$month <- format(reviews$date, "%B")

ncom_by_month <- list((reviews %>% 
  group_by(month) %>% 
  summarise(n_reviews = n()) %>% 
  arrange(desc(n_reviews)))[1:4,1])

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- ncom_by_month

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

# wybieramy id apartamentow z reviews dla ktorych liczba komentarzy >= 100
apt_100_com <- reviews %>% group_by(listing_id) %>% 
  summarise(n_reviews = n()) %>%
  filter(n_reviews >= 100) %>% .$listing_id

# korzystajac z tych id wybieramy je w listings i sortujemy po cenie
min100com_maxprice <- listings %>% 
  filter(id %in% apt_100_com) %>% 
  arrange(desc(price))

## Odpowiedz przypisana do zmiennej

ANS_TASK_03 <- min100com_maxprice$price[1]

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

min_10_years <- reviews %>% 
  group_by(listing_id) %>%
  summarise(first_review = min(date, na.rm = TRUE)) %>%  
  mutate(years = as.numeric(Sys.Date() - first_review)/365) %>% 
  filter(years > 10)


## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- c(nrow(min_10_years), max(min_10_years$years))

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
center <- mean(listings$latitude, na.rm = TRUE)

temp2 <- listings %>% 
  mutate(north_south = ifelse(latitude >= center, "north", "south")) %>% 
  relocate(north_south, .after = latitude) %>% count(room_type, north_south) %>% 
  group_by(room_type, north_south) %>% 
  pivot_wider(names_from = north_south, values_from = n, values_fill = 0) %>% 
  summarise(south_minus_north = south - north)

p <- list(ifelse(temp2$south_minus_north > 0, 
            paste(temp2$room_type, "- Na poludniu jest wiecej o", temp2$south_minus_north),
            paste(temp2$room_type, "- Na pólnocy jest wiecej o", abs(temp2$south_minus_north))))

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- p

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

# Rozwiązanie

dec <- quantile(listings$number_of_reviews, probs = c(0.4, 0.5), na.rm = TRUE)

# kolumna even_odd - czy rok wystawienia recenzji byl parzysty czy nieparzysty
temp3 <- reviews %>% group_by(listing_id) %>%
  mutate(tot_rev = n()) %>%
  filter((tot_rev >= dec[1]) & (tot_rev <= dec[2])) %>%
  mutate(even_odd = ifelse((as.numeric(format(as.Date(date), "%Y"))) %% 2 == 0, "even", "odd"))

# nr_rev - kolumna, z wartosciami, ktore pokazuja ile recenzji bylo wystawione
# dla danego apartamentu w latach parzystych/nieparzystych

temp4 <- temp3 %>% group_by(listing_id, even_odd) %>% summarise(nr_rev = n()) %>%
  pivot_wider(names_from = even_odd, values_from = nr_rev, values_fill = 0) %>%
  filter(odd > even)

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- c(nrow(temp4),
  sum(temp4$odd + ifelse(is.na(temp4$even), 0, temp4$even)))



# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

listings %>% 
  select(id, room_type, price)

listings %>% 
  ggplot(mapping = aes(x = as.factor(room_type), y = price, color = room_type)) + 
  geom_boxplot(outlier.color = 'black') +
  labs(x = 'Typ pokoju',
       y = 'Cena',
       title = 'Rozklad cen apartamentów w zależności od typu pokoju (skala log)') +
  scale_y_log10() +
  theme_bw() -> a

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- '
Wśród wszystkich kategorii najwyższa wartość średnia jest dla
Hotel Room. Również dla tej kategorii obserwujemy spore zróżnicowanie cen
i praktycznie brak wartości odstających (tylko jedna, dziwnie niska).
Co ciekawe zupelnie inaczej ceny rozkladają się dla kategorii
Entire home/room apt, gdzie są one generalnie znacznie mniej zróżnicowane,
ale za to jest bardzo dużo outlierów.

Dla Private Room oraz Shared room ceny w ich kategoriach są stosunkowo
podobne i najniższe, aczkolwiek jest parę pokoi 
z tej pierwszej kategorii, które ewidentnie odbiegają cenowo od reszty.'

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
listings %>%
  mutate(host_first_letter = as.character(substr(host_name, 1, 1))) %>% 
  filter(host_first_letter %in% c(letters,LETTERS)) %>% 
  ggplot(mapping = aes(x = host_first_letter)) + 
  geom_bar(color = "black", fill = "darkgreen") +
  labs(title = "Rozkład pierwszych liter imion hostów",
       x = "Pierwsza litera imienia",
       y = "Liczba hostów")

## Odpowiedz przypisana do zmiennej WROC
ANS_TASK_08 <- 'Rozklad jest co ciekawe zupelnie nierównomierny. 
Jak widać litery A,B,J,M,S są znacznie bardziej popuarne jako początek nazwy
niż chociażby O,Q,U,X,Z nie użyte prawie wcale.'


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

center_lat <- mean(listings$latitude, na.rm = TRUE)
center_long <- mean(listings$longitude, na.rm = TRUE)

listings %>% 
  filter(is.na(price)) %>% 
  ggplot(mapping = aes(x = latitude, y = longitude)) + 
  geom_point(alpha = 0.6) + 
  geom_point(aes(x = center_lat, y = center_long),   # punkt środka
             color = "maroon", size = 4, shape = 10) +
  labs(title = "Rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych", 
         x = "Szerokość geograficzna", 
         y = "Długość geograficzna")


## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- 'W centrum jest nieco większe skupisko
tego typu apartamentów, ale nie jest to równomierny rozklad'



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
saveRDS(solutions, file = "MagdalenaForowicz.rds")


