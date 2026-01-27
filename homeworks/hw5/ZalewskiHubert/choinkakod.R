library(ggplot2)
library(dplyr)

set.seed(29)

stworz_pietro <- function(n, y_min, y_max, szerokosc_dolu, margines = 1.0) {
  real_width <- szerokosc_dolu * margines
  x <- runif(n, -real_width, real_width)
  y <- runif(n, y_min, y_max)
  max_x_na_y <- (y_max - y) / (y_max - y_min) * real_width
  data.frame(x, y) %>% filter(abs(x) < max_x_na_y)
}

stworz_lancuch <- function(y_srodek, szerokosc_paraboli, zwis, kolor, y_max_tree, y_min_tree, width_tree) {
  x <- seq(-szerokosc_paraboli, szerokosc_paraboli, length.out = 500)
  y <- (zwis * x^2) + (y_srodek - zwis)
  data.frame(x, y, Kolor = kolor) %>%
    filter(y < y_max_tree & y > y_min_tree) %>%
    mutate(max_x_allowed = (y_max_tree - y) / (y_max_tree - y_min_tree) * width_tree) %>%
    filter(abs(x) < (max_x_allowed - 0.15))
}

p1_par <- c(0.5, 4.5, 3.6)
p2_par <- c(3.5, 7.5, 2.9)
p3_par <- c(6.5, 9.8, 2.2)

df_igly <- bind_rows(
  stworz_pietro(20000, p1_par[1], p1_par[2], p1_par[3]),
  stworz_pietro(15000, p2_par[1], p2_par[2], p2_par[3]),
  stworz_pietro(10000, p3_par[1], p3_par[2], p3_par[3])
)

df_bombki <- bind_rows(
  stworz_pietro(30, p1_par[1], p1_par[2], p1_par[3], margines = 0.95),
  stworz_pietro(20, p2_par[1], p2_par[2], p2_par[3], margines = 0.95),
  stworz_pietro(20, p3_par[1], p3_par[2], p3_par[3], margines = 0.95)
) %>%
  mutate(Kolor = sample(c("red", "yellow", "blue", "purple", "green"), n(), replace = TRUE))

df_lancuchy <- bind_rows(
  stworz_lancuch(1.5, 3.8, 0.40, "silver", p1_par[2], p1_par[1], p1_par[3]),
  stworz_lancuch(3.2, 3.2, 0.30, "gold", p1_par[2], p1_par[1], p1_par[3]),
  stworz_lancuch(4.8, 3.0, 0.35, "silver", p2_par[2], p2_par[1], p2_par[3]),
  stworz_lancuch(6.2, 2.5, 0.25, "gold", p2_par[2], p2_par[1], p2_par[3]),
  stworz_lancuch(7.8, 2.0, 0.20, "silver", p3_par[2], p3_par[1], p3_par[3])
)

ggplot() +
  geom_point(data = df_igly, aes(x, y), color = "darkgreen", alpha = 0.3, size = 1) +
  
  geom_point(data = df_lancuchy, aes(x, y, color = Kolor), size = 2.5, show.legend = FALSE) +
  
  geom_point(data = df_bombki, aes(x, y, color = Kolor), size = 6, show.legend = FALSE) +
  
  annotate("text", x = 0, y = 10, label = "\u2605", color = "#FFD700", size = 30) +
  
  annotate("text", x = 0, y = 0, label = "Merry Christmas", color = "white", 
           size = 10, fontface = "italic", family = "serif") +
  scale_color_manual(values = c(
    "red" = "red",
    "blue" = "blue",
    "yellow" = "yellow",
    "purple" = "purple",
    "green" = "green",
    "gold" = "#FFD700",
    "silver" = "#E0E0E0"
  )) +
  
  theme_void() +
  theme(
    plot.background = element_rect(fill = "black", color = NA),
    legend.position = "none"
  )

ggsave("Choinka.png", width = 8, height = 9, dpi = 300)