library(ggplot2)
library(gganimate)
library(dplyr)


n_klatek <- 40
n_platkow <- 100

galezie <- data.frame(
  id = rep(1:5, each = 3),
  x = c(-5, 0, 5,   -4, 0, 4,   -3, 0, 3,   -2, 0, 2,   -1, 0, 1),
  y = c(0, 4, 0,    2, 5.5, 2,    4, 7, 4,    6, 8.5, 6,   8, 10, 8),
  fill = rep(c("#004d00", "#006600", "#008000", "#00cc00", "#00ff00"), each = 3)
)

pien <- data.frame(
  id = 0,
  x = c(-0.5, 0.5, 0.5, -0.5),
  y = c(-2, -2, 0, 0),
  fill = "brown"
)

bombki <- data.frame(
  x = c(-3,  2.5, -1.5,  4,   0.5, -1, 1.5, -0, 3,   -1),
  y = c( 1,  1.5,  5,    1,   9,  1.5,  6,   4,  3,    7))

choinka_base <- rbind(pien, galezie)

choinka_anim <- expand.grid(frame = 1:n_klatek, row_id = 1:nrow(choinka_base)) %>%
  mutate(
    x = choinka_base$x[row_id],
    y = choinka_base$y[row_id],
    id = choinka_base$id[row_id],
    fill = choinka_base$fill[row_id]
  )

snieg_anim <- expand.grid(flake_id = 1:n_platkow, frame = 1:n_klatek) %>%
  group_by(flake_id) %>%
  mutate(
    x = runif(1, -6, 6),
    speed = runif(1, 0.2, 0.5),
    start_y = runif(1, 0, 15),
    y = ((start_y - speed * frame) %% 15) -2
  ) %>%
  ungroup()


scena <- ggplot() + theme_void() + theme(panel.background = element_rect(fill = "black")) +
  geom_polygon(data = choinka_anim, aes(x, y, group = id, fill = I(fill))) +
  geom_point(data = bombki, aes(x, y), color = "red", size = 7) +
  annotate("point", x = 0, y = 10.5, color = "gold", size = 8, shape = 8) +
  geom_point(data = snieg_anim, aes(x, y), color = "white", size = 2) + 
  transition_manual(frame)

anim <- animate(scena, nframes = n_klatek, fps = 10, width = 400, height = 450, renderer = gifski_renderer())
anim
anim_save("choinka.gif", anim)
