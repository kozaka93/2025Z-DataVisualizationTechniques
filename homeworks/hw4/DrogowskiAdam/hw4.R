library(pacman)
library(tidyverse)
library(lubridate)

# Zaczytanie ze strony człowieka od wykresu

pacman::p_load(
  tidyverse,            # All things tidy
  
  scales,               # Nice Scales for ggplot2
  fontawesome,          # Icons display in ggplot2
  ggtext,               # Markdown text support for ggplot2
  showtext,             # Display fonts in ggplot2
  colorspace,           # Lighten and Darken colours
  
  patchwork,            # Composing Plots
  sf                    # Making maps
)

df <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-07-01/weekly_gas_prices.csv')

# Wykres jest absolutnie nieczytelny, nie potrafiłem zinterpretować przez pierwsze 3 minuty co badamy
# Data na osi x-ów jest co 5 lat, co przy tak szybko zmieniających sie danych sprawia, że jest to mylące czy
# benzyna nagle była droższa w 2018 czy 2019. 
# To, że linia jest pogrubiana, sprawia że nie wiem, czy patrząc na cene mam patrzeć na dół lini? czy na góre?
# Po dogłębnej analize doszedłem do wniosku,

# Wykres miał przedstawić, co było droższe, na przestrzeni lat, więc ja promonuje prostszą forme, z linią trendu,
# która znajduje się w obszarze typu paliwa, który w danym czasie był droższy. Jest to różnica między nimi.

# Dodałem też linie x = rok, aby było jasne w których przedziałach czasowych dominował jaki typ.
# Date dziele co dwa lata nie pięc, gdyż z liniami co rok, łatwo dojechać wzrokiem do odpowiedniego okresu
# Poza tym, mój wykres jest lepszy ponieważ użyłem ładniejszych kolorów

# link do danych: https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-07-01/weekly_gas_prices.csv

# oryginalny post: https://x.com/AdityaDahiyaIAS/status/1941063335744766214/photo/1

gas <- df %>% 
  filter(fuel == "gasoline") %>%
  group_by(date) %>%
  summarise(gasoline = mean(price))

dsl <- df %>% 
  filter(fuel == "diesel") %>%
  group_by(date) %>%
  summarise(diesel = mean(price))

merged <- full_join(gas, dsl, by = "date") %>%
  drop_na() %>% 
  mutate(delta = diesel - gasoline)


# Tutaj przydaje się normalizacja, gdyż niemógłbym wstawić ładnie napisów (bądź też nie potrafiłem, ale pokonało mnie to)
max_abs <- max(abs(merged$delta))

merged <- merged %>%
mutate(delta_norm = delta / max_abs * 0.67)  


upper_col <- "#C8D8D0"  
lower_col <- "#E7C4D4"  

ggplot(merged, aes(x = date)) +
  
  annotate("rect",
           xmin = min(merged$date),
           xmax = max(merged$date),
           ymin = -1,
           ymax = 0,
           fill = lower_col) +
  
  annotate("rect",
           xmin = min(merged$date),
           xmax = max(merged$date),
           ymin = 0,
           ymax = 1,
           fill = upper_col) +
  
  annotate("text",
           x = mean(range(merged$date)),
           y = 0.5,
           label = "Diesel",
           color = "grey20",
           alpha = 0.45,
           size = 12,
           fontface = "bold") +
  
  annotate("text",
           x = mean(range(merged$date)),
           y = -0.5,
           label = "Benzyna",
           color = "grey20",
           alpha = 0.45,
           size = 12,
           fontface = "bold") +
  
  geom_hline(yintercept = 0, color = "red", linewidth = 0.6) +
  
  geom_line(aes(y = delta_norm), color = "#4B5634", linewidth = 1.0) +
  
  geom_vline(xintercept = seq(from = floor_date(min(merged$date), "year"),
                              to   = floor_date(max(merged$date), "year"),
                              by   = "1 year"),
             color = "grey30",
             linetype = "dashed",
             linewidth = 0.3,
             alpha = 0.5) +
  
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  
  theme_minimal(base_size = 14) +
  
  labs(
    title = "Który typ paliwa był droższy na przestrzeni lat?",
    subtitle = "Linia znajduje się na droższym typie paliwa",
    x = NULL
  
  ) +
  
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
  )

ggsave(
  filename = "wykreshw4.png",
  width = 14,
  height = 8,
  dpi = 320,
  bg = "white"
)

