library(ggplot2)
library(dplyr)
library(maps)
library(ggnewscale)

corruption <- read.csv("https://ourworldindata.org/grapher/political-corruption-index.csv?v=1&csvType=full&useColumnShortNames=true")
# źródło danych: https://ourworldindata.org/corruption
world_map <- map_data("world")

corruption_2024 <- corruption %>%
  filter(Year == 2024) %>%
  filter(Code != "", nchar(Code) == 3) %>%
  select(Entity, Code, corruption_vdem__estimate_best) %>%
  rename(Country = Entity, Index = corruption_vdem__estimate_best)

# Sprawdzam, które nazwy państw różnią się w ramkach
not_in_world <- corruption_2024 %>%
  anti_join(world_map, by = c("Country" = "region")) %>%
  select(Country)

# Ujednolicam nazwy
corruption_2024 <- corruption_2024 %>%
  mutate(Country = case_when(Country == "Congo" ~ "Republic of Congo",
                             Country == "Democratic Republic of Congo" ~ "Democratic Republic of the Congo",
                             Country == "Cote d'Ivoire" ~ "Ivory Coast",
                             Country == "East Timor" ~ "Timor-Leste",
                             Country == "Eswatini" ~ "Swaziland",
                             Country == "United States" ~ "USA",
                             Country == "United Kingdom" ~ "UK",
                             Country == "Czechia" ~ "Czech Republic",
                             Country == "Trinidad and Tobago" ~ "Trinidad",
                             TRUE ~ Country)) %>% 
  filter(Country != "Hong Kong")

corruption_joined <- world_map %>%
  left_join(corruption_2024, by = c("region" = "Country"))

label_coords <- corruption_joined %>%
  filter(Index %in% c(min(Index, na.rm = TRUE), max(Index, na.rm = TRUE))) %>%
  group_by(region) %>%
  summarise(long = mean(long, na.rm = TRUE), lat = mean(lat,  na.rm = TRUE),
    Index = first(Index), .groups = "drop") %>%
  mutate(label = paste0(region, "\nIndex: ", round(Index, 3)))

map <- ggplot(corruption_joined, aes(long, lat, group = group)) +
  geom_polygon(data  = subset(corruption_joined, is.na(Index)),
               aes(fill = "No data"),
               color = "gray",
               linewidth = 0.1) +
  scale_fill_manual(values = c("No data" = "lightgray"),
                    name   = "") +
  new_scale_fill() +
  geom_polygon(data  = subset(corruption_joined, !is.na(Index)),
               aes(fill = Index),
               color = "gray",
               linewidth = 0.1) +
  scale_fill_stepsn(colours = c("#fff7f3", "#fde0dd", "#fcc5c0", "#fcb4c4", "#f979b6", "#f768a1", "#dd3497",
                "#b21788", "#7a0177", "#49006a"),
                limits  = c(0, 1),
                breaks  = seq(0, 1, by = 0.1),
                name    = "Political\ncorruption\nindex") +
  geom_segment(data = label_coords,
               aes(x = long, y = lat, xend = long, yend = lat + 10),
               inherit.aes = FALSE) +
  geom_label(data = label_coords,
             aes(x = long, y = lat + 10, label = label),
             inherit.aes = FALSE,
             size = 3) +
  coord_fixed(1.3) +
  theme_void() +
  labs(title = "Political Corruption Index, 2024",
    subtitle = "The index ranges from 0 to 1 (highly corrupt).",
    caption  = "Source: https://ourworldindata.org/corruption")
map
ggsave("map.png", plot  = map, width = 10, height = 9)