library(ggplot2)
library(dplyr)

set.seed(2025)
ile_igiel <- 5000
ile_gwiazdek <- 10

dane <- data.frame(
  x = runif(ile_igiel, -5, 5),
  y = runif(ile_igiel, 0, 10)) %>%
  filter(abs(x) < (10 - y) / 2)

bombki <- dane %>%
  sample_n(100) %>%
  mutate(which_color = runif(n(), 0, 1))

gwiazdki <- data.frame(x = runif(ile_gwiazdek, -5, 5),
  y = runif(ile_gwiazdek, 5, 10)) %>%
  filter(abs(x) > (10 - y) / 2)


choinka <- ggplot() +
  geom_point(data = dane, aes(x, y), color = "#378902", alpha = 0.5, size = 2) +
  geom_point(data = bombki,aes(x, y, color = which_color, size = 2.5)) +
  geom_point(aes(x = 0, y = 10), shape = 8, size = 10, color = "#ffd100", stroke = 2) + 
  geom_point(data = gwiazdki, aes(x,y), shape = 8, size = 2, color = "yellow", alpha = 0.8, stroke = 2) +
  scale_color_gradientn(colors = c("#9000c1", "#0097d2", "#cb0088", "#ff9400")) +
  guides(color = "none", size = "none") +
  theme_void() + 
  theme(plot.background = element_rect(fill = "#020031"))
choinka
