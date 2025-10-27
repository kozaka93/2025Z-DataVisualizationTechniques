###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           PRACA DOMOWA 1            ###
###########################################

# Ładowanie pakietów-----------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# Ładowanie danych --------------------------------------------------------

#reviews <- read.csv("C:/Users/pzbzb/OneDrive/Pulpit/STUDIA/SEM3/TWD/reviews.csv")
#View(reviews)
#listings <- read.csv("C:/Users/pzbzb/OneDrive/Pulpit/STUDIA/SEM3/TWD/listings.csv")
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
answ1 <- reviews %>%
  group_by(reviewer_id) %>%
  summarise(number_of_reviews=n()) %>%
  filter(number_of_reviews>20) %>%
  nrow()

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- answ1

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
answ2 <- reviews %>%
  mutate(month = format(as.Date(date), "%m")) %>% #wyciagam tylko miesiace
  mutate(month=month.name[as.numeric(month)]) %>% #zamieniam numery na nazwy dla lepszej czytelnosci
  group_by(month) %>%
  summarise(reviews_per_month = n()) %>%
  arrange(-reviews_per_month) %>% #malejąco zeby na gorze byly z najwieksza iloscia recenzji
  top_n(2) %>%
  pull(month)
  
  ## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- paste("Two months with most reviews published are", paste(answ2, collapse=" and "))

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

good_hotels <- reviews %>%
  group_by(listing_id) %>%
  summarise(listing_reviews=n()) %>%
  filter(listing_reviews >= 100) %>%
  pull(listing_id) #wyciagam id apartamentow ktore spelniaja reviews >=100

answ3 <- listings %>%
  filter(id %in% good_hotels) %>% #biore pod uwage tylko dobre apartamenty
  top_n(1, price) %>%
  pull(price) #wyciagam najwieksza cene




## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- answ3

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

today <- as.Date("2025-10-26")

exc4 <- reviews %>%
  mutate(date=as.Date(date)) %>%
  group_by(listing_id) %>%
  summarise(min_date = min(date)) %>% #dla kazdego ID dobieram najstarsza recenzje
  mutate(date_dif = as.numeric(today-min_date)/365) %>%
  filter(date_dif > 10)
  
answ4_1 <- nrow(exc4) # ile jest tych apartamentow
answ4_2 <- exc4 %>% # wyciagam najstarszy
  top_n(1,date_dif) %>%
  pull(date_dif)

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- paste("There are", answ4_1, "apartments that exist for at least 10 years. Also the oldest apartment exists for", round(answ4_2,2), "years.")

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
center <- mean(listings$latitude)

answ5 <- listings %>% 
  mutate(place = ifelse(latitude > center, "North", "South")) %>% #dodanie etykiety south/north
  count(room_type, place) %>%
  pivot_wider(names_from = place, values_from = n, values_fill = 0) %>% #zamieniam macierz zeby łatwiej bylo policzyc roznice
  mutate(dif = South - North) %>%
  select(room_type,dif)


## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- answ5

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

decils <- quantile(listings$number_of_reviews, prob=c(0.4,0.5), na.rm=TRUE)

good_ids <- listings %>% #wybieram tylko te hotele, ktorych recenzje sa w danych decylach
  filter(number_of_reviews >= decils[1] & number_of_reviews <=decils[2]) %>%
  pull(id) 

answ6 <- reviews %>%
  filter(listing_id %in% good_ids) %>% #te dobre hotele
  mutate(year = as.numeric(substr(date,1,4))) %>% #wyodrebniam rok i zmieniam na numeryczny
  mutate(iseven = ifelse(year%%2==0, "EVEN", "ODD")) %>% #do pozniejszego porownania
  count(listing_id,iseven) %>%
  pivot_wider(names_from=iseven,values_from=n, values_fill=0) %>% #zmieniam macierz aby byla czytelniejsza
  filter(ODD>EVEN) %>% #wybieram tylko te dla ktorych jest wiecej np. recenzji  
  mutate(difference = ODD-EVEN) %>%
  select(listing_id,difference)

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- answ6

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie


answ7 <- listings %>%
  select(room_type,price) %>%
  filter(!is.na(price))


ggplot(answ7, aes(x=room_type,y=price,fill=room_type)) +
  geom_violin() +
  scale_y_log10(expand=c(0,0)) +
  labs(x="Room type", y="Price") +
  theme(legend.position = "None")
  



## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- answ7

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie

answ8 <- listings %>%
  mutate(FirstLetter = substr(host_name,1,1)) %>%
  group_by(FirstLetter) %>%
  summarise(FirstLetter_number = n()) %>%
  filter(grepl("^[A-Za-z]$", FirstLetter))

ggplot(answ8, aes(x=FirstLetter, y= FirstLetter_number)) +
  geom_col(fill="blue") +
  labs(x="First letter", y="Count") +
  scale_y_continuous(expand=c(0,0))



## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- answ8


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie
answ9 <- listings %>%
  filter(is.na(price))

ggplot(answ9, aes(y=latitude,x=longitude)) +
  geom_density_2d_filled() +
  labs(x="Longtitude", y="Latitude", title="Hotels location in Seatle with unknown price") +
  scale_y_continuous(expand=c(0,0)) +
  scale_x_continuous(expand=c(0,0))

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- answ9



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
saveRDS(solutions, file = "ZakrzewskiPawel.rds")



