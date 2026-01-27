library(ggplot2)
library(plotly)
library(dplyr)
library(tidyverse)
library(tidyr)

tuesdata <- tidytuesdayR::tt_load('2024-03-05')

trashwheel <- tuesdata$trashwheel

# Wykres źródłowy: procentowy udział różnych śmieci wyłowionyhc w 2023r przez urządzenie Trashwheel
# źródło: https://x.com/simisani10/status/1767540926304415942?s=46&t=AEyQybLAZ9YnHmOHEIVkFg
# Dane: https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-03-05
#
# Dlaczego źródłowy wykres jest zły: 
# - brak osi
# - brak informacji o skali, która nie jest nawet zachowana - wartości 0,27 oraz 0,72 wydają się byc wyżej umieszczone niż wartość 3
# - nie podpisane wartosci - wystepują tylko rysunki, które mogą być niejednoznaczne, nie występuje także legenda, która pomogłaby zidentyfikować obrazki
# - nie występuje żaden wykres, wartości nie są uporządkowane, co sprawia wrażenie losowo rozmieszczonych grafik
# - bład w danych : HomePowered oznacza liczbę gospodarstw domowych, które mogłyby zostać zasilone energią uzyskaną z przetworzenia wyłowionych śmieci — nie jest to liczba ton odpadów, lecz odpowiadająca im wartość energetyczna
#
#Dlaczego mój wykres jest lepszy:
# - każda kolumna jest podpisana, co umożliwia odbiorcy bezproblemowe rozpoznanie obiektu badanego
# - występuje oś y -> łatwo odczytać wartość danej kategorii
# - nad każdym słupkiem umieściłam wartość procentową kategorii -> odowłanie się do idei autorki, by każda katgegoria była podpisana -> czytelnik od razu dostaje ilość % nie musi odczytywać z wykresu
# - usunęłąm zbędną kategorie :HomePowered , która nie powinna być umieszczona na wykresie
# - wyraźnie widać, która kategoria została wyłowiona najczęśćiej

trashwheel_2023 <- trashwheel %>%
  filter(Year == 2023) %>%
  select(ID,Name,Year, Weight,Volume,PlasticBottles,Polystyrene,
         CigaretteButts,GlassBottles,Wrappers,SportsBalls,PlasticBags)%>%
  group_by(Name)%>%
  summarise( ID = first(ID),Year = first(Year),across( !Year &where(is.numeric), sum, na.rm = TRUE))

trash_tidy2 <- trashwheel_2023 %>%
  select(PlasticBottles, Polystyrene, CigaretteButts,
         GlassBottles, Wrappers, SportsBalls,PlasticBags) %>%
  pivot_longer(cols = everything(),names_to = "TrashType", values_to = "Amount")

trash_total2 <- trash_tidy2 %>%
  group_by(TrashType) %>%
  summarise(Total = sum(Amount, na.rm = TRUE)) %>%
  arrange(desc(Total))

trash_total2 <- trash_total2 %>%
  mutate(Percent = Total / sum(Total) * 100)

ggplot(trash_total2, aes(x = reorder(TrashType, -Percent), y = Percent)) +
  geom_col(fill = "hotpink3") +
  geom_text(aes(y = Percent, label = sprintf("%.2f%%", Percent)),vjust = -0.3,size = 3.5, color = "hotpink4",family="Times New Roman" )+       
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Waste Composition Collected by the Trash Wheel in 2023",
    subtitle = "Percentage Share of Debris Types",
    x = "Trash Type",
    y = "Percentage (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle=2, hjust=0.5,family = "Times New Roman",size = 10),
    plot.title = element_text(family = "Times New Roman", face = "bold", size = 16,hjust = 0.5),
    plot.subtitle = element_text(family = "Times New Roman", size = 12,hjust = 0.5),
    axis.title.x = element_text(family = "Times New Roman", size = 12),
    axis.title.y = element_text(family = "Times New Roman", size = 12),
    axis.text.y = element_text(family = "Times New Roman", size = 10))


