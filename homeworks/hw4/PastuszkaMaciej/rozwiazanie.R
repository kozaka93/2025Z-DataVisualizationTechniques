# Oryginalna wizualizacja:
# https://x.com/RicardoRH_IDB/status/1645279050762469376

# Dane:
# https://github.com/rfordatascience/tidytuesday/blob/main/data/2023/2023-04-04/soccer21-22.csv

# Popelnione bledy przez autora wizualizacji:
# - Na pierwszy rzut oka ciezko stwierdzic jaka zmienna jest badana, pomocny moglby
#   byc bardziej zrozumialy tytul i podtytul
# - brak etykiety osi x
# - os x moglaby zaczynac sie od 0
# - herby druzyn na wizualizacji sa zbyt gesto umiejscowione, przez co niektore
#   sa w ogole nie widoczne
# - przez to ze kazdy herb ma pewna szerokosc trudno jest ocenic ile dokladnie goli
#   strzelily poszczegolne druzyny


# Moj plan na naprawe wizualizacji:
# - Zrobic normalny, czytelny wykres kolumnowy

library(dplyr)
library(ggplot2)
library(tidyr)

data <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/refs/heads/main/data/2023/2023-04-04/soccer21-22.csv")

# Do wizualizacji potrzebujemy dla kazdej druzyny znalezc strzelona przez niej liczbe goli w sezonie
# Liczba goli w sezonie: liczba goli jako HomeTeam (FTHG - Full time home goals)
#                       + liczba goli jako AwayTeam (FTAG - Full time away goals)

home_goals <- data %>% 
  select(HomeTeam, FTHG) %>%
  group_by(HomeTeam) %>% 
  summarise(HomeGoals = sum(FTHG)) %>% 
  rename(Team = HomeTeam)

away_goals <- data %>% 
  select(AwayTeam, FTAG) %>% 
  group_by(AwayTeam) %>% 
  summarise(AwayGoals = sum(FTAG)) %>% 
  rename(Team = AwayTeam)

all_goals <- left_join(home_goals, away_goals, by = "Team") %>% 
  mutate(AllGoals = HomeGoals + AwayGoals)

plot1 <- ggplot(all_goals, aes(x = AllGoals, y = reorder(Team, AllGoals))) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = AllGoals), hjust = -0.2, size = 3.5) +
  scale_x_continuous(limits = c(0, 110), expand = c(0, 0.1)) + 
  labs(
    title = "Ile goli strzeliły poszczególne drużyny Premier League?",
    subtitle = "Wykres przedstawia łączne liczby goli strzelonych w sezonie 2021-22.",
    x = "Łączna liczba goli",
    y = NULL, 
    caption = "dane: https://github.com/rfordatascience/tidytuesday/blob/main/data/2023/2023-04-04/soccer21-22.csv"
  ) +
  theme_minimal() +
  theme(
    plot.margin = margin(10, 10, 10, 10),
    panel.grid.major.y = element_blank()
  )

plot1

# Dlaczego wykres jest lepszy od oryginalu?

# skorzystalem z prostszego typu wykresu, dzieki czemu przedstawione informacje
# sa latwiejsze w odbiorze, a takze umiejscowilem na wykresie dokladne liczby
# goli dla kazdej druzyny co moze byc uzyteczna informacja
# zmienilem takze tytul ktory jasno opisuje, czego dotyczy wykres