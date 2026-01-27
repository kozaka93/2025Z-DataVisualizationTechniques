library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)

A <- read_csv("C:/IAD/Semestr_3/Techniki_Wizualizacji_Danych/Homework/hw5/tree_heatmap_wide.csv", col_names = FALSE)

df <- A %>% 
  mutate(y = row_number() - 1) %>% 
  pivot_longer(-y, names_to = "x", values_to = "value") %>% 
  mutate(x = as.integer(gsub("X", "", x)) - 1)

colors <- c(
  "0" = "lightblue",
  "1" = "green",
  "2" = "red",
  "3" = "pink",
  "4" = "yellow",
  "5" = "brown",
  "6" = "grey"
)

ggplot(df, aes(x = x, y = -y, fill = factor(value))) +
  geom_tile() +
  coord_fixed() +
  scale_fill_manual(values = colors) +
  theme_void() +
  theme(legend.title = element_blank())


  