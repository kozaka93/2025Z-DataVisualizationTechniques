# Wizualizacja na której bazuje: https://aditya-dahiya.github.io/projects_presentations/data_vizs/tidy_usa_gas_prices.html
# Dane: https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-07-01

# Co należało poprawić?
# W zamyśle pierwotny wykres miał pokazywać, które paliwo w danym tygodniu kosztowało więcej, 
# ale sposób przedstawienia danych był mało czytelny: linie były momentami tak cienkie, że trudno było odróżnić kolory i zauważyć różnice.
# Poza tym tytuł oraz legenda zostały umieszczone bezpośrednio na tle siatki wykresu, 
# co utrudniało odczytywanie wartości na osi Y i sprawiało, że cała wizualizacja wydawała się mniej przejrzysta

# Na poprawionym wykresie wciąż można łatwo dostrzec, kiedy diesel był droższy od benzyny i odwrotnie, 
# ale jednocześnie prezentacja cen jest pełniejsza — widoczne są także wartości tego paliwa, 
# które w danym okresie było tańsze, co w oryginale często ginęło.
# Dodatkowo dodałam średnie roczne dla obu rodzajów paliw, co pozwala wyraźniej uchwycić ogólny trend cenowy w dłuższym czasie.
# Tytuł i legenda teraz są w miejscach, które nie zaburzają odbioru danych.

library(tidyverse)
library(lubridate)
library(scales)

url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-07-01/weekly_gas_prices.csv"
df <- read_csv(url)

df2 <- df %>%
  mutate(date = ymd(date)) %>%
  filter(
    (fuel == "gasoline" & grade == "all" & formulation == "all") |
      (fuel == "diesel")
  )

df_yearly <- df2 %>%
  mutate(year = year(date)) %>%
  group_by(year, fuel) %>%
  summarise(avg_price = mean(price, na.rm = TRUE), .groups = "drop")

fuel_colors <- c(
  "gasoline" = "#1f78b4", 
  "diesel"   = "#e31a1c"  
)

p <- ggplot() +
  geom_line(
    data = df2,
    aes(x = date, y = price, group = fuel, color = fuel, alpha = fuel),
    linewidth = 0.5, alpha = 0.3
  ) +
  geom_line(
    data = df_yearly,
    aes(x = as.Date(paste0(year, "-06-30")), y = avg_price, color = fuel),
    linewidth = 1
  ) +
  geom_point(
    data = df_yearly,
    aes(x = as.Date(paste0(year, "-06-30")), y = avg_price, color = fuel),
    size = 2
  ) +
  scale_color_manual(values = fuel_colors, name = "Fuel Type") +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Weekly U.S. Fuel Prices with Yearly Averages, 1995–2025",
    subtitle = "Weekly prices (semi-transparent) and yearly averages",
    x = "Date",
    y = "Price (USD per gallon)",
    color = "Fuel Type",
    caption = "Data: TidyTuesday 01.07.2025, weekly gas prices"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave("wykres_ceny_paliw.png", plot = p, width = 12, height = 6, dpi = 300)


