library(eurostat)
library(dplyr)
library(tidyr)
library(giscoR)
library(sf)
library(ggplot2)

energy_data <- get_eurostat("nrg_ind_ren", time_format="num")

energy_data1 <- energy_data %>% 
  filter(nrg_bal == "REN") %>% 
  label_eurostat() %>% 
  select(geo, TIME_PERIOD, values) %>% 
  pivot_wider(
    names_from = TIME_PERIOD,
    values_from = values
  ) %>% 
  select(geo, `2022`) # ostatni rok z danymi dla wszystkich państw

most_renewable_energy <- energy_data1 %>% 
  arrange(desc(`2022`)) %>% 
  pull(geo)

# Wyroznione regiony
most <- most_renewable_energy[1]
least <- most_renewable_energy[length(most_renewable_energy)]


map <- gisco_get_countries(
  year = "2020",
  resolution = "20"
)

# 5. Łączenie
map_data <- map %>% 
  left_join(energy_data1, by = c("NAME_ENGL" = "geo"))

# 6. Rysowanie
ggplot(data = map_data) +
  geom_sf(aes(fill = `2022`), color = "black", size = 0.1) +
  scale_fill_gradientn(
    colours = c("red", "orange", "green"), 
    na.value = "gray",                 
    name = "%"
  ) +
  labs(
    title = "Udział energii odnawialnej w pańtwach Europy (2022)",
    subtitle = "Źródło: Eurostat", 
    caption = paste("najwięcej:", most, "najmniej:", least)
  ) +
  
  # zblizenie na Europe
  coord_sf(
    xlim = c(-25, 45),
    ylim = c(34, 72)
  ) +

  theme_void() +
  theme(
    legend.position = c(0.15, 0.6),
    plot.background = element_rect(fill = "white", color = NA),
    plot.title = element_text(face = "bold", size = 16)
  )
