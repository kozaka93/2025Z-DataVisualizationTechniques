###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           PRACA DOMOWA 1            ###
###########################################

#GZ# - oznaczenie komentarzy dodanych przeze mnie (Gabriela Załęska, nr indeksu: 338951)
#GZ# Kod - język angielski
#GZ# Komentarze - język polski
#GZ# Ustawienia wykresów zostały dopasowane do wyświetlania ich okna na mniej więcej połowie ekranu.

# Ładowanie pakietów-----------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

#GZ# dodatkowo użyte przeze mnie biblioteki

library(lubridate)
library(forcats)
library(ggmap)

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

reviewersWithMoreThan20Reviews <- nrow (
  reviews %>% group_by(reviewer_id) %>% 
  summarize(NumberOfReviews = n()) %>% 
  filter(NumberOfReviews>20)
)
#GZ# Liczba wierszy ramki danych zawierającej informacje tylko o użytkownikach, którzy zostawili więcej niż 20
#GZ# recenzji to właśnie liczba tych recenzentów. Jest ich 32.

## Odpowiedz przypisana do zmiennej
ANS_TASK_01 <- reviewersWithMoreThan20Reviews

# Zadanie 2 (0.5) ---------------------------------------------------------
# W jakich miesiącach jest wystawiane najwięcej recenzji?

## Rozwiązanie

topMonths <- reviews %>% 
  mutate(month = format(as.Date(date), "%B")) %>% 
  group_by(month) %>% 
  summarize(NumberOfReviews = n()) %>% 
  arrange(-NumberOfReviews) %>% 
  slice_head(n = 3)

#GZ# Wyciągneliśmy z daty samą nazwę miesiąca i dzięki temu mogliśmy względem samego miesiąca pogrupować,
#GZ# a następnie posortować względem liczby wystawionych opinii. Po posortowaniu pierwszy miesiąc w 
#GZ# rankingu (tzn. pierwszy wiersz ramki danych) to miesiąc z największą liczbą wystawionych recenzji. Zatem
#GZ# przykładowo 3 miesiące, w których wystawiono najwięcej recenzji to kolejno: sierpień, czerwiec, lipiec.

## Odpowiedz przypisana do zmiennej
ANS_TASK_02 <- topMonths$month

# Zadanie 3 (0.5) ---------------------------------------------------------
# Jaka jest największa cena za apartament przy złożeniu, że musi
# mieć co najmniej 100 recenzji (bazujemy na tabeli reviews).

## Rozwiązanie

goodApartmetns <- reviews %>% 
    group_by(listing_id) %>% 
    summarize(NumberOfReviews = n()) %>%
    filter(NumberOfReviews>=100)

#GZ# Skoro wymagane było użycie tabeli reviews, to z tabeli reviews wyciągam tylko te apartamenty, które mają 
#GZ# conajmniej 100 recenzji. Jednak, żeby uzyskać informacje o cenie musimy już skorzystać z tabeli listings.

theHighestPriceApartment <- listings %>% 
    filter(id %in% goodApartmetns$listing_id) %>% 
    arrange(-price) %>% 
    slice_head(n = 1)

#GZ# Znalazłam najwyższą cenę za pomocą sortowania malejącego i wybrania pierwszego wiersza.
#GZ# Ta cena to 1012 złotych.

## Odpowiedz przypisana do zmiennej
ANS_TASK_03 <- theHighestPriceApartment$price

# Zadanie 4 (0.5) ---------------------------------------------------------
# Bazując na wystawionych recenzjach oblicz ile jest apartamentów, które są na
# rynku dłużej niż 10 lat. Jaka jest maksymalna liczba lat apartametów na rynku?

## Rozwiązanie

moreThan10YearsApartments <- reviews %>%  
  mutate(data = as.Date(date)) %>% 
  group_by(listing_id) %>% 
  summarise(
    min_data = min(data, na.rm = TRUE),
    max_data = max(data, na.rm = TRUE),
    year_difference = time_length(interval(min_data, max_data), "years")
  ) %>% 
  filter(year_difference > 10) %>% 
  arrange(-year_difference)

#GZ# Za czas apartamentu na rynku uznałam czas, który minął pomiędzy pierwszą a ostatnią wystawioną recenzją.
#GZ# Skorzystałam z dodatkowej biblioteki lubridate, ponieważ funkcja time_length licząca lata pomiędzy dwoma datami
#GZ# uwzględnia także lata przystępne. Samo podzielenie liczby dni międzt tymi 2 datami przez 365 dałoby podobne, 
#GZ# ale delikatnie różniące się wyniki.
#GZ# Takich apartamentów jest 118, a maks liczba apartamentu na rynku to około 14,13 lat (14 lat i póltora miesiąca).

## Odpowiedz przypisana do zmiennej
ANS_TASK_04 <- c(nrow(moreThan10YearsApartments), moreThan10YearsApartments[1, 4])

# Zadanie 5 (0.5) ---------------------------------------------------------
# O ile więcej jest apartamentów na południu niż na północy w podziale na typ pokoju? 
# (środek określamy jako średnia z szerokości geograficznej)

## Rozwiązanie

half <- mean(listings$latitude, na.rm = TRUE)

#GZ# Zmienna half przechowuje środek miasta.

howMuchMoreOnTheSouthThanOnTheNorth <- listings %>% 
  mutate(region = ifelse(latitude < half, "south", "north")) %>% 
  group_by(room_type, region) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  pivot_wider(names_from = region, values_from = n, values_fill = 0) %>% 
  mutate(diff = south - north) %>% 
  summarise(room_type, diff)

#GZ# Każdemu apartamentowi przypisaliśmy czy jest na pólnocy czy na południu. Pogrupowaliśmy apartamenty ze względu na
#GZ# dwie zmienne: typ pokoju i północ/południe. Następnie skorzystaliśmy z pivot_wider, aby zamiast 2 odzielnych 
#GZ# wierszy dla każdego typu pokoju, mieć jeden, który zawiera i północ i południe. To umożliwiło
#GZ# porównanie ilości daneo typu pokoju na połnocy i południu.
#GZ# W ramce danych howMuchMoreOnTheSouthThanOnTheNorth kolumna diff określa ile więcej jest apartamentów
#GZ# na południu niż na północy (liczba ujemna oznacza, że tych apartamentow jest mniej, nie więcej).

## Odpowiedz przypisana do zmiennej
ANS_TASK_05 <- howMuchMoreOnTheSouthThanOnTheNorth

# Zadanie 6 (0.5) ---------------------------------------------------------
# Rozważmy recencje apartamentów, interesują nas tylko apartamenty, które mają liczbę recenzji między
# 4 a 5 decylem rozkładu recenzji. Ile apartamentów miało więcej recenzji w latach nieparzystych
# niż parzystych i jaka to jest liczba recenzji?

## Rozwiązanie

D4 <- quantile(listings$number_of_reviews, 0.4, na.rm = TRUE)
D5 <- quantile(listings$number_of_reviews, 0.5, na.rm = TRUE)
apartmentsBetweenD4AndD5 <- (listings %>% filter(number_of_reviews > D4 & number_of_reviews < D5))$id

#GZ# Przyjmujemy, że "między 4 a 5 decylem" oznacza, że wartośc należy do przedziału (decyl 4, decyl 5),
#GZ# tzn. wartości dokładnie równe decylom tu nie należą.

moreOddThanEven <- reviews %>% #1...
  filter(listing_id  %in% apartmentsBetweenD4AndD5) %>% 
  select(listing_id, date) %>% 
  mutate(year=as.integer(format(as.Date(date), "%Y"))) %>% 
  mutate(odd=as.logical(year%%2)) %>%
  group_by(listing_id, odd) %>% 
  summarize(NumberOfReviews = n()) %>% #...1   #2...
  pivot_wider(
    id_cols=listing_id,
    names_from=odd,
    values_from=NumberOfReviews,
    names_prefix="odd"
  ) %>% #...2   #3...
  filter(oddTRUE>oddFALSE) %>% 
  mutate(diff=oddTRUE-oddFALSE) %>% 
  summarise(listing_id, diff)

#GZ# (1) Najpierw apartamenty między 4 i 5 decylem pogrupowaliśmy tak, że dla każdego apartamentu powstały 2 grupy:
#GZ# recenzje apartamentu X w latach parzystych i rezencje apartamentu X w latach nieparzystych. Dla każdej takiej
#GZ# grupy określamy liczbę recenzji.
#GZ# (2) Podobnie jak w poprzednim zadaniu korzystam z pivot_wider, aby móc porównywać liczbę recenzji w l. parz.
#GZ# i w l. nieparz. dla jednego apartamentu.
#GZ# (3) Filtrujemy, i zostawiamy tylko te apartamenty, które mają więcej recenzji w latach nieparz.
#GZ# Ta liczba to 311 apartamentów, a ich dokładne roznice liczby recenzji w latach nieparz. niż parz.
#GZ# zawiera ramka danych moreOddThanEven.

## Odpowiedz przypisana do zmiennej
ANS_TASK_06 <- rbind(data.frame(listing_id = "NUMBERofSUCHapartments(this is not an element of this df)", diff = nrow(moreOddThanEven)), moreOddThanEven)

# Zadanie 7 (0.5 + 0.5) ---------------------------------------------------
# Jak wygląda rozkład cen apartamentów w zależności od typu pokoju?

## Rozwiązanie

#GZ# Można stworzyć tabelkę, która zawiera najważniejsze informacje (tzn. średnią, kwartyle, medianę,
#GZ# wartośc minimalną, maksymalną, idchylenie standardowe). 

summaryByRoomType <- listings %>% 
  group_by(room_type) %>% 
  summarise(
    mean=mean(price, na.rm = TRUE),
    q25=quantile(price, 0.25, na.rm = TRUE),
    median=median(price, na.rm = TRUE),
    q75=quantile(price, 0.75, na.rm = TRUE),
    minPrice=min(price, na.rm = TRUE),
    maxPrice=max(price, na.rm = TRUE),
    sd=sd(price, na.rm = TRUE)
  )

#GZ# Jednak taka tabelka jest mało czytelna.
#GZ# Lepiej stworzyć wykres skrzynkowy lub skrzypcowy i go przeanalizować.

ggplot(listings, aes(x=room_type, y=price)) +
  geom_boxplot(fill = "blue2", color = "darkblue") + 
  coord_cartesian(ylim = c(0, 1200)) + #(*)
  labs(
    title = "Distribution Of Apartment Prices Depending\nOn The Room Type",
    x = "Room Type",
    y = "Price"
  ) +
  theme(
    axis.title.x = element_text(margin = margin(t = 20)), 
    axis.title.y = element_text(margin = margin(r = 20)), 
    plot.title = element_text(margin = margin(b = 20), size = 20),   
    axis.text = element_text(size = 12)                   
  )

ggplot(listings, aes(x=room_type, y=price)) +
  geom_violin(fill = "blue2", color = "darkblue") + 
  coord_cartesian(ylim = c(0, 1200)) + #(*)
  labs(
    title = "Distribution Of Apartment Prices Depending\nOn The Room Type",
    x = "Room Type",
    y = "Price"
  ) +
  theme(
    axis.title.x = element_text(margin = margin(t = 20)), 
    axis.title.y = element_text(margin = margin(r = 20)), 
    plot.title = element_text(margin = margin(b = 20), size = 20),   
    axis.text = element_text(size = 12)                   
  )

#GZ# (*) W obu wykresach zmieniłam zakres osi y na węższy, ponieważ wartości dla typu Entire home/apt mają bardzo dużo 
#GZ# outlierów na wysokich wartościach, przez co skrzynki są mało czytelne (można to zobaczyć przy zakomentowaniu lini (*) ).

#GZ# Analiza: Standardowe (tzn. mieszczące się w skrzynce) ceny pokoju typu "hotel room" są o wiele bardziej 
#GZ# oddalone od siebie, niż pozostałych typów pokojów. Jednak ten typ pokoju nie ma dużo wartości odstających, czego nie
#GZ# można powiedzieć o Entire home/apt i Private room, które ceny standardowe mają bliskie siebie, ale mają bardzo dużo 
#GZ# outlierów w wysokich wartościach. Najbardziej stabilną opcją jest Shared room, który ma zarówno bliskie
#GZ# siebie wartości standardowe jak i brak wartości odstających.

## Odpowiedz przypisana do zmiennej
ANS_TASK_07 <- summaryByRoomType
  
# Zadanie 8 (0.5 + 0.5) ---------------------------------------------------
#
# Dla każdego apartamentu wybierzmy pierwszą literę imienia hosta. Jak wygląda 
# rozkład pierwszych liter hostów?

## Rozwiązanie

firstLetters <- listings %>% 
  mutate(firstHostLetter=substr(host_name, 1, 1)) %>% 
  group_by(firstHostLetter) %>% 
  summarize(NumberOfHosts = n()) %>% 
  filter(grepl("^[A-Za-z]$", firstHostLetter))

#GZ# Stworzyliśmy ramkę pokazującą częstość występowania pierwszych liter hostów. Jednak jest mało czytelna.
  
ggplot(firstLetters, aes(x = firstHostLetter, y = NumberOfHosts)) +
  geom_col(fill = "darkblue") +
  labs(
    title = "Distribution of First Letters of Host Names",
    x = "First Letter",
    y = "Number of Occurrences"
  ) +
  theme(
    axis.title.x = element_text(margin = margin(t = 20)), 
    axis.title.y = element_text(margin = margin(r = 20)), 
    plot.title = element_text(margin = margin(b = 20), size = 20),   
    axis.text = element_text(size = 12)                   
  )

#GZ# Analiza: jak widać rozkład pierwszych liter hostów jest bardzo nierównomierny. Są litery, które występują wiele razy:
#GZ# np. A, J, M, S. Ale są także litery występujące bardzo rzadko, np. Q, U, X. Aby lepiej zobaczyć, które litery są 
#GZ# bardziej popularne, które mniej posortujmy najpierw ramkę firstLetters (na stałe, nie tylko arrange, które zmienia widok).

firstLettersSorted <- firstLetters %>% 
  mutate(firstHostLetter = forcats::fct_reorder(firstHostLetter, -NumberOfHosts))

ggplot(firstLettersSorted, aes(x = firstHostLetter, y = NumberOfHosts)) +
  geom_col(fill = "darkblue") +
  labs(
    title = "Distribution of First Letters of Host Names",
    x = "First Letter",
    y = "Number of Occurrences"
  ) +
  theme(
    axis.title.x = element_text(margin = margin(t = 20)), 
    axis.title.y = element_text(margin = margin(r = 20)), 
    plot.title = element_text(margin = margin(b = 20), size = 20),   
    axis.text = element_text(size = 12)                   
  )

#GZ# Teraz na wykresie jeszcze lepiej widać, które litery są najbardziej popularne.

## Odpowiedz przypisana do zmiennej
ANS_TASK_08 <- firstLetters


# Zadanie 9 (0.5 + 0.5) ---------------------------------------------------
# Czy rozkład (położenie) aparmatemtów w mieście Seatle, które nie mają podanej ceny w bazie danych
# jest równomierny?

## Rozwiązanie

apartmentsWithMissingPrice <- listings %>% 
  filter(is.na(price)) %>% 
  summarise(id, latitude, longitude)

#GZ# Bierzemy do analizy tylko apartamenty bez podanej ceny.

ggplot(apartmentsWithMissingPrice, aes(x = longitude, y = latitude)) +
  geom_point(color = "darkblue", alpha = 0.5) +
  labs(title = "Distribution of apartments without a\nspecified price",
       x = "Longitude",
       y = "Latitude") +
  theme(
    axis.title.x = element_text(margin = margin(t = 20)), 
    axis.title.y = element_text(margin = margin(r = 20)), 
    plot.title = element_text(margin = margin(b = 20), size = 20),   
    axis.text = element_text(size = 12)                   
  )

#GZ# Jak widać rozkład nie jest równomierny, poniewaz występują pewne skupiska punktów. Są także miejsca, gdzie tych 
#GZ# punktów w ogóle nie ma, jednak to może być z powodu, że tam gdzie ich nie ma jest woda/rzeka i po prostu nie ma apartamentów.
#GZ# Aby sprawdzić to dokładniej warto nanieść punkty na prawdziwą mapę.

#GZ# Aby użyc mapy trzeba:
register_stadiamaps("2fa0074e-f306-4afd-b491-38e6912a1b9b", write=FALSE)

map <- get_stadiamap(
  bbox = c(left = -122.45, bottom = 47.50, right = -122.20, top = 47.75),
  zoom = 12,
  maptype = "stamen_terrain"
)

ggmap(map) +
  geom_point(
    data = apartmentsWithMissingPrice,
    aes(x = longitude, y = latitude),
    color = "darkblue",
    alpha = 0.6,
    size = 2
  )

#GZ# Jak widać faktycznie miejsca bez punktów, to w większości woda. A największe skupisko punktów to samo centrum Seattle, 
#GZ# gdzie bardzo możliwe występują jedne z najdroższych apartamentów i właściciele nie chcą "straszyć cenami" lub jest to 
#GZ# element strategii marketingowej przyciągnięcia najbogatszych gości (tzw. tajemnicza, prywatna cena).

## Odpowiedz przypisana do zmiennej
ANS_TASK_09 <- apartmentsWithMissingPrice



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
saveRDS(solutions, file = "ZaleskaGabriela.rds")