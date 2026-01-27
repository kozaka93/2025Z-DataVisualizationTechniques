library(dplyr)
library(ggplot2)
library(gganimate)


trojkat_choinki <- function(srodek_x, podstawa_y, szerokosc, wysokosc) {
  data.frame(
    srodek_x = srodek_x,
    podstawa_y = podstawa_y,
    szerokosc = szerokosc,
    wysokosc = wysokosc,
    x = c(srodek_x - szerokosc/2, srodek_x, srodek_x + szerokosc/2),
    y = c(podstawa_y, podstawa_y + wysokosc, podstawa_y)
  )
}

cien_choinki <- function(trojkat, skala = 0.45) {
  with(trojkat,
       data.frame(
         x = c(
           srodek_x + szerokosc/2 * skala,
           srodek_x + szerokosc/2,
           srodek_x
         ),
         y = c(
           podstawa_y + wysokosc * 0.15,
           podstawa_y,
           podstawa_y + wysokosc
         )
       ))
}

gwiazda_piecioramienna <- function(x0, y0, promien_duzy = 0.35, promien_maly = 0.15) {
  katy <- seq(0, 2*pi, length.out = 11)[-11]
  promienie <- rep(c(promien_duzy, promien_maly), 5)
  data.frame(
    x = x0 + promienie * sin(katy),
    y = y0 + promienie * cos(katy)
  )
}


choinka_dol <- trojkat_choinki(5, 0.8, 6.6, 2.8)
choinka_srodek <- trojkat_choinki(5, 2.1, 4.6, 2.2)
choinka_gora <- trojkat_choinki(5, 3.6, 3.0, 1.8)

cien_dol <- cien_choinki(choinka_dol, 0.50)
cien_srodek <- cien_choinki(choinka_srodek, 0.48)
cien_gora <- cien_choinki(choinka_gora, 0.46)


pien <- data.frame(
  x = c(4.6, 5.4, 5.4, 4.6),
  y = c(0.8, 0.8, 0.5, 0.5)
)


lancuch_na_choince <- function(trojkat, y_lewy, y_prawy) {
  with(trojkat,
       data.frame(
         x0 = srodek_x - (szerokosc/2) * (1 - (y_lewy - podstawa_y)/wysokosc),
         y0 = y_lewy,
         x1 = srodek_x + (szerokosc/2) * (1 - (y_prawy - podstawa_y)/wysokosc),
         y1 = y_prawy
       ))
}

lancuch_dol <- lancuch_na_choince(choinka_dol, 1.5, 2.1)
lancuch_srodek <- lancuch_na_choince(choinka_srodek, 2.8, 3.4)
lancuch_gora <- lancuch_na_choince(choinka_gora, 4.1, 4.6)

rysuj_lancuch <- function(l) {
  data.frame(x = c(l$x0, l$x1), y = c(l$y0, l$y1))
}


lampki_na_lancuchu <- function(lancuch, liczba, przesuniecie) {
  pozycje_1 <- seq(0.12, 0.88, length.out = liczba)
  pozycje_2 <- pozycje_1 + przesuniecie
  
  bind_rows(
    data.frame(t = 1, p = pozycje_1),
    data.frame(t = 2, p = pozycje_2)
  ) %>%
    mutate(
      x = lancuch$x0 + p * (lancuch$x1 - lancuch$x0),
      y = lancuch$y0 + p * (lancuch$y1 - lancuch$y0),
      kolor = "#ff77cc"
    )
}

lampki <- bind_rows(
  lampki_na_lancuchu(lancuch_dol, 6, 0.06),
  lampki_na_lancuchu(lancuch_srodek, 4, 0.06),
  lampki_na_lancuchu(lancuch_gora, 3, 0.06)
)


gwiazda <- bind_rows(
  gwiazda_piecioramienna(5, 5.8, 0.30, 0.13) %>% mutate(t = 1),
  gwiazda_piecioramienna(5, 5.8, 0.38, 0.17) %>% mutate(t = 2)
)


ggplot() +
  
  geom_polygon(data = choinka_dol, aes(x,y), fill = "#0b7d3b") +
  geom_polygon(data = cien_dol, aes(x,y), fill = "#064f25") +
  
  geom_polygon(data = choinka_srodek, aes(x,y), fill = "#0b7d3b") +
  geom_polygon(data = cien_srodek, aes(x,y), fill = "#064f25") +
  
  geom_polygon(data = choinka_gora, aes(x,y), fill = "#0b7d3b") +
  geom_polygon(data = cien_gora, aes(x,y), fill = "#064f25") +
  
  geom_polygon(data = pien, aes(x,y), fill = "#8b4513") +
  
  geom_polygon(
    data = gwiazda,
    aes(x,y,group=t),
    fill = "#f2c94c"
  ) +
  
  geom_line(data = rysuj_lancuch(lancuch_dol), aes(x,y), colour = "#1a1a1a") +
  geom_line(data = rysuj_lancuch(lancuch_srodek), aes(x,y), colour = "#1a1a1a") +
  geom_line(data = rysuj_lancuch(lancuch_gora), aes(x,y), colour = "#1a1a1a") +
  
  geom_point(
    data = lampki,
    aes(x,y),
    shape = 8,
    size = 4,
    colour = "#ff77cc"
  ) +
  
  coord_equal(xlim = c(2,8), ylim = c(0.3,6.2)) +
  theme_void() +
  theme(panel.background = element_rect(fill = "#001a3d")) +
  
  transition_states(
    t,
    transition_length = 1,
    state_length = 1
  )

animate(animacja, nframes = 50, fps = 180, width = 700, height = 430, renderer = gifski_renderer(loop = TRUE))

anim_save("choinka.gif", animation = animacja)






