library(ggplot2)
library(dplyr)

warstwy_choinki <- data.frame(
  x = c(0, -1, 1, 0, -0.8, 0.8, 0, -0.6, 0.6, 0, -0.4, 0.4),
  y = c(2.5, 0.5, 0.5, 3.5, 1.5, 1.5, 4.3, 2.5, 2.5, 5.0, 3.5, 3.5),
  warstwa = rep(c("dol", "srodek1", "srodek2", "gora"), each = 3)
)

pien <- data.frame(xmin = -0.2, xmax = 0.2, ymin = 0, ymax = 1)

set.seed(123)
ilosc_bombek <- 55
bombki <- data.frame(y = runif(ilosc_bombek, 0.7, 4.8)) %>%
  mutate(
    max_x = (5 - y) * 0.18, 
    x = runif(n(), -max_x, max_x),
    kolor = sample(c("lightblue1", "cyan4", "steelblue1", "skyblue"), n(), replace = TRUE),
    rozmiar = runif(n(), 3, 5)
  )

snieg <- data.frame(
  x = runif(150, -1.5, 1.5),
  y = runif(150, 0, 6)
)

choinka <- ggplot() +
  geom_point(data = snieg, aes(x = x, y = y), color = "white", alpha = 0.6, shape = 42, size = 4)+
  geom_rect(data = pien, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = "brown4") +
  geom_polygon(data = warstwy_choinki, aes(x = x, y = y, group = warstwa), fill = "forestgreen") +
  geom_point(data = bombki, aes(x = x, y = y, color = kolor, size = rozmiar)) +
  geom_point(aes(x = 0, y = 5), shape = 8, size = 10, color = "gold", stroke = 2) +
  scale_color_identity() +
  scale_size_identity() +
  theme_void() +
  theme(panel.background = element_rect(fill = "midnightblue"))
choinka

ggsave("MaciatekHelena.png", plot = choinka)
