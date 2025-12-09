library(ggplot2)
library(patchwork)
library(ggimage)
library(forcats)
library(extrafont)
library(dplyr)
library(tidyr)

#   importowanie czcionek:
# font_import() 
#   zaladuj czcionki dla Windows:
# loadfonts(device = "win")  

#sciezka do folderu o nazwie "dane"
path <- "C:/Users/gabri/OneDrive/Pulpit/TechnikiWizualizacjiDanych/pracadomowa4/dane"
setwd(path)

#kolory i czcionka
colors <- c(
  rgb(189/255, 83/255, 48/255),
  rgb(0, 100/255, 0),
  rgb(38/255, 50/255, 91/255),
  rgb(168/255, 214/255, 133/255),
  rgb(216/255, 166/255, 14/255),
  rgb(240/255, 136/255, 236/255),
  rgb(101/255, 67/255, 33/255),
  rgb(47/255, 62/255, 44/255)
)

fnt <- "Bahnschrift"


#ladowanie danych
animals <- as.data.frame(read.csv("longbeach.csv"))
animals$outcome_date

#moje opracowanie wykresu

#wykresy dla kazdego gatunku
gatunki <- animals %>% filter(outcome_type == "adoption") %>%  mutate(rok_adopcji = as.numeric(format(as.Date(outcome_date), "%Y"))) %>% group_by(rok_adopcji, animal_type) %>%
  summarise(liczba = n()) %>%
  mutate(animal_type = factor(animal_type, levels = rev(
    c(
      "cat",
      "dog",
      "rabbit",
      "guinea pig",
      "other",
      "bird",
      "reptile",
      "livestock"
    )
  )))


p1 <- ggplot(gatunki, aes(x = rok_adopcji, y = liczba, color = animal_type)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = 2017:2025) +
  theme_minimal(base_family = fnt) +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    strip.text = element_blank(),
    panel.spacing = unit(2, "lines")
  ) +
  geom_vline(
    xintercept = c(2017:2025),
    linetype = "solid",
    color = "gray"
  ) +
  facet_wrap( ~ animal_type, scales = "free_y", ncol = 1) +
  scale_color_manual(values = colors)

#wykres glowny
p2 <- ggplot(gatunki, aes(x = rok_adopcji, y = liczba, fill = animal_type)) +
  scale_x_continuous(breaks = 2017:2025) +
  theme_minimal(base_family = fnt) +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 25, margin = margin(b = 30)),
    axis.title.x = element_text(margin = margin(t = 20)),
    axis.title.y = element_text(margin = margin(r = 20))
  ) +
  labs(x = "Year of adoption", y = "Number of adoptions") +
  geom_bar(stat = 'identity') +
  labs(title = "Number of adopted animals at the Long Beach animal shelter") +
  scale_fill_manual(values = colors)

#obrazki i nazwy zwierzat
df <- data.frame(
  x = c(1, 1, 1, 1, 1, 1, 1, 1),
  y = c(1, 2, 3, 4, 5, 6, 7, 8),
  image = rev(
    c(
      "farma.jpg",
      "gady.jpg",
      "ptaki.jpg",
      "inne.jpg",
      "swinka.jpg",
      "krolik.jpg",
      "pies.jpg",
      "kot.jpg"
    )
  )
)


df2 <- data.frame(
  x = c(1, 1, 1, 1, 1, 1, 1, 1),
  y = c(1, 2, 3, 4, 5, 6, 7, 8),
  label = rev(
    c(
      "livestock",
      "reptile",
      "bird",
      "other",
      "guinea pig",
      "rabbit",
      "dog",
      "cat"
    )
  )
)


df2 <- df2 %>%
  mutate(label = factor(label, levels = rev(
    c(
      "cat",
      "dog",
      "rabbit",
      "guinea pig",
      "other",
      "bird",
      "reptile",
      "livestock"
    )
  )))


p3 <- ggplot(df, aes(x, y)) +
  geom_image(aes(image = image), size = 0.1) +
  theme_void()


p4 <- ggplot(df2, aes(x, y, label = label, color = label)) +
  geom_text(size = 6) +
  scale_color_manual(values = colors) +
  theme_minimal(base_family = fnt) +
  theme_void() +
  theme(legend.position = "none")

#razem
p <- p2 + p3 + p4 + p1 + plot_layout(widths = c(3, 0.5, 0.8,1.2))

p


