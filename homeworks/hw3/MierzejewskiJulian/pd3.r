library(tidyverse)
library(maps)

#wczytywanie mapy
################################################################
world_coordinates <- map_data("world")

world_coordinates$region[world_coordinates$region == "UK"] <- "United Kingdom"
world_coordinates$region[world_coordinates$region == "Czech Republic"] <- "Czechia"
world_coordinates$region[world_coordinates$region == "Slovakia"] <- "Slovak Republic"
world_coordinates$region[world_coordinates$region == "USA"] <- "United States"
world_coordinates$region[world_coordinates$region == "Russia"] <- "Russian Federation"
world_coordinates$region[world_coordinates$region == "Egypt"] <- "Egypt, Arab Rep."
world_coordinates$region[world_coordinates$region == "Democratic Republic of the Congo"] <- "Congo, Dem. Rep."
world_coordinates$region[world_coordinates$region == "Republic of Congo"] <- "Congo, Rep."
world_coordinates$region[world_coordinates$region == "Venezuela"] <- "Venezuela, RB"
world_coordinates$region[world_coordinates$region == "Ivory Coast"] <- "Cote d'Ivoire"
################################################################
#czytywanie danych
################################################################
dane <- read.csv("dane.csv")
dane <- dane[,c(3,4,7)]
colnames(dane)[1] <- "region"
dane$X2024..YR2024. <- round(as.numeric(dane$X2024..YR2024.), 2)
colnames(dane)[3] <- "population_growth_2024"
################################################################

#łącznie mapy i danych
################################################################
mapa <- inner_join(world_coordinates, dane, by = "region")

#szukanie maksymlanych i minimalnych
################################################################
kraje <- mapa %>% 
  group_by(region) %>% 
  summarise(population_growth_2024 = first(population_growth_2024), .groups = "drop")


max_row <- kraje %>% slice_max(population_growth_2024, n = 1, with_ties = FALSE)
min_row <- kraje %>% slice_min(population_growth_2024, n = 1, with_ties = FALSE)

max_country <- max_row$region
max_value   <- max_row$population_growth_2024

min_country <- min_row$region
min_value   <- min_row$population_growth_2024

breaks <- c(-1, -0.5, 0, 0.5, 1.5, 2, 3)

caption_text <- paste0(
  "Max: ", max_country, " (", round(max_value, 2), ")\n",
  "Min: ", min_country, " (", round(min_value, 2), ")"
)

p <- ggplot(data = mapa, mapping = aes(x = long, y = lat, group = group))+
coord_fixed(1.3) +
  geom_polygon(aes(fill = population_growth_2024)) +
  geom_polygon(fill = NA, color = "grey70", linewidth = 0.4)+
  ggtitle("Population Growth 2024")+
  scale_fill_steps2(
    breaks = breaks,
    n.breaks = length(breaks),
    low = "black",
    mid = "white",
    high = "darkgreen",
    name = "%",
    guide = guide_coloursteps(
      direction = "horizontal",
      barwidth = 30,
      barheight = 1,
      title.position = "top"
    )
  ) +
  labs(
    title = "Wzrost populacji 2024",
    caption = caption_text
  ) +
  theme(
    legend.title = element_text(hjust = 0.5),
    axis.title = element_blank(),       
    axis.text = element_blank(),       
    axis.ticks = element_blank(),     
    panel.grid = element_blank(),      
    panel.border = element_blank(),    
    axis.line = element_blank(),
    legend.position = "bottom",
    legend.text  = element_text(size = 12),
    plot.title = element_text(hjust = 0.5,size = 22),
    
    plot.caption = element_text(
      hjust = 0.5,        
      size = 14,          
      lineheight = 0.7    
    )
  )
p
ggsave("mapa.pdf", plot = p, width = 12, height = 10, dpi = 300, device = cairo_pdf, bg = "transparent")  

