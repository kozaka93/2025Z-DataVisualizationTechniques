# link do posta https://x.com/simisani10/status/1774780110538690799
# Co jest nie tak z wykresem?
# 1. Jest to wykres kołowy
# 2. Wykres nie posiada legendy i w żaden sposób nie tłumaczy czego dotyczą dane
# link do danych: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-26/public-picks.csv
library(tidyverse)

data <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-26/public-picks.csv"
)

data_long <- pivot_longer(
  data,
  -c(YEAR, TEAMNO, TEAM),
  names_to = "Round",
  values_to = "Percentage"
)

data_long$Percentage <- as.numeric(sub("%", "", data_long$Percentage))

p <- ggplot(data_long, aes(x = Round, y = Percentage, fill = TEAM)) +
  geom_col(position = "dodge") +
  facet_wrap(~YEAR) +
  labs(
    title = "Progression of NCAA basketball teams across different rounds",
    subtitle = "Source: 2024 Tidy Tuesday week 13",
    x = "Round",
    y = "Percentage"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#F5F5DC", color = NA),   # beżowe tło
    panel.background = element_rect(fill = "#F5F5DC", color = NA),
    legend.background = element_rect(fill = "#F5F5DC"),
    text = element_text(family = "Arial", color = "black"),
    plot.title = element_text(size = 18, face = "bold"),
    legend.position = "bottom"
  )

ggsave("Poprawiony_Wykres.png", p, width = 10, height = 10)

# Czemu mój wykres jest lepszy od poprzedniego?
# Przede wszystkim nie jest to wykres kołowy
# Kolejna sprawa to jasny opis słupków na wykresie i czytelna reprezentacja na przyjemnym kolorystycznie tle
# Z poprzednieog wykresu nie dało się odczytać czego dotyczą "kawałki" koła, tutaj natomiast wszystko jest zapisane w profesjonalnie skonstruowanej legendzie
