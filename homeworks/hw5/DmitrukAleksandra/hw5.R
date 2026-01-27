library(ggplot2)
library(dplyr)
library(gganimate)


green_darker <- "#083A19"
green_mid    <- "#0A4820"
green_bright <- "#4A8860"
green_highlight <- "#D0E9D9"

red_darker <- "#961E1E"
red_mid    <- "#BD1A1A"
red_highlight <- "#CB5F5F"


gold_darker <- "#8A6E2F"
gold_mid    <- "#C0A04D"
gold_highlight <- "#FFFFE0"

k <- seq(0, 25 * pi, length.out = 2000)

tree_data <- data.frame(t = k) %>%
  mutate(
    radius = t^0.90 * 0.25,
    x = radius * cos(t),
    y = -t / 2 - 0.5 * sin(t),
    twist = abs(sin(t + pi / 4))
  )

s <- 25 * pi * sqrt(seq(0, 1, length.out = 80))

decoration_data <- data.frame(t = s) %>%
  mutate(
    radius = s^0.90 * 0.25 + 0.2,
    x = radius * cos(s),
    y = -s / 2 - 0.5 * sin(s),
    twist = abs(sin(s + pi / 4)),
  )


twinkle_data <- decoration_data %>%
  slice(rep(1:n(), times = 20)) %>%
  mutate(state = rep(1:20, each = nrow(decoration_data)),
         alpha_val = runif(n(), min = 0, max = 1))


star_data <- data.frame(y = 0.9, x = 0)


p <- ggplot() +
  
  geom_path(data = tree_data,
            aes(x = x, y = y),
            color = green_darker,
            linewidth = 6,
            lineend = "round",
            linejoin = "round") +
  geom_path(data = tree_data,
            aes(x = x, y = y, color = twist),
            linewidth = 4.5,
            lineend = "round",
            linejoin = "round") +
  geom_point(data = decoration_data,
             aes(x = x, y = y),
             color = red_darker,
             size = 2.5) +
  geom_point(data = decoration_data,
             aes(x = x, y = y),
             color = red_mid,
             size = 1.5) +
  geom_point(data = decoration_data,
            aes(x = x + 0.08, y = y + 0.08),
            color = red_highlight,
            size = 1) +
  geom_point(data = twinkle_data,
             aes(
              x = x + 0.08,
              y = y + 0.08,
              alpha = alpha_val),
             color = "white",
             size = 0.5)  +
  geom_point(data = star_data,
            aes(x = x, y = y),
            color = gold_darker,
            shape = 8,
            size = 12,
            stroke = 2) +
  geom_point(data = star_data,
            aes(x = x, y = y),
            color = gold_mid,
            shape = 8,
            size = 12,
            stroke = 1) +
  geom_point(data = star_data,
            aes(x = x, y = y),
            color = gold_highlight,
            shape = 8,
            size = 12,
            stroke = 0.5) +
  scale_color_gradientn(colors = c(
    green_mid,
    green_bright,
    green_highlight,
    green_bright,
    green_mid)) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none",
        plot.background = element_rect(fill = "black", color = NA),
        panel.background = element_rect(fill = "black", color = NA),
        plot.margin = margin(0, 0, 0, 0, "pt")) +
  transition_states(state, transition_length = 2, state_length = 1)

anim <- animate(
  p,
  nframes = 100,
  fps = 20,
  width = 400,        
  height = 635,       
  res = 100,
  end_pause = 30,
  renderer = gifski_renderer(),

)
anim_save("choinka.gif", animation = anim)
