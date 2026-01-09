
library(ggplot2)
library(dplyr)

set.seed(2137)
n_points <- 8000
tree_height <- 10

df <- data.frame(
  y = runif(n_points, 0, tree_height)
) %>%
  mutate(
    sd = (tree_height - y) / 4, 
    x = rnorm(n(), mean = 0, sd = sd),
    type = "igla"
  )

n_baubles <- 40
baubles <- df %>%
  sample_n(n_baubles) %>%
  mutate(type = sample(c("bombka_czerwona", "bombka_zlota"), n(), replace = TRUE))

star <- data.frame(x = 0, y = tree_height + 0.2, sd = 0, type = "gwiazda")

final_data <- bind_rows(df, baubles, star)

p <- ggplot(final_data, aes(x = x, y = y)) +
  geom_point(data = subset(final_data, type == "igla"), 
             color = "darkgreen", alpha = 0.6, size = 0.8, shape = 16) +
  geom_point(data = subset(final_data, type %in% c("bombka_czerwona", "bombka_zlota")), 
             aes(color = type), size = 3) +
  geom_point(data = subset(final_data, type == "gwiazda"), 
             color = "yellow", size = 8, shape = 8) + 
  scale_color_manual(values = c("bombka_czerwona" = "red", "bombka_zlota" = "gold")) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#051e3e", color = NA),
    legend.position = "none",
  )

print(p)
ggsave("choinka.png")
