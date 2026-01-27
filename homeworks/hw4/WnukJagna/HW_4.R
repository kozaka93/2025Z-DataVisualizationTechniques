
# link do danych: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-19/mutant_moneyball.csv
# link do posta na X: https://x.com/simisani10/status/1774290101717094552?s=20

#Błędy:
# 1. Tyutł sugeruje, że wizualizacje ma prezentować występowanie postaci w komiksach 
# natomiast patrząc na kod i dobór wykresu są to dane precentowe (stosunek występowania danej postaci do sumarycznej liczby komiksów)
# 2. Wykresy kołowe nie reprezentują wartości są nieczytelne
# 3. Tworzenie kilku wykresów oddzielnie sprawia że ciężko porównuje się wartości między sobą
# 4. Nie ma żadnych opisów, wartości liczbowych/ procentowych

# Co jest lepiej:
# Prezentujemy to na co wskazywał tytuł czyli występowanie postaci w komiksach
# Wykres lizakowy posortowany po ilości komiksów pozwala wyraźnie odczytać dane i je porównać
# Nazwy postaci są zapisane w bardziej czytelny sposób

library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)


xmen_data <- read.csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-19/mutant_moneyball.csv"
)
xmen_data <- xmen_data %>% select('Member','TotalIssues')
xmen_data$Member =  tools::toTitleCase(gsub("([a-z])([A-Z])", "\\1 \\2",  xmen_data$Member))
 

xmen_data %>%
  mutate(Member = fct_reorder(Member, TotalIssues)) %>% 
ggplot(aes(x=Member, y=TotalIssues)) +
  geom_segment(aes(y=0, yend=TotalIssues), color="red") +
  geom_point(color="black", size=2, alpha=0.9) +
  theme_light() +
  coord_flip() +
  labs(
    title = "Występowanie poszczególnych postaci w komiksach XMen w latach 1963 - 1992",
    y = "Ilość komiksów",
    x = "Postać"
  ) +
  theme(
    plot.title = element_text(size = 8),
    axis.text = element_text(size = 7),
    panel.grid.major.y = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.x  = element_text(size = 8),
    axis.title.y  = element_text(size = 8)
  )


