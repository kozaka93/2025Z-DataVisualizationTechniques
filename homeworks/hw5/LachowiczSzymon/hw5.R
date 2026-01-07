library(ggplot2)
library(dplyr)
library(gganimate)
warstwy <- data.frame(
  id = rep(1:5, each = 4),
  x = c(-5, 5, 2, -2,
        -4, 4, 1.5, -1.5, 
        -3, 3, 1, -1, 
        -2, 2, 0.5, -0.5, 
        -1, 1, 0, 0),
  y = c(0, 0, 2, 2,
        1.5, 1.5, 3.5, 3.5,
        3, 3, 5, 5,
        4.5, 4.5, 6.5, 6.5,
        6, 6, 8, 8)
)

pien <- data.frame(x = c(-0.5, 0.5, 0.5, -0.5), y = c(-1, -1, 0, 0))

set.seed(123)
bombki <- data.frame(
  x = runif(30, -3, 3),
  y = runif(30, 0, 7)
) %>% 
  filter(abs(x) < (8 - y) * 0.6) %>%
  mutate(kolor = sample(c("red", "gold", "white", "cyan"), n(), replace = TRUE))

liczba_platkow <- 150
liczba_klatek <- 20
snieg_animacja <- data.frame(
  id_platka = rep(1:liczba_platkow, each = liczba_klatek),
  x = rep(runif(liczba_platkow, -6, 6), each = liczba_klatek),
  y_start = rep(runif(liczba_platkow, -1, 10), each = liczba_klatek),
  czas = rep(1:liczba_klatek, liczba_platkow)
) %>%
  mutate(y = y_start - (czas * 0.5)) %>%
  mutate(y = ifelse(y < -1, y + 11, y))

animacja <- ggplot() +
  geom_point(data = snieg_animacja, aes(x, y, group = id_platka), color = "white", size = 0.8, alpha = 0.5) +
  geom_polygon(data = pien, aes(x, y), fill = "#5D4037") +
  geom_polygon(data = warstwy, aes(x = x, y = y, group = id, fill = id), color = "#1B5E20") +
  geom_point(data = bombki, aes(x, y, color = kolor), size = 4) +
  geom_point(aes(x = 0, y = 8.2), shape = 8, size = 10, color = "gold", stroke = 2) +
  scale_fill_gradient(low = "#2E7D32", high = "#A5D6A7", guide = "none") +
  scale_color_identity() +
  theme_void() +
  theme(panel.background = element_rect(fill = "#000814", color = NA)) +
  coord_fixed() +
  transition_time(czas) +
  ease_aes('linear')
finalna_animacja <- animate(animacja, nframes = 50, fps = 10, width = 600, height = 600, renderer = gifski_renderer())
anim_save("choinka_data_science.gif", animation = finalna_animacja)
finalna_animacja