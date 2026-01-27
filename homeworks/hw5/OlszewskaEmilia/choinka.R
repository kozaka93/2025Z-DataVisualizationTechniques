library(ggplot2)
library(gganimate)
library(dplyr)

set.seed(2026)
liczba_serca <- 3000 
choinka_data <- data.frame(
  x = runif(liczba_serca, -5, 5),
  y = runif(liczba_serca, 0, 10)
) %>%
  filter(abs(x) < (10 - y) * 0.5)


liczba_swiatelka <- 1100 
u <- seq(0, 1, length.out = liczba_swiatelka)

t_seq <- 10 * (u ^ 1.8) 

lancuch_swiatelek <- data.frame(
  id = 1:length(t_seq),
  y = t_seq,
  x = sin(t_seq * 5) * ((10 - t_seq) * 0.5 + 0.2),
  phase_shift = runif(length(t_seq), 0, 2 * pi)
)

liczba_klatek <- 30 
lancuch_gif <- list()

for(i in 1:liczba_klatek) {
  lancuch <- lancuch_swiatelek
  lancuch$frame <- i
  sin_zmiana <- sin((i / liczba_klatek * 2 * pi) + lancuch$phase_shift)
  lancuch$alpha_val <- (sin_zmiana + 1) / 2 * 0.9 + 0.1
  lancuch_gif[[i]] <- lancuch
}
lancuch_koncowy <- do.call(rbind, lancuch_gif)


p <- ggplot() +
  geom_text(data = choinka_data, aes(x, y), label = "♥", 
            color = "maroon3", size = 5.5) + 
  geom_point(data = lancuch_koncowy, aes(x, y, alpha = alpha_val), 
             color = "white", size = 2.5, shape = 16) + 
  annotate("point", x = 0, y = 10.5, color = "gold2", size = 12, shape = 8)+
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#1a0510", color = NA), 
    legend.position = "none"
  ) +
  transition_manual(frame)

anim <- animate(p, 
                nframes = liczba_klatek, 
                fps = 15, 
                width = 550, height = 650, 
                renderer = gifski_renderer())

anim_save("choinka.gif", animation = anim)
utils::browseURL("choinka.gif")