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

reviews %>% 
  group_by(reviewer_id)%>% 
  summarise(reviews_count = n()) %>% 
  filter(reviews_count > 20) %>% 
  nrow() -> odp1

odp1

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- odp1

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

reviews %>% 
  transmute(date = as.Date(date, format =  "%Y-%m-%d")) %>% 
  group_by(miesiac = format(date, "%m")) %>% 
  summarise(count_reviews = n()) %>% 
  filter(count_reviews == max(count_reviews)) -> odp2

  odp2 <- as.integer(odp2[1,1])
  odp2
## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- odp2

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

reviews %>% 
  group_by(listing_id) %>% 
  summarise(count_reviews = n()) %>% 
  filter(count_reviews >= 100) %>% 
  select(listing_id) -> tmp
  
  colnames(tmp) <- c("id")
  
  inner_join(tmp, listings, by = "id") %>% 
    arrange(desc(price)) %>% 
    head(1) %>% 
    select(price) -> odp3

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- odp3[1,1]

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

reviews %>%
  group_by(listing_id) %>% 
  transmute(date_diff = as.numeric(difftime(as.Date(Sys.Date(), format="%Y-%m-%d"), as.Date(min(date), format="%Y-%m-%d"), 
  unit="days"))/365.25) %>% 
  unique() %>% 
  filter(date_diff > 10) %>%  
  arrange(desc(date_diff)) -> odp4
  

  odp4 <- c(nrow(odp4), odp4[1,2])

  odp4


## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- odp4

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie

mean_lat <- mean(listings$latitude)

listings %>% 
  mutate(south = ifelse(latitude < mean_lat, 1, -1)) %>% 
  group_by(room_type) %>% 
  summarise(suma_wartosci = sum(south, na.rm = TRUE)) -> odp5



## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- odp5

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

decyle <- quantile(probs = seq(0.1, 1, 0.1), listings$number_of_reviews)

listings %>% 
  filter((number_of_reviews > decyle[4]) & (number_of_reviews < decyle[5])) -> tmp




reviews %>%  
  filter(listing_id %in% tmp$id) %>% 
  mutate(rok = as.integer(format(as.Date(date, format = "%Y-%m-%d"), "%Y"))) %>% 
  mutate(rok_parzysty = ifelse(rok %% 2 == 0, -1, 1)) %>% 
  group_by(listing_id) %>% 
  summarise(suma_wartosci = sum(rok_parzysty, na.rm = TRUE)) %>% 
  filter(suma_wartosci > 0) -> tmp
  
  odp6 <- c(nrow(tmp), sum(tmp[,2]))
## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- odp6

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda Rozkład cen apartamentów w zależności od typu pokoju?

listings %>% 
  select(price, room_type) %>% 
  filter(!is.na(price)) -> odp7

ggplot(listings, aes(x = price, y = room_type,fill = room_type))+
geom_violin()+
  scale_x_log10()+
  labs(title = "Rozkład cen apartamentów w zależności od pokoju", y = "typ pokoju", x = "cena")+
  theme(legend.position="none")
  

## Rozwiązanie




## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- odp7

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie
listings %>% 
  mutate(first_letter = substring(host_name,1,1)) %>% 
  filter(first_letter %in% toupper(letters)) %>% 
  group_by(first_letter) %>% 
  count(name = "count")  -> odp8
odp8 %>% 
ggplot(aes(x = first_letter, y = count))+
  geom_col()+
  labs(title = "Rozkład pierwszych liter imion hostów", x  = "litera", y = "liczba wystąpień")+
  scale_y_continuous(breaks = round(seq(0, 800, by = 100),1))

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- odp8


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

listings %>% 
  filter(is.na(price)) %>% 
  select(latitude, longitude)-> odp9

odp9 %>% 
  
ggplot(aes(y = latitude, x=longitude))+
  geom_jitter(size = 1.5,alpha = 0.3) +
  geom_point(colour = "red")+
  labs(title = "Rozkład apartamentów w Seatle bez podanej ceny")
  

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- odp9



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
saveRDS(solutions, file = "MierzejewskiJulian.rds")


