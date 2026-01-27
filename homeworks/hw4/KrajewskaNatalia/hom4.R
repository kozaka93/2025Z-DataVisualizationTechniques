#install.packages("readr")

# Link do oryginalnej wizualizacji: https://x.com/Dr_manishdatt/status/1995848623738020208

# Link do danych: https://github.com/rfordatascience/tidytuesday/tree/1aef86fe34cc24396a350985dfb3288e31117851/data/2025/2025-12-02

# Błędy w wizualizacji:
#1) Niepotrzebne wprowadzenie lat na osi x, zmiana temperatur na przestrzeni lat nie 
# wnosi nic do odpowiedzi na postawione w wizualizacji pytanie:
# "czy długość palenia się Boeoegga przewiduje temperaturę w ciągu lata w tym roku"
#2) Czas palenia bałwana zaznaczony tylko poprzez wielkość punktu, 
# trudno porównać ze sobą wielkości.
#3) Na osi Y pokazane zostały tylko maksymalne temperatury, które nie są dobrym wkaźnikiem
# czy ogólnie temperatury w ciągu lata w danym roku były wysokie,
# lepsze byłoby pokazanie średnich temperatur.

#Dlaczego wykres jest lepszy:
#1) Można łatwo odczytać odpowiedź na pytanie postawione wcześniej: długość palenia 
#  bałwana nie przewiduje temperatury w ciągu lata.
#2) Wykres pokazuje zależność średniej letniej temperatury (maksymalna temperatura zaznaczona tylko jako kolor punktu) od długości palenia się bałwana,
#  zaznaczony jest współczynnik korelacji Pearsona i linia trendu.
#3) Zaznaczona linia powyżej której są rekordowo wysokie średnie temperatury (>19°C) - występują niezależnie czy 
# bałwan palił się 4 minuty, czy 60.

library(ggplot2)
library(dplyr)
#install.packages("ggpubr")
library(ggpubr)

data <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-12-02/sechselaeuten.csv')

ggplot(data, aes(x = duration, y = tre200m0, color = tre200mx)) +
  geom_point(size = 3, alpha = 0.85) +
  geom_smooth(method = "lm", color = "black", fill = "grey60", alpha = 0.2) +
  geom_hline(yintercept = 19, linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text",
           x = max(data$duration, na.rm = TRUE) * 0.9,  
           y = 19.1,                                   
           label = "Rekordowo ciepłe lato (>19°C)",
           color = "red", size = 4, hjust = 1)+
  stat_cor(aes(label = ..r.label..),
           method = "pearson",
           label.x.npc = 0.75,
           label.y.npc = 0.95,
           size = 5, color = "black") +
  scale_color_gradient(
    name = "Maks. temperatura lata (°C)",
    low = "#56B1F7", high = "#CA0020"
  ) +
  labs(
    x = "Czas palenia się bałwana (minuty)",
    y = "Średnia letnia temperatura (°C)",
    title = "Zależność średniej temperatury w ciągu lata od czasu palenia się Boeoega",
    subtitle = "Według wierzeń folkowych im krócej pali się bałwan, tym cieplejsze będzie lato. \nNa wykresie widać, że to powiedzenie się nie sprawdza.") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

