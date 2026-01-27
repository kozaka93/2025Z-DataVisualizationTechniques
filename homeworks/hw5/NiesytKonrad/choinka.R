library(ggplot2)
library(gganimate)


t <- seq(0, 1, length.out = 5000)
tree_data <- data.frame(
  x = (1 - t) * cos(t * 30),
  y = t
)


n_lights <- 50
n_states <- 10

lights_data <- data.frame(
  state = rep(1:n_states, each = n_lights),
  id = rep(1:n_lights, n_states),
  y = rep(runif(n_lights, 0.05, 0.95), n_states),
  angle = rep(runif(n_lights, 0, 2*pi), n_states)
)


lights_data$x <- (1 - lights_data$y) * 0.8 * cos(lights_data$angle)
lights_data$color <- sample(c("red", "gold", "blue", "white", "orange"), nrow(lights_data), replace = TRUE)


p <- ggplot() +
  geom_path(data = tree_data, aes(x, y), color = "forestgreen", size = 1.5, alpha = 0.6) +
  geom_point(data = lights_data, aes(x, y, color = color, group = id), size = 4) +
  geom_point(aes(x = 0, y = 1.05), shape = 8, size = 12, color = "gold") +
  theme_void() +
  scale_color_identity() +
  theme(plot.background = element_rect(fill = "#051f30", color = NA)) + 
  transition_states(state, transition_length = 2, state_length = 1, wrap = TRUE) +
  enter_fade() + 
  exit_fade()

animate(p, fps = 30, duration = 6, width = 500, height = 600, res = 100)

anim_save("choinka.gif")
