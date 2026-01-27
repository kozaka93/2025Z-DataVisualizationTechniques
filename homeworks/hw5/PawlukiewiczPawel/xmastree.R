
library(ggplot2)
library(dplyr)
library(tibble)


n_points <- 15000 
height_max <- 8 

tree_data <- tibble(
  t = seq(0, 25 * pi, length.out = n_points), 
  h = seq(0, height_max, length.out = n_points) 
) %>%
  mutate(
    r = (height_max - h) / height_max, 
    
    x = r * cos(t) * 3.5 + runif(n_points, -0.1, 0.1),
    
    y = h + runif(n_points, -0.15, 0.15), # żeby było trochę szumu
    
    color_val = runif(n_points, 0, 1) # różne odcienie zieleni
  )
# bombki
set.seed(133) 
baubles <- tree_data %>%
  sample_n(226, weight = r) %>% 
  mutate(
    color = sample(c("red", "gold", "skyblue", "magenta", "hotpink", "aquamarine"), 226, replace = TRUE),
    size = runif(226, 2, 4)
  )

# gwiazda
star <- data.frame(x = 0, y = height_max+0.1)

# pień
trunk <- data.frame(
  x = 0, 
  y = -0.5, 
  width = 0.8, 
  height = 1.2
)

# cała choinka
plot <- ggplot() +
  # pień
  geom_tile(data = trunk, aes(x = x, y = y, width = width, height = height), 
            fill = "tan4") + # TU BRAKOWAŁO NAWIASU
  
  # gałęzie
  geom_point(data = tree_data, aes(x = x, y = y, color = color_val), 
             size = 1.5, alpha = 0.8, show.legend = FALSE) +
  scale_color_gradient(low = "#004d00", high = "#33cc33", guide = "none") + 
  
  # bombki
  geom_point(data = baubles, aes(x = x, y = y, color = I(color), size = I(size))) +
  
  # gwiazda (a bardziej romb)
  geom_point(data = star, aes(x = x, y = y), shape = 23, fill = "gold", color = "orange", size = 14, stroke = 1.5) +
  
  # tło
  theme_void() + 
  theme(
    panel.background = element_rect(fill = "navy", color = NA), 
    plot.background = element_rect(fill = "navy", color = NA),
    plot.title = element_text(color = "white", hjust = 0.5, vjust = -1, size = 30, face = "bold", margin = margin(b = 40))
  ) + 
  
  labs(
    title = "Wesołych Świąt!" # wesołych świąt
  ) +
  coord_fixed(ratio = 1)

print(plot)



ggsave("xmastree.png", plot = plot, width = 8, height = 10, dpi = 300)

