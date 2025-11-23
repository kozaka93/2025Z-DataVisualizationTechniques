library(ggplot2)
library(maps)
library(mapdata)
library(dplyr)

world <- map_data("world")

#https://ec.europa.eu/eurostat/databrowser/view/road_eqs_carhab__custom_19013919/default/table
cars <- read.csv("samochody_eu.csv")

cars <- cars %>% 
  select("Geopolitical.entity..reporting.", "OBS_VALUE", "TIME_PERIOD") %>% 
  rename(country = Geopolitical.entity..reporting.)

europe <- world %>% 
  filter(region %in% c("Austria", "Belgium", "Bulgaria", "Croatia", "Czech Republic",
                       "Denmark", "Finland", "France", "Germany", "Greece", 
                       "Hungary", "Ireland", "Italy", "Netherlands", "Norway", 
                       "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", 
                       "Spain", "Sweden", "Switzerland", "UK", "Serbia", "Albania", "Bosnia and Herzegovina", 
                       "Montenegro", "Macedonia", "Kosovo", "Iceland", "Malta", "Cyprus", "Estonia",
                       "Latvia", "Lithuania", "Russia", "Belarus", "Ukraine", "Turkey", "Andorra", "Monaco",
                       "Liechtenstein", "San Marino", "Vatican City", "Moldova", "North Macedonia",
                       "Luxembourg", "Georgia", "Armenia", "Giblartar"),
         long <= 45,
         lat <= 73)

#Dane z Państwowych urzędów statystycznych
cars <- rbind(cars,
  data.frame(country = "Belarus", OBS_VALUE = 332, TIME_PERIOD = 2023),
  data.frame(country = "Russia", OBS_VALUE = 315, TIME_PERIOD = 2023))

cars$country[cars$country == "United Kingdom"] <- "UK"
cars$country[cars$country == "Czechia"] <- "Czech Republic"
cars$country[cars$country == "Türkiye"] <- "Turkey"
cars$country[cars$country == "Kosovo*"] <- "Kosovo"

max <- cars %>%
  filter(OBS_VALUE == max(OBS_VALUE, na.rm = TRUE)) %>% 
  select(country)

max <- max$country[1]

min <- cars %>%
  filter(OBS_VALUE == min(OBS_VALUE, na.rm = TRUE)) %>% 
  select(country)

min <- min$country[1]

min_max <- europe %>%
  filter(region %in% c(min, max))

label_loc <- min_max %>%
  group_by(region) %>%
  summarise(
    long = mean(long), 
    lat = mean(lat)) %>%
  ungroup()

label_loc <- label_loc %>% 
  mutate(long_offset = ifelse(region == "Liechtenstein",long - 10, long),
         lat_offset = ifelse(region == "Liechtenstein",lat + 20, lat))

label_loc <- label_loc %>%
  mutate(OBS_VALUE = case_when(
      region == min ~ cars$OBS_VALUE[cars$country == min][1],
      region == max ~ cars$OBS_VALUE[cars$country == max][1]))

europe_data <- europe %>%
  left_join(cars, by = c("region" = "country"))

ggplot(europe_data, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = OBS_VALUE), color = "black") +
  geom_segment(data = label_loc,
    aes(x = long_offset, y = lat_offset, xend = long, yend = lat, group = NULL),
    linewidth = 1,
    arrow = arrow(length = unit(0.02, "npc"))) +
  geom_label(data = label_loc,
    aes(x = long_offset, y = lat_offset, label = paste0(region, "\n(", OBS_VALUE, ")"), group = NULL),
    size = 3,        
    fill = "white",
    alpha = 0.75,
    fontface = "bold") +
  coord_map("mercator") +
  theme_void()+
  scale_fill_viridis_c(option = "B", na.value = "grey") +
  labs(title = "Number of cars per 1000 inhabitants in Europe (2023)",
       subtitle = "Grey - NO DATA",
       caption = "Source: Eurostat and National statistical offices",
       fill = "Cars per 1000") +
  theme(plot.caption = element_text(face = "italic"),
        plot.subtitle = element_text(size = 6))
  