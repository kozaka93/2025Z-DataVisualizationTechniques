library(ggplot2)
library(dplyr)
library(gganimate) 

# dane do choinki spirala
t <- seq(0, 10 * pi, length.out = 600)
tree_data <- data.frame(
  x = (10 * pi - t) * cos(t),
  y = t,
  size = (10 * pi - t)
)

# dane bombki
set.seed(42)
ornaments <- tree_data %>%
  sample_n(40) %>%
  mutate(
    color = sample(c("#E63946", "#F1FAEE", "#A8DADC", "#457B9D", "#FFD700"), n(), replace = TRUE),
    val = runif(n(), 3, 6)
  )

# animowany snieg
n_frames <- 20
snow_frames <- lapply(1:n_frames, function(f) {
  data.frame(
    x = runif(100, min = -35, max = 35),
    y = runif(100, min = -5, max = 35),
    alpha = runif(100, 0.3, 0.8),
    frame = f
  )
}) %>% bind_rows()



anim_tree <- ggplot() +
  theme_void() +
  theme(panel.background = element_rect(fill = "#050A30", color = NA)) +
  
  geom_point(data = snow_frames, aes(x = x, y = y, alpha = alpha, group = x), 
             color = "white", size = 1.5, shape = 8) +
  
  geom_rect(aes(xmin = -1.5, xmax = 1.5, ymin = -3, ymax = 0), fill = "#3E2723") +

  geom_path(data = tree_data, aes(x = x, y = y, size = size), 
            color = "#004B23", linejoin = "round") +

  geom_point(data = ornaments, aes(x = x, y = y, color = color, size = val)) +
  scale_color_identity() +
  
  annotate("point", x = 0, y = 10 * pi + 1, color = "#FFD700", shape = 8, size = 10, stroke = 2) +
  
  annotate("text", x = 0, y = -6, label = "TWD 2025 - Merry Christmas", 
           color = "#A8DADC", family = "mono", size = 4) +
  
  transition_states(frame, transition_length = 1, state_length = 1) +
  enter_fade() + 
  exit_fade() +
  coord_fixed(ratio = 1.5) +
  guides(size = "none", alpha = "none")

animate(anim_tree, nframes = 40, fps = 10, width = 500, height = 700, renderer = gifski_renderer())
anim_save("choinka_hw5.gif")
