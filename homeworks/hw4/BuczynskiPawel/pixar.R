library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(patchwork)

# Oryginalna wizualizacja:
# https://github.com/ivabrunec/tidytuesday/blob/main/2025/2025_03_11/tidy_tues_2025_03_11_pixar.png

# Post:
# https://bsky.app/profile/ivabrunec.bsky.social/post/3lkjsfemxjc2d

# Problemy:
# - Jest dużo oddzielnych wykresów, przez co trudno porównać różne filmy ze sobą
# - Brakuje legendy (chociaż tu w zasadzie nie jest konieczna, ale jakiś lepszy opis by się przydał)
# - Brakuje skali osi
# - Wstawienie na jeden wykres ocen z dwóch źródeł oraz długości filmu może być mylące,
#   bo dwie rzeczy są z tej samej "kategorii", a trzecia z innej, więc mają też różne skale

# Linki do danych źródłowych
pixar_films <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-03-11/pixar_films.csv')
public_response <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-03-11/public_response.csv')

# Moja wizualizacja
wider <- pixar_films %>%
  left_join(public_response, join_by(film)) %>%
  drop_na(film) %>%
  # nie wiem skąd autor wziął te ręcznie wstawiane wartości, załóżmy że są prawdziwe
  mutate(run_time = if_else(film == "Turning Red" & is.na(run_time), 100, run_time),
         run_time = if_else(film == "Lightyear" & is.na(run_time), 105, run_time),
         rotten_tomatoes = if_else(film == "Luca" & is.na(rotten_tomatoes), 91, rotten_tomatoes),
         rotten_tomatoes = if_else(film == "Turning Red" & is.na(rotten_tomatoes), 95, rotten_tomatoes),
         rotten_tomatoes = if_else(film == "Lightyear" & is.na(rotten_tomatoes), 74, rotten_tomatoes),
         metacritic = if_else(film == "Luca" & is.na(metacritic), 71, metacritic),
         metacritic = if_else(film == "Turning Red" & is.na(metacritic), 83, metacritic),
         metacritic = if_else(film == "Lightyear" & is.na(metacritic), 60, metacritic),
         release_date = as.Date(release_date),
         min_score = pmin(rotten_tomatoes, metacritic, critics_choice, na.rm = TRUE),
         max_score = pmax(rotten_tomatoes, metacritic, critics_choice, na.rm = TRUE)
  ) %>%
  arrange(max_score, min_score) %>%
  mutate(film = factor(film, film))

longer <- wider %>%
  pivot_longer(cols = c(rotten_tomatoes, metacritic, critics_choice),
               names_to = "reviewer",
               values_to = "score") %>%
  drop_na(score)

p1 <- ggplot(wider) +
  geom_segment(aes(x = min_score, xend = max_score, y = film, yend = film)) +
  # geom_text(aes(x = max_score + 1, y = film, label = film), hjust = 0) +
  geom_point(data = longer, aes(x = score, y = film, color = reviewer), size = 3) +
  scale_x_continuous(expand = expansion(add = c(2, 2))) +
  scale_y_discrete(position = "right") +
  scale_color_discrete(labels = c("critics_choice" = "Critic's Choice",
                                  "metacritic" = "MetaCritic",
                                  "rotten_tomatoes" = "Rotten Tomatoes")) +
  labs(x = "Ratings",
       color = "Rating from:") +
  theme(legend.position = c(0.3, 0.7),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y  = element_blank())

p2 <- ggplot(wider) +
  geom_col(aes(x = run_time, y = film), alpha = 0.6) +
  scale_x_continuous(expand = expansion(mult = c(0, .1))) +
  labs(x = "Run time (minutes)") +
  theme(axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y  = element_blank())

y_axis <- ggplot(wider, aes(y = film)) +
  geom_blank() +
  scale_y_discrete() +
  theme_void() +
  theme(axis.text.y  = element_text(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank())

p1 + y_axis + p2 +
  plot_layout(widths = c(2, 0, 1)) +
  plot_annotation(title = "Ratings and run time of Pixar 3D films",
                  theme = theme(plot.title = element_text(hjust = 0.5, size = 20)))

# Co jest lepiej:
# - Wszystkie filmy są na jednym wykresie "lizakowym", więc można je łatwo porównywać,
#   zwłaszcza po posortowaniu według ocen
# - Jest legenda
# - Jest skala osi
# - Przy okazji okazało się, że można pokazać oceny z 3 źródeł, a nie tylko 2,
#   mamy więcej danych i dobrze to wygląda na tym typie wykresu
# - Oceny są przedstawione w inny sposób niż długość filmu i na osobnym wykresie
