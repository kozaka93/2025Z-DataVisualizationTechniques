library(ggplot2)
library(gganimate)
library(tidyr)
library(dplyr)

n_rows <- 25
n_cols <- 21
middle <- 11
n_frames <- 20 
n_snow <- 7 

grid_base <- expand.grid(x = 1:n_cols, y = 1:n_rows) %>%
  mutate(val = "0")

for (i in 3:19) {
  width <- floor(((i - 2) / 17) * 9)
  grid_base$val[grid_base$y == i & 
                  grid_base$x >= (middle - width) & 
                  grid_base$x <= (middle + width)] <- "1"
}

grid_base$val[grid_base$y %in% 20:24 & grid_base$x %in% (middle-1):(middle+1)] <- "2"

bombki_pos <- data.frame(
  x = c(11, 9, 13, 11, 7, 15, 11, 6, 16),
  y = c(5, 8, 8, 11, 14, 14, 16, 18, 18),
  type = sample(c("4", "5"), 9, replace = TRUE)
)

for(i in 1:nrow(bombki_pos)) {
  grid_base$val[grid_base$x == bombki_pos$x[i] & grid_base$y == bombki_pos$y[i]] <- bombki_pos$type[i]
}

set.seed(43)
snow_anim <- data.frame(
  flake_id = 1:n_snow,
  x = sample(1:n_cols, n_snow, replace = TRUE),
  start_y = sample(1:n_rows, n_snow, replace = TRUE)
) %>%
  crossing(frame = 1:n_frames) %>%
  mutate(
    y = ((start_y + frame - 2) %% n_rows) + 1,
    val = "6"
  )

tile_colors <- c(
  "0" = "#050B18", 
  "1" = "#145214", 
  "2" = "#4E342E", 
  "3" = "#FFD700", 
  "4" = "#E64A19", 
  "5" = "#0288D1", 
  "6" = "#FFFFFF"  
)

grid_base$val[grid_base$y == 3 & grid_base$x == middle] <- "3"
grid_base$val[grid_base$y == 2 & grid_base$x == middle] <- "3"
grid_base$val[grid_base$y == 2 & grid_base$x == middle + 1] <- "3"
grid_base$val[grid_base$y == 2 & grid_base$x == middle -1] <- "3"
grid_base$val[grid_base$y == 1 & grid_base$x == middle] <- "3"

p <- ggplot() +
  geom_tile(data = grid_base, aes(x = x, y = y, fill = val), color = "#0A1221", linewidth = 0.1) +
  geom_tile(data = snow_anim, aes(x = x, y = y, fill = val), color = "white", linewidth = 0.1) +
  scale_y_reverse() + 
  scale_fill_manual(values = tile_colors) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#050B18", color = NA),
    panel.background = element_rect(fill = "#050B18", color = NA),
    plot.title = element_text(hjust = 0.5, color = "white", face = "bold", size = 22)
  ) +
  ggtitle("WESOŁYCH ŚWIĄT!!!") +
  transition_manual(frame)

anim <- animate(p, nframes = n_frames, fps = 10, width = 504, height = 600, renderer = gifski_renderer(), bg = "#050B18")
anim_save("choinka.gif", animation = anim)