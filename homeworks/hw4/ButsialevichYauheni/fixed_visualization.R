#ORIGINAL POST: https://x.com/simisani10/status/1775148173045973045/photo/1
#ORIG CODE: https://github.com/sndaba/2024TidyTuesdayWithRstats/tree/main/week14
#ORIG DATA: https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-04-02/readme.md

install.packages('treemapify')

library(ggplot2)
library(tidyverse)
library(treemapify)
library(showtext)
library(sysfonts)

# Uzasadnienie:
# Oryginalny wykres błędnie wykorzystuje ciągły gradient kolorystyczny
# do prezentacji zmiennej jakościowej (kategorii zawodów),
# co utrudnia ich rozróżnienie i mylnie sugeruje hierarchię danych.
# Dodatkowo, etykiety tekstowe stają się nieczytelne w mniejszych blokach,
# oraz nie odpowiednie odstępy w tytule sprawiają że tekst jest nieczytelny.

font_add_google("Teko", "dubois_font")
showtext_auto()

# Dopasowanie wielkosci tekstu
showtext_opts(dpi = 300)


# Dane
week10 <- readr::read_csv("https://raw.githubusercontent.com/ajstarks/dubois-data-portraits/master/challenge/2024/challenge10/data.csv")

# Definicja palety kolorów w stylu Du Bois

dubois_palette <- c(
  "#DC143C", # Crimson Red
  "black",   # Black
  "#FFD700", # Gold/Yellow
  "#4682B4", # Steel Blue
  "#D2691E", # Chocolate/Tan
  "#2E8B57"  # Sea Green
)

# Wykres
p <- ggplot(week10, aes(area = Percentage, 
                        fill = Occupation,  # Zmienione: Kolor zależy od zawodu, nie procentu
                        label = paste(Occupation, paste0(Percentage, "%"), sep = "\n"))) +
  
  # Usunięto subgroup, dodano jednolite obramowanie
  geom_treemap(colour = "white", size = 2) + 
  
  geom_treemap_text(colour = "white", 
                    place = "center",
                    family = "dubois_font",
                    size = 18,              # Większa czcionka dla czytelności
                    grow = FALSE) +         # Wyłączono grow, aby zachować proporcje tekstu
  
  # Zmienione: Manualna skala kolorów zamiast gradientu
  scale_fill_manual(values = dubois_palette) +
  
  # Tytuły i opisy
  labs(title = "OCCUPATIONS OF GRADUATES.",
       subtitle = "At the time of 1900, since its establishment in 1867,\nAtlanta University had graduated 330 black people among whom were:",
       caption = "Source: Plate 37 | Du Bois 1900 Paris Exposition") +
  
  theme_void() + 
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#EFE4D0", colour = NA), # Tło w kolorze starego papieru
    plot.title = element_text(size = 24, hjust = 0.5, family = "dubois_font", face = "bold", margin = margin(t=20, b=10)),
    plot.subtitle = element_text(size = 16, hjust = 0.5, family = "dubois_font", margin = margin(b=20)),
    plot.caption = element_text(size = 10, family = "dubois_font", color = "grey30", margin = margin(t=10, b=10))
  )

# Wyświetlenie
print(p)


# Wyjasnienie:
# Poprawiona wizualizacja wykorzystuje dyskretną paletę barw,
# co pozwala na jednoznaczną identyfikację każdej kategorii bez powtarzania się kolorów.
# Zastosowanie czytelniejszej czcionki, oraz dostosowanie marginesów między
# tytułem a wykresem znacząco poprawiło estetykę i czytelność odbioru danych.

# Zapis
ggsave("Fixed_Plot.png", plot = p, width = 6, height = 8, dpi = 300)