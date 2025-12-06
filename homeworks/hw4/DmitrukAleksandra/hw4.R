# install.packages("remotes")
# install.packages("sysfonts")
# install.packages("sysfonts")
# remotes::install_github("davidsjoberg/ggsankey")


# Źródło posta: https://x.com/Manasseh_6/status/1867538559462519249/photo/1
#
# Źródło danych: https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-12-10
#
# Największym błędem rozważanej wizualizacji jest nachodzenie na siebie nazw profili zapachowych
# i nazw perfum, a także wielokrotne powtarzanie informacji,
# np. La Capitale pojawia się w pięciu różnych komórkach. Wykres staje się przez to nieczytelny.
# Wybrany sposób wizualizacji utrudnia  też porównywanie poszczególnych profili
# zapachowych. Brakuje także legendy kolorystycznej i informacji, jak zostało wybrane 20 najlepszych perfum.

library(dplyr)
library(ggplot2)
library(tidyr)
library(ggsankey)
library(sysfonts)
library(showtext)
library(paletteer)

font_add_google("Roboto Slab")
showtext_auto()

dane <- read.csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-12-10/parfumo_data_clean.csv'
)



dane <- dane %>%
  drop_na(Rating_Count, Rating_Value) %>%
  mutate(Rating_Weighted = Rating_Value * log(Rating_Count)) %>%
  select(Name,
         Main_Accords,
         Rating_Weighted,
         Rating_Count,
         Rating_Value) %>%
  arrange(-Rating_Weighted) %>%
  head(20) %>%
  separate_rows(Main_Accords, sep = ", ")


main_accords <- dane %>%
  separate_rows(Main_Accords, sep = ", ") %>%
  count(Main_Accords, sort = TRUE) %>%
  mutate(perc = n / 20 * 100)

dane <- dane %>%
  left_join(main_accords, by = "Main_Accords") %>%
  mutate(Main_Accords = paste(Main_Accords, " (", perc, "%)", sep = ""))

main_accords <- main_accords %>%
  mutate(Main_Accords = paste(Main_Accords, " (", perc, "%)", sep = ""))


dane <- dane %>%
  make_long(Name, Main_Accords)

sorted_accords <- main_accords %>%
  arrange(n, Main_Accords) %>%
  pull(Main_Accords)


dane <- dane %>%
  mutate(
    x_num = as.numeric(x),
    x_label = ifelse(x_num == min(x_num), x_num - 0.03 , x_num + 0.03),
    hjust_lab = ifelse(x_num == min(x_num), 1, 0)
  )

tmp <- dane %>%
  filter(x == "Name")

perfume_names <- unique(tmp$node)
palette_perfumes <- paletteer_d("pals::glasbey")[1:length(perfume_names)]
perfume_levels <- dane %>%
  filter(x == "Name") %>%
  pull(node) %>%
  unique()

all_levels <- c(perfume_levels, sorted_accords)
dane$node <- factor(dane$node, levels = all_levels)

ggplot(
  dane,
  aes(
    x = x,
    next_x = next_x,
    node = node,
    next_node = next_node,
    fill = factor(node),
    label = node
  )
) +
  
  geom_sankey(flow_alpha = 0.65, width = 0.02) +
  geom_sankey_text(aes(x = x_label, hjust = hjust_lab, family = "Roboto Slab"), size = 4) +
  theme_sankey(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(
      family = "Roboto Slab",
      face = "bold",
      hjust = 0.5
    ),
    plot.subtitle = element_text(family = "Roboto Slab", hjust = 0.5),
    plot.caption = element_text(family = "Roboto Slab", hjust = 0.5),
    axis.title.x = element_blank(),
    axis.text.x = element_text(size = 12, family = "Roboto Slab"),
    axis.title.y = element_blank()
  ) +
  scale_x_discrete(labels = c("Name" = "Name of perfume", "Main_Accords" = "Main Fragrance Accord")) +
  scale_fill_manual(values = c(setNames(palette_perfumes, perfume_names))) +
  labs(
    title = "Fragrance Profiles of the Top-Rated 20 Perfumes",
    subtitle = "We chose Top Rated perfumes by weighing average rating\nwith the logarithm of the number of reviews.The percentage shows in how many\
nperfumes a certain fragrance is present.",
    caption = "Source: Tidy Tuesday, 2024-12-10"
  )

# Drugi wykres jest lepszy, ponieważ wszystkie nazwy perfum i nut zapachowych są czytelne i nie powtarzają się.
# Przez to że każde perfumy mają własny unikalny, kontrastujący kolor można łatwo zobaczyć, które perfumy mają jakie nuty.
# Nuty są posortowane od najczęściej występującej do najrzadziej występującej, co sprawia, że ich porównywanie jest o wiele łatwiejsze.
# W czytelności pomaga wartość procentowa dodana do etykiety każdej nuty, a także neutralny szary kolor, który nie odwraca uwagi od koloru danych perfum.
