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
#View(reviews)
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


k <- reviews %>% 
  group_by(reviewer_id) %>% 
  summarise(liczbaRecenzji = n()) %>% 
  filter(liczbaRecenzji > 20) %>% 
  summarise(n()) %>% as.numeric()
#k

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- k # 32

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

library(stringr)

months <-  as.numeric(
  reviews$date %>% 
    str_extract("-..-") %>% 
    str_remove_all("-"))

(tab <- table(factor(month.name[months], levels = month.name)))

(NajczestszeMiesiace <- sort(tab,decreasing = TRUE))

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- NajczestszeMiesiace

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

PopularneID <- reviews %>% 
  group_by(listing_id) %>% 
  summarise(LiczbaRecenzji = n()) %>%
  filter(LiczbaRecenzji >= 100 )

NajdrozszaOferta <- merge(PopularneID,listings[,c("id","price")],by.x ="listing_id",by.y="id") %>% 
  top_n(1,wt=price)

NajdrozszaOferta["price"]


## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- NajdrozszaOferta["price"] # 1012

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie


daty <- as.Date( reviews$date )

# Jaka data byla 10 lat temu?
dziesiecLatTemu <- seq(Sys.Date(), length = 2, by = "-10 years")[2]

NajstarszeApart <- reviews %>%  
  select(listing_id,date)%>%
  filter(daty < dziesiecLatTemu) %>% 
  group_by(listing_id) %>% 
  summarise(Najstarszy_Wpis = min(date)) %>% 
  arrange(Najstarszy_Wpis)

NajstarszeApart # tabela z id apartamentow, ktore byly ocenianie >10lat temu, oraz data najstarszej recenzji


ileStarych <- dim(NajstarszeApart)[1]  # 392 (zależy od momentu uruchomienia skryptu)
#ileStarych 

NajstarszyLokal <- NajstarszeApart[1,]
NajstarszyLokal[1,2]
## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- paste("Jest",ileStarych,"apartamentow starszych niz 10 lat. Najstarszy wpis jest z ",NajstarszyLokal[1,2])




# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie

srednia_szerokosc <- mean(listings$latitude)
srednia_szerokosc # 47.626

df <- listings %>% 
  mutate(NS = ifelse(latitude > srednia_szerokosc,"NORTH","SOUTH")) %>% 
  select(room_type,NS) %>% 
  group_by(room_type,NS) %>% 
  summarise(liczba = n()) %>% 
  pivot_wider(values_from = liczba,names_from = NS,values_fill = 0) %>% 
  transmute(Ile_Wiecej_Na_Poludniu=SOUTH-NORTH)

df 
## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- df





# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?


## Rozwiązanie
(liczba_recenzji <- reviews %>%  
  group_by(listing_id) %>%
  summarise(liczba_recenzji = n()))

(q <- quantile(liczba_recenzji$liczba_recenzji,probs = c(0.4,0.5)))

mask <- liczba_recenzji %>% filter( q[1] < liczba_recenzji & liczba_recenzji <q[2])

# Wybieram tylko recenzje miedzy 4, a 5 decylem
OgraniczoneReviews <- reviews %>% 
  semi_join(mask,by="listing_id") %>%
  select(listing_id,date)

# Z kazdego wpisu wybieram rok
Lata <- OgraniczoneReviews$date %>%  str_extract("....") %>% as.numeric()

# Tablica z liczba recencji z parzystych i nieparzystych lat dla kazdego lsiting_id
# I roznica miedzy nimi
df <- OgraniczoneReviews %>% 
  mutate(Nieparzyste = Lata %% 2) %>% 
  mutate(Parzyste = 1 - Nieparzyste) %>% 
  group_by(listing_id) %>% 
  summarise(SumaParzystych = sum(Parzyste),SumaNieparzystych = sum(Nieparzyste)) %>% 
  mutate(roznica = SumaNieparzystych - SumaParzystych) %>% 
  filter(roznica > 0)
# Wybieram te ktore maja wiecej recenzji w latach nieparzystych
#View(df)
szukana_liczba <- dim(df)[1] # 296 apartamentow mialo wiecej recenzji w latach nieparzystych (miedzy 4,a 5 decylem...)
szukana_liczba
## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- df




# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

df7 <- listings %>%  
  select(room_type,price)%>%  
  filter(!is.na(price))

wykres <- df7 %>% 
  ggplot(aes(y=price,x = room_type,fill = room_type)) + 
  geom_violin(alpha = 0.6) +
  scale_y_log10() +
  labs(x = "Typ pokoju",y="Cena",title = "Rozklad cen apartamentow w zaleznosci od typu pokoju") + 
  theme_bw() + theme(legend.position = "none")
 
wykres  

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- df7
# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie


df8 <- listings %>% 
  select(host_name) %>%
  mutate(PierwszaLitera = substr(host_name,1,1)) %>% 
  filter(grepl("^[A-Za-z]",PierwszaLitera)) %>% 
  group_by(PierwszaLitera) %>% 
  summarise(Liczba_Wystapien= n())

df8

wykres2 <- df8 %>% 
  ggplot(aes(x=PierwszaLitera,y=Liczba_Wystapien)) + 
  geom_col() +
  labs(y = "lizcba wystapien",x = "Pierwsza litera", title = "Liczba hostow o danej pierwszej literze imienia") +
  theme_bw()

wykres2


## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- df8


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (polozenie)aparmatemtów w Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

Coords <- listings %>% 
  filter(is.na(price)) %>% 
  select(latitude,longitude,room_type)


# Wersja ggplot, bez mapy w tle, rodzaj pokoju na inny color
# Rozklad wyglada na w miare rownomoerny, poza przerwa wygladajaca na rzeke.
Coords %>% 
  ggplot(aes(x=longitude,y=latitude,color=room_type)) +
  geom_point() +
  coord_fixed() +
  labs(title = "Rozklad polozenia apartamentow,\ndla ktorych brakuje ceny ",
       x="Wysokosc geograficzna",y="szerokosc geograficzna",
       color="Rodzaj\napartamentu")

#install.packages("leaflet")
library(leaflet)

# wersja z mapa w tle
leaflet(data = Coords) %>%
  addTiles() %>%   
  addCircleMarkers(~longitude, ~latitude,radius = 2)  # dodaje punkty


## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- Coords



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
saveRDS(solutions, file = "KoboszAntoni.rds")


