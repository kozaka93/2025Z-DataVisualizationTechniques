library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(svglite)
library(systemfonts)

malzenstwa <- read_excel("C:\\PW\\TWD projekt\\malzenstwa-miesiaceR.xlsx", skip = 30)

colnames(malzenstwa) <- c("Rok", "Miejsce", "Przeciętna miesięczna", "Styczeń", "Luty", "Marzec", "Kwiecień", 
                          "Maj", "Czerwiec", "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień")

malzenstwa <- malzenstwa %>%
  filter(if_any(everything(), ~ !is.na(.)))

malzenstwa <- malzenstwa %>%
  mutate(Miejsce = recode(Miejsce,
                          "o" = "ogółem",
                          "m" = "miasto",
                          "w" = "wieś"))

malzenstwa_long <- malzenstwa %>%
  pivot_longer(cols = Styczeń:Grudzień,
               names_to = "Miesiąc",
               values_to = "Liczba_małżeństw")

malzenstwa_long <- malzenstwa_long %>%
  mutate(R_w_nazwie = ifelse(Miesiąc %in% c("Marzec", "Kwiecień", "Sierpień", "Wrzesień", "Październik", "Grudzień"),
                             "z R", "bez R"))

procenty <- malzenstwa_long %>%
  group_by(Rok, Miejsce) %>%
  summarise(malzenstwa_R = sum(Liczba_małżeństw[R_w_nazwie == "z R"], na.rm = TRUE),
    malzenstwa_total = sum(Liczba_małżeństw, na.rm = TRUE),
    procent_R = (malzenstwa_R / malzenstwa_total) * 100) 

srednie <- malzenstwa_long %>%
  group_by(Rok, Miejsce, R_w_nazwie) %>%
  summarise(Srednia_małżeństw = mean(Liczba_małżeństw, na.rm = TRUE)) %>% 
  ungroup()

srednia_globalna <- mean(procenty$procent_R, na.rm = TRUE)

procenty1 <- procenty %>% 
  filter(Rok != 2023)

p <- ggplot(procenty1, aes(x = Rok, y = procent_R, color = Miejsce)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.8) +
  scale_color_manual(
    values = c("#B33F62", "#F9564F", "#FBAF00"),
    name = "Miejsce zawarcia małżeństwa") +
  labs(title = "Udział małżeństw zawieranych w miesiącach z literą 'R'",
    subtitle = "Procent wszystkich małżeństw w danym roku (według miejsca zawarcia)",
    x = "Rok",
    y = "Procent małżeństw w miesiącach z 'R' [%]") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 21, hjust = 0.5, color = "whitesmoke"),
    plot.subtitle = element_text(size = 18, hjust = 0.5, color = "whitesmoke"),
    axis.title = element_text(size = 18, face = "bold", color = "whitesmoke"),
    axis.text = element_text(size = 16, color = "whitesmoke"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", color = "whitesmoke", size = 18),
    legend.text = element_text(size = 18, color = "whitesmoke"),
    panel.border = element_blank(),
    panel.background  = element_rect(fill = NA, color = NA),
    plot.background   = element_rect(fill = NA, color = NA),
    legend.background = element_rect(fill = NA, color = NA),
    legend.box.background = element_rect(fill = NA, color = NA))

ggsave(filename = "malzenstwa_r.svg",
  plot = p,
  device = "svg",
  bg = "transparent",
  width = 9,
  height = 6,
  units = "in")

p
