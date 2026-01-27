# POPRAWA WIZUALIZACJI

# link do repo: 
# link do danych:
# link do posta:

# NIEPRAWIDŁOWOŚCI
# Po pierwsze siatka w tle sugeruje, że miał to być wykres natomist
#brakuje osi x i y. Po drugie brakuje logiki wykresu - autor nie trzyma
#się konwencji, że wyżej to wyższy procent ani, że im większa ikona
# tym większy procent - szczezre trudno mi się dopatrzeć tu logikii
#i dla mnie wygląda jak losowo umieszczone obrazki. Po trzecie brakuje legendy -
#obrazki nie zawsze dostarczją wystarczającej informacji do jakich śmieci
#odnosi się dany procent - np niebieska figurka nie wiemy do czego się
# odnosi, dodatkowo 3 jest niżej niż np 0,27. 
# Dodatkowo uwzględniona jest dana HousesPowered, a w Readme repo napisane jest, że
# nie są to śmieci (a coś na zasadzie liczby domów jakie można zasilić z zebranych ton)
#Ponadto nie mamy informacji czy procent jest wyższy jeśli chodzi o liczbę sztuk/ton/litrów,
# a jest to istotny aspekt
#


# dlaczego ten lepszy?
# Dane zwizualizowane jako wykres słupkowy oraz posortowane od największej
#wartości, słupki wizualizują procent, dodane osie wraz z podpisami.
# Śmieci przedstawione jako słupki zamiast ikony i do nich dołączona legenda.
# Dodatkowo pomijam kolumnę HomesPowered, ponieważ nie są to śmieci, a 
# liczba domów jakie można zasilić 
# Poprawiony natomiat autor wykresu przygotował go na rok 2023
# i postanowiłam przy tym zostać, choć dane są dla wielu lat więc może warto przedstawić więcej




library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)


trash <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-05/trashwheel.csv')
View(trash)


ggplot(
  trash %>%
    filter(Year == 2023) %>%
    select(
      PlasticBottles,
      Polystyrene,
      CigaretteButts,
      GlassBottles,
      PlasticBags,
      Wrappers,
      SportsBalls) %>%
    summarise(across(everything(), sum, na.rm = TRUE)) %>%
    pivot_longer(cols = everything(), names_to = "Type", values_to = "Count") %>%
    mutate(Percent = Count / sum(Count) * 100),
  aes(x = reorder(Type, -Percent), y = Percent, fill = Type)
) +
  geom_col() +
  labs(
    title = "Udział procentowy typów śmieci w 2023",
    subtitle = "Procent liczby zebranych sztuk",
    x = NULL,
    y = "Procent (%)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_blank(),    # usuwa napisy na osi X
    axis.ticks.x = element_blank(),   # usuwa kreski osi X
    plot.title = element_text(hjust = 0.5),      # wyśrodkowanie tytułu
    plot.subtitle = element_text(hjust = 0.5)    # wyśrodkowanie podtytułu
  )
