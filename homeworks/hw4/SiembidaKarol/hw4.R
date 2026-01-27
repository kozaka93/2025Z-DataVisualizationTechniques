# Karol Siembida - TWD Praca Domowa 4
# 
# Link do posta z oryginalną wizualizacją: https://x.com/Dr_manishdatt/status/1973043061677863253/photo/1
# Link do datasetu: https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-09-30/cranes.csv
#
# Błędy w oryginalnej wizualizacji:
# 1) Brak podpisów osi X i Y
# 2) Mieszanka języków (tytuł po angielsku, nazwy miesięcy po szwedzku)
# 3) Zastosowanie tych samych kolorów dla różnych miesięcy (co prawda są to dwa oddzielne wykresy ale uważam że tak nie powinno być)
# 4) Brak odpowiedniej informacji o tym dlaczego są dwa wykresy (podział na połowy roku)
# 5) Miesiące w legendzie są nie po kolei
#
# Na temat poprawionego wykresu:
# Poprawiony wykres ma podpisane osie, w szczególności wiadomo czym są liczby na osi Y (na osi X można było się i tak domyślić). 
# Każdy miesiąc jest przedstawiony innym kolorem ponadto z podziałem na kolory odcienia zielonego (pierwsza połowa roku, 
# kojarzą się z wiosną), i odcienia pomarańczowego (druga połowa roku, kojarzą się z latem/jesienią). Taki dobór kolorów pozwala 
# na przedstawienie "dwóch" oryginalnych wykresów na jednym. Wszystko na wykresie jest w jednym języku, miesiące w legendzie 
# uporządkowane są w takiej kolejności w jakiej występują w roku.

library(dplyr)
library(ggplot2)

cranes = read.csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-09-30/cranes.csv')

cranes <- cranes %>% 
  mutate(month = format(as.Date(date), "%B")) %>% 
  mutate(year = as.integer(format(as.Date(date), "%Y")))

unique(cranes$month)

cranes <- cranes %>% 
  mutate(
    month = case_when(
      month == "marzec" ~ "March",
      month == "kwiecień" ~ "April",
      month == "sierpień" ~ "August",
      month == "wrzesień" ~ "September",
      month == "październik" ~ "October",
      TRUE ~ month
    )
  )

# Przypisując angielskie nawzy miesięcy wykorzystujemy fakt, że z unique wyszły tylko takie miesiące

cranes_eachmonth_eachyear <- cranes %>% 
  group_by(year, month) %>% 
  summarise(
    n = sum(observations, na.rm= TRUE),
  )

cranes_eachmonth_eachyear <- cranes_eachmonth_eachyear %>% 
  mutate(month = factor(month, levels = c("March", "April", "August", "September", "October")))

corrected_plot <- cranes_eachmonth_eachyear %>% 
  ggplot(aes(x = year, y = n/1000, color = month))+
  geom_point(size = 3)+
  geom_line(size=0.5, linetype = "dashed")+
  scale_color_manual(
    values = c(
      "March"     = "#05e66a",
      "April"     = "#218c00",
      "August"    = "#fcc203",
      "September" = "#eb8500",
      "October"   = "#d93a00"
    )
  )+
  labs(
    title = "Crane Observations at Lake Hornborgasjön in Sweden",
    subtitle = "Shades of green represent the first half of the year, shades of orange represent the second half",
    x = "Year",
    y = "Total number of observed cranes (thousands)",
    color = "Month"
  )+
  scale_x_continuous(breaks = seq(1994, 2024, by = 5))+
  scale_y_continuous(breaks = seq(0, 250, by = 50))+ 
  theme_minimal()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey75", linewidth = 0.4))

ggsave("hw4.png", plot = corrected_plot, width = 16, height = 9, dpi = 250)
