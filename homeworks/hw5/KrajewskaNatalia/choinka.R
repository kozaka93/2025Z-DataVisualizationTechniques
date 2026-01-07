library(ggplot2)
library(dplyr)

choinka <- data.frame(
  grupa = c(rep("Pien", 4), rep("L4", 3), rep("L3", 3), rep("L2", 3), rep("L1", 3)),
  x = c(-0.4, 0.4, 0.4, -0.4, -5, 5, 0, -4, 4, 0, -3, 3, 0, -2, 2, 0),
  y = c(0, 0, 1.2, 1.2, 1.2, 1.2, 6, 4, 4, 8, 6, 6, 10, 8, 8, 11),
  kolor = c(rep("brown", 4), rep("forestgreen", 12))
)

set.seed(2025)
bombki <- data.frame(x = numeric(), y = numeric(), kolor = character())
for (i in 1:45) {
  y_los <- runif(1, 1.5, 10.5)
  szerokosc <- case_when(
    y_los < 4  ~ 5 * (1 - (y_los - 1.2) / 4.8),
    y_los < 6  ~ 4 * (1 - (y_los - 4) / 4),
    y_los < 8  ~ 3 * (1 - (y_los - 6) / 4),
    TRUE       ~ 2 * (1 - (y_los - 8) / 3)
  )
  x_los <- runif(1, -(szerokosc - 0.3), (szerokosc - 0.3))
  bombki <- rbind(bombki, data.frame(x = x_los, y = y_los, kolor = sample(c("red", "gold", "white", "purple", "#C0C0C0"), 1)))
}

poziomy_y <- c(3.2, 5.2, 7.2, 9.2)
szerokosci_y <- c(2.8, 2.2, 1.6, 1.0)
lancuchy <- data.frame(x = numeric(), y = numeric(), grupa = character())
for (i in 1:4) {
  x_sekwencja <- seq(-szerokosci_y[i], szerokosci_y[i], length.out = 50)
  y_sekwencja <- poziomy_y[i] - 0.5 * cos(x_sekwencja / szerokosci_y[i] * pi / 2)
  lancuchy <- rbind(lancuchy, data.frame(x = x_sekwencja, y = y_sekwencja, grupa = as.character(i)))
}

katy <- seq(90, 450, length.out = 11)[1:10]
promienie <- rep(c(0.8, 0.35), 5)
gwiazda <- data.frame(
  x = promienie * cos(katy * pi / 180),
  y = 11 + promienie * sin(katy * pi / 180)
)

ggplot() +
  geom_polygon(data = choinka, aes(x = x, y = y, group = grupa, fill = kolor), color = NA) +
  geom_path(data = lancuchy, aes(x = x, y = y, group = grupa), color = "gold", linewidth = 1.2, alpha = 0.8) +
  geom_point(data = bombki, aes(x = x, y = y, color = kolor), size = 3) +
  geom_polygon(data = gwiazda, aes(x = x, y = y), fill = "gold", color = NA) +
  scale_fill_identity() +
  scale_color_identity() +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "#001f3f", color = NA),
    plot.background = element_rect(fill = "#001f3f", color = NA),
    plot.title = element_text(color = "white", hjust = 0.5, size = 20, face = "bold", margin = margin(t = 20))
  ) +
  ggtitle("Wesołych Świąt!") +
  coord_fixed()
