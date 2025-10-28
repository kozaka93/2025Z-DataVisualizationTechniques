###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           PRACA DOMOWA 1            ###
###########################################

# Ładowanie pakietów-----------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
install.packages("stringi")
library(stringi)
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

task_1 <- reviews %>% 
  count(reviewer_id) %>% 
  filter(n>20) %>% 
  count() %>% 
  pull(n)
task_1

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- task_1
# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

task_2 <- reviews %>% 
  mutate(month=format(as.Date(date),"%m")) %>% 
  count(month) %>% 
  arrange(desc(n)) %>% 
  slice_head(n=3) %>% 
  pull(month)
  
task_2

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- "Sierpień, Czerwiec, Lipiec"
# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie
task_3 <- reviews %>% 
  count(listing_id) %>% 
  filter(n>100)
task_3 <- left_join(task_3,listings,by=c("listing_id" ="id"))
task_3 <-task_3 %>% 
  arrange(desc(price)) %>% 
  slice_head(n=1) %>% 
  pull(price)
 ## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- task_3
# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?


## Rozwiązanie

today <- as.Date("2025-10-28", format="%Y-%m-%d")
task_4 <- reviews %>% 
  group_by(listing_id) %>%
  summarise(min_year = min(as.Date(date, format="%Y-%m-%d"))) %>%
  mutate(time_on_market = as.numeric(today - min_year, units="days") / 365) %>%
  summarise(ten_years_apartments = sum(time_on_market > 10),max_time = max(time_on_market))
  




## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- task_4

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

middle <-mean(listings$latitude)
task_5 <- listings %>% 
  group_by(room_type) %>% 
  transmute(north = latitude > middle,
            south = latitude <= middle) %>% 
  summarise(south_minus_north = sum(south) - sum(north))
  
  




## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- task_5


# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

deciles <- quantile(listings$number_of_reviews, probs=seq(0, 1, 0.1), na.rm=TRUE)
decile4 <- deciles["40%"]
decile5 <- deciles["50%"]


task_6 <- listings %>% 
  filter(number_of_reviews>=decile4 & number_of_reviews<=decile5  ) 
task_6 <- semi_join(reviews,task_6, by = c("listing_id" = "id"))
task_6 <- task_6 %>% 
  mutate(year=as.numeric(format(as.Date(date),"%y"))) %>% 
  group_by(listing_id) %>%
  summarise(rev_parz = sum(year %% 2 == 0, na.rm = TRUE),rev_nieparz = sum(year %% 2 == 1, na.rm = TRUE)) %>% 
  mutate(nieparz_minus_parz=rev_nieparz-rev_parz)
  
task_6a <- task_6 %>% 
  count(nieparz_minus_parz>0)

task_6a
task_6b <- task_6 %>% 
  filter(nieparz_minus_parz>0) %>% 
  summarise(suma=sum(nieparz_minus_parz))
task_6b
## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- " 348 , różnica to 3030 recenzji"

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

task_7<- listings %>% select(price,room_type)

plot_7<- ggplot(listings,aes(x=price))+
  geom_histogram(bins=30,fill="lightblue",color="black")+
  facet_wrap(~room_type,scales="free")
plot_7

#podzieliłem to na 4 wykresy aby można było zauważyć rozkład cen shared room i hotel room
#których jest mało na tle innych apartamentów
#Entire home - silnie prawostronnie skośny, większość tańszych niż ~500
#Hotel room - nie wiele obserwacji , kilka tańszych niż 350, najwięcej w okolicy 1000
#Private Room - podobnie jak dla entire home
#Shared room - mało obserwacji, wszystkie nie droższe niż 150
#podsumowanie - średnjo najtańsze są shared room, potem private room, potem entire home, potem hotel room

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- task_7


# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?



## Rozwiązanie

zad_8 <-listings %>% 
  mutate(p_litera=stri_extract_first_regex(host_name, "[A-Za-z]")) %>% 
  group_by(p_litera) %>% 
  count
zad_8
ggplot(zad_8,aes(x=p_litera,y=n))+
  geom_col(fill="lightblue")+
  labs(title="Ile razy dana litera występuje jako pierwsza w imieniu hosta",y="ilość",x="litera")

#najwięcej imion zaczyna się na literę A,B,J,M,S. A prawie żadne na Q,U,X. 
#nie jest on równomierny


## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- zad_8

# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

zad_9 <-listings %>% 
  
  mutate(czy_na=if_else(is.na(price),"price is na","price is given")) %>% 
  select(longitude,latitude,czy_na)
zad_9

plot_9 <- ggplot(zad_9,aes(x=longitude,y=latitude,color=czy_na,alpha = czy_na))+
  geom_point()+
  scale_alpha_manual(values = c(0.2,1))+
  guides(alpha = "none")+
  scale_colour_manual(values=c("lightblue","navy"),name="czy jest podana cena",labels=c("jest","nie ma"))+
  labs(title="Rozkład apartamentów bez podanej ceny na tle wszystkich w Seattle",x="szerokośc geograficzna",y="długość geograficzna")

plot_9

# patrząc na rozkład apartamentów bez podanej ceny na tle całego miasta nie jest-
# równomierny. są większe skupiska ale i również obszary bez żadnych występowań
# jednakżde jeżeli spojrzymy na rozkład ich na tle wszystkich apartamentów w mieśćie-
# zauważymy że nie ma żadnego wzorca w którym obszarze występuję wyjątkowo więcej apartamntów -
# bez podanej ceny w stosunku do wszystkich 
 ## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- zad_9


# Zapisanie rozwiązań do plik .RDS ----------------------------------------


# PROSZĘ NIC NIE ZMIENIAĆ  ------------------------------------------------

solutions <- list(ANS_TASK_01, ANS_TASK_02, ANS_TASK_03, 
                  ANS_TASK_04, ANS_TASK_05, ANS_TASK_06,
                  ANS_TASK_07, ANS_TASK_08, ANS_TASK_09)

solutions

names(solutions) <- c("Task01", "Task02", "Task03", 
                      "Task04", "Task05", "Task06",
                      "Task07", "Task08", "Task09")


#   -----------------------------------------------------------------------

# Proszę zmienić tylko nazwę pliku w komendzie saveRDS na swoje Nazwisko i Imię (bez polskich znaków)
saveRDS(solutions, file = "LachowiczSzymon.rds")




