library(tidyverse)
library(gganimate)


punkty <- data.frame()
sekwencja <- seq(0.1, 1, length.out = 20)

for (i in sekwencja) {
  szerokosc <- (1 - i) * 0.5
  j <- seq(-szerokosc, szerokosc, length.out = 10)
  temp <- data.frame(x = j, y = i)
  punkty <- rbind(punkty, temp)
}

dane <- data.frame()

for (i in 1:150) {
  start_y <- runif(1, 0.05, 0.9)
  aktualny_x <- 0
  aktualny_y <- start_y
  
  sciezka <- data.frame(x = aktualny_x, y = aktualny_y, krok = 1, galaz = i)
  
  for (s in 2:50) {

    dyst <- sqrt((punkty$x - aktualny_x)^2 + (punkty$y - aktualny_y)^2)
    ktory <- which.min(dyst)
    naj_x <- punkty$x[ktory]
    naj_y <- punkty$y[ktory]
    
    dyst_x <- naj_x - aktualny_x
    dyst_y <- naj_y - aktualny_y

    if (sqrt(dyst_x^2 + dyst_y^2) > 0) {
      dyst_x <- dyst_x / sqrt(dyst_x^2 + dyst_y^2)
      dyst_y <- dyst_y / sqrt(dyst_x^2 + dyst_y^2)
    }
    
    aktualny_x <- aktualny_x + (dyst_x * 0.7 + runif(1, -1, 1) * 0.3) * (0.08 * (1 - start_y + 0.2))
    aktualny_y <- aktualny_y + (dyst_y * 0.7 + runif(1, -1, 1) * 0.3) * (0.08 * (1 - start_y + 0.2))
    
    krok <- data.frame(x = aktualny_x, y = aktualny_y, krok = s, galaz = i)
    sciezka <- rbind(sciezka, krok)
  }
  dane <- rbind(dane, sciezka)
}

bombki <- data.frame()

for (j in 1:80) {
  y_b <- runif(1, 0.1, 0.9)
  limit_x <- (1 - y_b) * 0.4
  x_b <- runif(1, -limit_x, limit_x)
  
  b <- data.frame(
    x = x_b, 
    y = y_b, 
    color = sample(c("red", "gold", "white"), 1)
  )
  bombki <- rbind(bombki, b)
}

p <- ggplot() +
  geom_path(data = dane, aes(x = x, y = y, group = galaz, color = y, size = (1/krok)^0.7), 
            alpha = 0.6, show.legend = FALSE) +
  
  geom_point(data = bombki, aes(x = x, y = y, fill = color), 
             shape = 21, size = 3, color = "black") +

  annotate("point", x = 0, y = 0.95, color = "gold", shape = 8, size = 8, stroke = 2) +
  

  scale_color_gradient(low = "#00441b", high = "#5ab4ac") +
  scale_fill_identity() +
  scale_size_identity() +
  theme_void() +
  theme(plot.background = element_rect(fill = "#050a14", color = NA)) +
  
 
  transition_reveal(krok)

animate(p, nframes = 100, fps = 20, end_pause = 30, width = 600, height = 600)

