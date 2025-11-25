library(waffle)
library(ggplot2)
df_1 <- data.frame(
  kraj = c(
    "GRECJA","WŁOCHY","TURCJA","CHORWACJA","HISZPANIA","BUŁGARIA","ALBANIA","WIELKA BRYTANIA",
    "EGYPT","POLSKA","MAROKO","CZARNOGÓRA","FRANCJA","PORTUGALIA","ZJEDNOCZONE EMIRATY ARABSKIE",
    "TUNEZJA","NIEMCY","IZRAEL","SZWAJCARIA","SZWECJA","DANIA","JORDANIA","USA","IRLANDIA",
    "KUWEJT","ARABIA SAUDYJSKA","MALEDIWY","AUSTRA","KENIA","ISLANDIA","FINLANDIA","CYPR"
  ),
  loty = c(
    43,24,22,17,16,14,9,7,
    6,4,4,4,3,3,3,
    2,2,2,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1
  )
)

top8 <- df_1 %>% arrange(desc(loty)) %>% slice(1:8)

inne_suma <- df_1 %>%
  arrange(desc(loty)) %>%
  slice(-1:-8) %>%
  summarise(loty = sum(loty)) %>%
  pull(loty)

dane_kraje <- c(
  setNames(top8$loty, top8$kraj),
  Inne = inne_suma
)
kolory3 <- c(
  "#08306B", "#08519C", "#2171B5", "#4292C6",
  "#6BAED6", "#9ECAE1", "#C6DBEF", "#DEEBF7",
   "lightpink"
)

dane_kraje_sorted <- dane_kraje[order(dane_kraje, decreasing = TRUE)]
procenty <- dane_kraje / sum(dane_kraje) * 100

tiles_vec <- floor(procenty)

diff <- 100 - sum(tiles_vec)

if (diff > 0) {
  reszty <- procenty - tiles_vec
  idx <- order(reszty, decreasing = TRUE)[1:diff]
  tiles_vec[idx] <- tiles_vec[idx] + 1
} else if (diff < 0) {
  reszty <- procenty - tiles_vec
  idx <- order(reszty, decreasing = FALSE)[1:abs(diff)]
  tiles_vec[idx] <- tiles_vec[idx] - 1
}

tiles_vec

p <- waffle::waffle(
  parts = tiles_vec,
  rows  = 5,
  size  = 0.4,          
  colors = kolory3,     
  legend_pos = "right"
)


p$layers[[1]]$aes_params$colour <- "black"

p +
  labs(
    title    = "Liczba lotów wakacyjnych",
    subtitle = "100 kafelków = 100% lotów, 1 kafelek ≈ 2%",
    fill     = "Kraj"
  ) +
  scale_x_continuous(breaks = NULL) +
  scale_y_continuous(breaks = NULL) +
  theme(
    plot.title      = element_text(face = "bold", color = "white"),
    plot.subtitle   = element_text(size = 10, color = "white"),
    legend.title    = element_text(color = "white"),
    legend.text     = element_text(color = "white"),
    axis.text       = element_blank(),
    axis.title      = element_blank(),
    panel.grid      = element_blank(),
    plot.background  = element_rect(fill = "black", color = NA),
    panel.background = element_rect(fill = "black", color = NA),
    legend.background = element_rect(fill = "black", color = NA),
    legend.key        = element_rect(fill = "black", color = NA)
  )
