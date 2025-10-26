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

reviews <- as_tibble(reviews)
listings <- as_tibble(listings)

# Zadanie 1 (0.5) ---------------------------------------------------------
# Ilu recenzentów wystawiło więcej niż 20 opinii?

## Rozwiązanie
reviews %>%
  count(reviewer_id) %>% 
  count(n>20) -> a
pull(a)[2] -> b

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- b

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie
#names(sort(table(substring(reviews$date,6,7)), decreasing = TRUE))[1]
reviews %>% 
  count(substring(date,6,7))  %>% 
  arrange(-n) #dostajemy posortowaną listę numerów miesięcy, wybieramy największe n

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- "Sierpień, Czerwiec, Lipiec"

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie
reviews %>% 
  count(listing_id) %>% 
  filter(n>100) -> over100
pull(over100[1]) -> over100 # wybieramy apartamenty mające ponad 100 opinii (id)

listings %>% 
  filter(id %in% over100) %>% 
  arrange(-price) %>% 
  first() %>%       # wybieramy pierwszy apartament pod względem najwyższej ceny i podajemy jego cenę
  pull(price) -> c

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- c

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie
years_ago <-  seq(Sys.Date(), by = "-10 years", length = 2)[2] #wybieramy datę 10 lat temu
reviews %>% 
  group_by(listing_id) %>% 
  arrange(date,.by_group = TRUE) %>% 
  filter(date == first(date)) %>%     #wybieramy tylko daty pierwszej opinii
  arrange(date) %>% 
  filter(date < years_ago) %>%    #wybieramy starsze opinie niż 10 lat
  ungroup() %>% 
  summarize(n()) %>% 
  pull() -> a

reviews %>% 
  group_by(listing_id) %>% 
  arrange(date,.by_group = TRUE) %>% 
  filter(date == first(date)) %>%     #wybieramy tylko daty pierwszej opinii
  arrange(date) ->b

as.numeric(substring(Sys.Date(),1,4)) - as.numeric(substring(first(b)$date,1,4)) ->b

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- "Jest ich 394, apartament będący najdłużej na rynku jest od 16 lat"

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie
srodek <- mean(listings$latitude)   #wyznaczamy środek
listings %>% 
  filter(latitude>srodek) %>% 
  summarize(n()) -> polnoc      #wyznaczamy odpowiednio apartamenty na północy i potem na południu

listings %>% 
  filter(latitude<srodek) %>% 
  summarise(n()) -> poludnie

a <- pull(poludnie - polnoc)

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- a

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

d <- reviews %>% 
  count(listing_id, name = "counts") %>% 
  filter(counts >= quantile(counts, 0.4),
    counts < quantile(counts, 0.5))      

reviews %>% 
  filter(listing_id %in% d$listing_id) -> e   #wybieramy apartamenty, które rozpatrujemy

e %>% filter(as.numeric(substring(date,1,4)) %% 2 == 0) -> e1 #lata parzyste
e %>% filter(as.numeric(substring(date,1,4)) %% 2 == 1) -> e2 #lata nieparzyste

count(e1, listing_id) -> e3 #zliczamy odpowiednio ile jest recenzji w latach parzystych i nieparzystych
count(e2, listing_id) -> e4
left_join(e3, e4, by = "listing_id") %>% 
  count(n.x < n.y)

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- "316 takich recenzji, liczba recenzji w latach nieparzystych zapisana w zmiennej e4"

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

listings %>% 
  group_by(room_type) %>% 
  ggplot(aes(x = room_type, y = price))+
  geom_boxplot()+
  scale_y_log10()+
  labs(x = "Rodzaj pokoju",
       y = "Cena (skala logarytmiczna)",
       title = "Rozkład cen apartamentów w zależności od typu pokoju")

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- listings %>% transmute(x = room_type, y = price)

# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie

listings %>% 
  mutate(letter = substring(host_name,1,1)) %>% 
  group_by(letter) %>% 
  summarize(count = n()) %>% 
  arrange(letter) %>% 
  filter(letter != "2")-> f #zliczamy pierwsze znaki imion hostów i usuwamy te, które nie są literami

f %>% ggplot(aes(x = letter, y = count))+
  geom_col()+
  labs(x = "Pierwsza litera imienia",
       y = "Liczba wystąpień",
       title = "Rozkład pierwszych imion hostów")

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- f


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie
listings %>% 
  filter(is.na(price)) %>% 
  transmute(latitude, longitude)-> priceless #współrzędne geograficzne "bezcennych" apartamentów

priceless %>% 
  ggplot(aes(x = longitude, y = latitude))+
  geom_point()+
  labs(title = "Rozkład apartamentów na wynajem w Seattle")
# widzimy, że rozkład nie jest równomierny


## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- "nie, nie jest równomierny"



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
saveRDS(solutions, file = "LabusFilip.rds")


