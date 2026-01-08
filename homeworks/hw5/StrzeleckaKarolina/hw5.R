#install.packages("gganimate")
#install.packages("gifski")
#install.packages("png")
 

library(ggplot2)
library(gganimate)
library(gifski)
library(png)


df_choinka <- data.frame(
  dzien = 1:31, #dni grudnia
  szerokosc = seq(1, 15, length.out = 31) #poziom przygotowań świątecznych
)

set.seed(1685)
n_bombek <- 70
df_bombki <- data.frame(
  y_pos = sample(1:31, n_bombek, replace = TRUE),
  kolor = sample(c("grey", "gold", "red"), n_bombek, replace = TRUE)
)

maks_szer <- df_choinka$szerokosc[df_bombki$y_pos]
df_bombki$x_pos <- runif(n_bombek, -maks_szer, maks_szer) * 0.8 


n_klatek <- 20
df_gwiazda <- data.frame(
  czas = 1:n_klatek,
  alpha = abs(sin(seq(0, 3*pi, length.out = n_klatek))) * 0.7 + 0.3
)


n_sniezynki <- 60
df_tlo_sniezynki <- data.frame(
  x = runif(n_sniezynki, -5, 30),
  y = runif(n_sniezynki, -15, 15),
  wielkosc = runif(n_sniezynki, 1, 3)
)


p <- ggplot() +
  geom_point(data = df_tlo_sniezynki, 
             aes(x = x, y = y, size = wielkosc), 
             shape = 8, color = "white") +
  geom_col(data = df_choinka, aes(x = dzien, y = -szerokosc), 
           fill = "darkgreen", width = 1) +
  geom_col(data = df_choinka, aes(x = dzien, y = szerokosc), 
           fill = "darkgreen", width = 1) +

  geom_point(data = df_bombki, aes(x = y_pos, y = x_pos, color = kolor), 
             size = 6) +

  geom_text(data = df_gwiazda, aes(x = -2 , y = 0, alpha = alpha), 
            label = "★", size = 28, color = "gold") +
  
  
  scale_color_identity() +
  coord_flip() +
  scale_x_reverse() +
  theme_void() +
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "navy"),
    plot.background = element_rect(fill = "navy"),
    plot.caption = element_text(color = "white", size = 20, hjust = 0.5, vjust = 5)
  ) +
  labs(caption = "Wesołych Świąt") + 
  
  transition_time(czas)


animate(p, fps = 10, width = 500, height = 600)

#setwd("C:/Users/karol/Desktop/iad_sem_3/techniki_wizualizacji_danych/hw5/StrzeleckaKarolina")



moj_gif <- animate(p, 
                   fps = 10, 
                   width = 500, 
                   height = 600, 
                   renderer = gifski_renderer(),
                   bg = "navy")


anim_save("choinka_16.gif", animation = moj_gif)

