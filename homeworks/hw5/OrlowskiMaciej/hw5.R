library(ggplot2)
library(dplyr)

## ŚNIEG DO TŁA ##

snieg_df <- data_frame(
  x = runif(250, -6, 6),
  y = runif(250, 0, 12),
  size = runif(250, 1, 3)
)

snieg_podloga_df <- data_frame(
  x = c(-10, 10, 10, -10),
  y = c(0.5, 0.5, -2, -2)
)

## CHOINKA ## 

# szkielet drzewa utworzony za pomocą trójkątów

drzewo_df <- data_frame(
  x = c(-4, 4, 0,
        -3.5, 3.5, 0,
        -3, 3, 0),
  y = c(1, 1, 6,
        3.5, 3.5, 7,
        6, 6, 9),
  grupowanie = c("dol", "dol", "dol",
                 "srodek", "srodek", "srodek",
                 "gora", "gora", "gora")
)


# łańcuch stworzony przy pomocy funkcji sin

lancuch_y <- seq(1, 9, by = 0.01)
lancuch_x <- 0.4 * (9 - lancuch_y) * sin(3.5 * lancuch_y)
lancuch <- data.frame(x = lancuch_x, y = lancuch_y)

# bombki wylosowane z rozkladu normalnego

set.seed(20251230)
bombki_df <- data_frame(
  x = c(runif(25, -3, 3),
        runif(15, -2, 2),
        runif(10, -1.5, 1.5)),
  y = c(runif(25, 1, 4),
        runif(15, 3.5, 5.5),
        runif(10, 5.5, 7.5))
)
bombki_kolory = c("#FFFFFF", "#FF00FF", "#9933FF", "#FF9933", "#99CCFF", "#FF0000")

# gwiazda utworzona za pomocą trójkątów i pięciokątu

gwiazda_df <- data_frame(
  x = c(0, 0.5, 0.3, -0.3, -0.5,
        0, 0.5, 0.7,
        0, -0.5, -0.7,
        0.5, 0.3, 1,
        -0.5, -0.3, -1,
        -0.3, 0.3, 0),
  y = c(8.5, 8.8, 9.6, 9.6, 8.8,
        8.5, 8.8, 8,
        8.5, 8.8, 8,
        8.8, 9.6, 9.5,
        8.8, 9.6, 9.5,
        9.6, 9.6, 10.6),
  grupowanie = c('sr', 'sr', 'sr', 'sr', 'sr',
                 'pd', 'pd', 'pd',
                 'ld', 'ld', 'ld',
                 'pg', 'pg', 'pg',
                 'lg', 'lg', 'lg',
                 'g', 'g', 'g')
)


ggplot() +
  geom_polygon(data=snieg_podloga_df, aes(x=x, y=y), fill="#FFFFFF") +
  geom_point(data=snieg_df, aes(x=x, y=y), color="#FFFFFF", size=snieg_df$size) +
  geom_rect(aes(xmin = -0.5, xmax = 0.5, ymin = 0, ymax = 1), fill="#330000") +
  geom_polygon(data=drzewo_df, aes(x=x, y=y, group=grupowanie), fill="#006600") +
  geom_path(data = lancuch, aes(x, y), color="#CC0000", size=3, alpha=0.8) +
  geom_point(data=bombki_df, aes(x=x, y=y), color=sample(bombki_kolory, nrow(bombki_df), replace=TRUE), size=7) +
  geom_polygon(data=gwiazda_df, aes(x=x, y=y, group=grupowanie), fill="#FFFF00") +
  coord_fixed(xlim=c(-5,5), ylim=c(-0.5, 10.9)) +
  theme_void() +
  theme(panel.background=element_rect(fill="#000066"))

