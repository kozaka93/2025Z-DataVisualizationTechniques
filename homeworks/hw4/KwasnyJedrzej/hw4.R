# Link do posta:
# https://x.com/Dr_manishdatt/status/1993270599851106465

# Link do danych:
# https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-11-25/spi_indicators.csv

# Co jest źle na wykresie:

# 1. Na wykresie zostały przedstawione dane dla 10 krajów, co w połączeniu z dużą ilością wykresów znacznie zmniejsza czytelność.
# 2. Niewłaściwie zaimplementowana legenda: Zamiast standardowej legendy z boku lub pod wykresem, 
# lista krajów została umieszczona bezpośrednio na panelu z danymi. Do tego napisy nakładają się na siebie
# 3. Brakujące dane w kilku podwykresach: W części wykresów brakuje danych dla okresu przed 2016 rokiem. 

# Co zostało poprawione:

# 1. Na nowym wykresie jest tylko 5 krajów co polepsza czytelność.
# 2. Legenda została przeniesiona na bok, dzięki czemu jest bardziej czytelna.
# 3. Zakres czasu na wykresie został zmieniony tak aby nie obejmował okresu w którym brakuje danych.




library(tidyverse)

df <- read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-11-25/spi_indicators.csv"
) 

df <- df %>%
  filter(year >= 2016)
naj <- df %>%
  group_by(country) %>%
  summarise(diff = max(overall_score, na.rm = TRUE) - min(overall_score, na.rm = TRUE)) %>%
  slice_max(diff, n = 5) %>%
  pull(country)

df_long <- df %>%
  filter(country %in% naj) %>%
  pivot_longer(
    starts_with(c("overall", "data_")),
    names_to = "Score_type",
    values_to = "Scores"
  )

score_labels <- c(
  data_infrastructure_score = "Data Infrastructure",
  data_products_score       = "Data Products",
  data_services_score       = "Data Services",
  data_sources_score        = "Data Sources",
  data_use_score            = "Data Use",
  overall_score             = "Overall Score"
)


df_long_clean <- df_long %>%
  drop_na(year, Scores)

p <- ggplot(df_long_clean, aes(year, Scores, color = country)) +
  geom_point(size = 2.5) +
  geom_line(linewidth = 1.6, alpha = 0.8) +
  facet_wrap(~Score_type, ncol = 3,  labeller = labeller(Score_type = score_labels)) +
  labs(x = "year", y = "Scores", color = "country") +
  theme_minimal(base_size = 12) + 
  labs(
    title = "Top 10 countries with the greatest improvement in the overall score\nof the World Bank Statistical Performance Indicators from 2004 – 2023"
  )
p
ggsave("wykres6.png", plot = p, width = 10, height = 6, dpi = 300)



