library(ggplot2)
library(gganimate)
library(dplyr)


n_iter <- 100000
x <- numeric(n_iter)
y <- numeric(n_iter)
x[1] <- 0; y[1] <- 0

# algorytm Barnsley Fern 
for (i in 1:(n_iter - 1)) {
  r <- runif(1)
  if (r < 0.01) {
    x[i+1] <- 0; y[i+1] <- 0.16 * y[i]
  } else if (r < 0.86) {
    x[i+1] <- 0.85 * x[i] + 0.04 * y[i]
    y[i+1] <- -0.04 * x[i] + 0.85 * y[i] + 1.6
  } else if (r < 0.93) {
    x[i+1] <- 0.20 * x[i] - 0.26 * y[i]
    y[i+1] <- 0.23 * x[i] + 0.22 * y[i] + 1.6
  } else {
    x[i+1] <- -0.15 * x[i] + 0.28 * y[i]
    y[i+1] <- 0.26 * x[i] + 0.24 * y[i] + 0.44
  }
}
tree_data <- data.frame(x = x, y = y)




n_frames <- 50  
n_flakes <- 300 

snow_data <- expand.grid(id = 1:n_flakes, frame = 1:n_frames)


set.seed(999)
snow_starts_x <- runif(n_flakes, -3, 3)
snow_starts_y <- runif(n_flakes, 0, 10)
speeds <- runif(n_flakes, 0.1, 0.3) 


snow_data <- snow_data %>%
  mutate(
    x = snow_starts_x[id],
    y = (snow_starts_y[id] - (speeds[id] * frame)) %% 10 
  )


set.seed(123)
ornament_idx <- sample(1:n_iter, size = 150)
base_ornaments <- tree_data[ornament_idx, ]
base_ornaments$color <- sample(c("red", "gold", "cyan", "magenta"), 150, replace = TRUE)
base_ornaments$id <- 1:150

ornament_anim <- expand.grid(id = 1:150, frame = 1:n_frames) %>%
  left_join(base_ornaments, by = "id") %>%
  group_by(frame) %>%
  mutate(
    alpha = runif(n(), 0.4, 1.0) 
  )


p <- ggplot() +
  geom_point(data = tree_data, aes(x, y), color = "darkgreen", size = 0.05, alpha = 0.6) +
  geom_point(data = snow_data, aes(x, y, group = id), color = "white", size = 0.8, alpha = 0.8) +
  geom_point(data = ornament_anim, aes(x, y, color = color, alpha = alpha, group = id), size = 2) +
  geom_point(aes(x = max(tree_data$x), y = max(tree_data$y)), color = "gold", shape = 8, size = 6, stroke = 2) +
  scale_color_identity() +
  scale_alpha_identity() +
  theme_void() +
  theme(plot.background = element_rect(fill = "midnightblue")) +
  coord_fixed(xlim = c(-3, 3), ylim = c(0, 10)) +
  transition_time(frame) +
  ease_aes('linear')


animate(p, nframes = n_frames, fps = 15, width = 500, height = 600, renderer = gifski_renderer())

#anim_save("fraktal_choinka.gif")