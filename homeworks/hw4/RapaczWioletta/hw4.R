#link do posta: https://x.com/simisani10/status/1767540926304415942
#link do repozytorium z danymi: https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-03-05
library(tidyr)
library(dplyr)
library(ggplot2)
trashwheel <- read.csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-03-05/trashwheel.csv')
View(trashwheel)

trashwheel_long <- trashwheel %>%
  pivot_longer(cols = c(PlasticBottles, Polystyrene, CigaretteButts, GlassBottles, PlasticBags, Wrappers, SportsBalls), names_to = "rodzaj_smieci", values_to = "liczba")

suma <- trashwheel_long %>%
  filter(Year==2023 & ID=="mister") %>% 
  group_by(ID) %>% 
  summarise(suma_fin=sum(liczba))

suma <- suma[[2]]

tw23 <- trashwheel_long %>%
  filter(Year==2023 & ID=="mister") %>% 
  group_by(rodzaj_smieci) %>% 
  summarise(suma_r=sum(liczba)) %>% 
  mutate(procenty=suma_r/suma)

p <- tw23 %>%
  ggplot(aes(x = rodzaj_smieci, y = procenty )) +
  geom_col()+
  labs(title="Podział śmieci zebranych przez Mister Trash Wheel w roku 2023 na rodzaje", y="procenty udziału w ilości śmieci", x="rodzaj śmieci")
p
#Co było do zmiany?
#W pierwotnej wizualizacji przez obrazki, które są w takim samym rozmiarze niezależnie od wielkości, podpisy wyników i brak widocznych słupków nie da się porównywać wyników w różnych kategoriach. 
#Błędny jest również tytuł, ponieważ dane dotyczą tylko jednego, nastarszego kolektrora, a tytuł sugeruje inaczej. Również nie wiadomo z czego liczymy procenty.
#Błąd pojawia się nawet danych, bo kolumna "HomesPowered" jest traktowana jako typ odpadu

#Dlaczego druga wizualizacja jest lepsza?
#Na poprawionym wykresie utrzymano koncept porównywania procentów, ale dzięki zastosowania wykresu słupkowego można nie tylko graficznie zauważyć wielkość, ale także porównać między kategoriami.
#Ponadto pozbyłam się błędnej kategorii "HomesPowered", która nie jest rodzajem śmiecia oraz poprawiłam tytuł by odzwierciedlał co jest w danych, czyli śmieci zebrane przez konkretny kolektor.
#Podpisy poprzez obrazki zastąpiłam tradycyjnymi kategoriami, dzięki temu mamy tyle samo informacji o kategoriach, a dane o procentach nie gubią się przez grafiki.