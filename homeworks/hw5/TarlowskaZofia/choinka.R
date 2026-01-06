library(tidyverse)
library(gganimate)
library(gifski)

set.seed(123)

srodek_x <- 20
czubek <- 34.5
podstawa <- 3.2

choinka <- tibble(y = seq(podstawa, czubek, by = 0.22)) %>%
  mutate(
    w = pmax(0.02, pmin(1, (czubek - y) / (czubek - podstawa))) * 10.5,
    x = map(w, ~ seq(srodek_x - .x, srodek_x + .x, by = 0.08))
  ) %>%
  unnest(x) %>%
  select(x, y)

pien <- tibble(
  x = srodek_x + c(-0.55, 0.55, 0.55, -0.55),
  y = c(-0.2, -0.2, 4.0, 4.0)
)

snieg <- map_dfr(1:80, \(k) {
  tibble(
    klatka = k,
    x = runif(70, 6, 32),
    y = runif(70, -2, 37 + 2.4),
    rozmiar = runif(70, 2.0, 6.0),
    znak = "*"
  )
})

girlanda <- function(y_srodek, amplituda, n, faza, nr) {
  w <- pmax(0.02, pmin(1, (czubek - y_srodek) / (czubek - podstawa))) * 10.5 * 0.92
  xs <- seq(srodek_x - w, srodek_x + w, length.out = n)
  tibble(
    lancuch = nr,
    x = xs,
    y = y_srodek + amplituda * sin(seq(faza, 2*pi + faza, length.out = n))
  )
}

baza_lampki <- bind_rows(
  girlanda(30.0, 0.35, 14, 0.5, 1),
  girlanda(26.2, 0.55, 18, 1.2, 2),
  girlanda(22.1, 0.70, 22, 0.3, 3),
  girlanda(17.6, 0.85, 26, 1.5, 4),
  girlanda(12.4, 1.00, 30, 0.9, 5),
  girlanda(7.2,  1.10, 34, 1.1, 6)
) %>%
  mutate(
    kolor = sample(c("#ff3b30", "#ffcc00", "#34c759", "#0a84ff", "#bf5af2"), n(), TRUE),
    faza = runif(n(), 0, 2*pi),
    rozmiar_bazowy = runif(n(), 2.2, 4.2)
  )

lampki <- crossing(klatka = 1:80, baza_lampki) %>%
  mutate(
    blik = (sin(klatka * 0.25 + faza) + 1) / 2,
    alfa = 0.20 + 0.80 * blik,
    rozmiar = rozmiar_bazowy * (0.90 + 0.40 * blik)
  )

rysunek <- ggplot() +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = "#6c8fc7") +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 2.2, fill = "#e8f3f7") +
  
  geom_text(data = snieg, aes(x, y, label = znak, size = rozmiar), color = "white", alpha = 0.8) +
  
  geom_polygon(data = pien, aes(x, y), fill = "#4b1b1b") +
  geom_point(data = choinka, aes(x, y), color = "#083002", size = 0.55) +
  
  geom_path(
    data = baza_lampki %>% arrange(lancuch, x),
    aes(x, y, group = lancuch),
    color = "#3a2a10", linewidth = 0.5, alpha = 0.55
  ) +
  
  geom_point(data = lampki, aes(x, y, size = rozmiar * 2.1, color = kolor, alpha = alfa * 0.25)) +
  geom_point(data = lampki, aes(x, y, size = rozmiar, color = kolor, alpha = alfa)) +
  
  geom_text(aes(x = srodek_x, y = czubek + 0.9), label = "★", color = "gold", size = 12, fontface = "bold") +
  
  scale_size_identity() +
  scale_color_identity() +
  scale_alpha_identity() +
  coord_fixed(xlim = c(6, 32), ylim = c(-2, 37)) +
  theme_void() +
  transition_manual(klatka) +
  ease_aes("linear")

animacja <- animate(
  rysunek,
  nframes = 80, fps = 5,
  width = 520, height = 520,
  renderer = gifski_renderer(loop = TRUE)
)

anim_save("choinka.gif", animacja)
