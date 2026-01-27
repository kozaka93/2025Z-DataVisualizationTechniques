library(ggplot2)
library(readr)
library(dplyr)

data <- read_csv("pascal_data.csv")

ggplot(data, aes(x = x, y = y)) +
  
  geom_text(
    aes(
      label = value,
      color = value
    ),
    size = 3,
    fontface = "bold"
  ) +
  
  geom_text(
    data = data.frame(x = 0, y = 0.5),
    aes(x, y),
    label = "★",
    color = "gold",
    size = 10,
    inherit.aes = FALSE
  ) +
  
  scale_color_gradient(
    low = "#1b5e20",
    high = "#a5d6a7"
  ) +
  
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")
  
ggsave("choinka.png", width = 6, height = 10, dpi = 300)

