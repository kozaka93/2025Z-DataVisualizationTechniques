# Źródło wizualizacji: https://x.com/Dr_manishdatt/status/1995848623738020208
#
# Kod oryginalnej wizualizacji: https://dviz.manishdatt.com/posts/Boogg_burn/Boogg_burn.html
#
# Źródło danych: https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-12-02
#
# Nieprawidłowości:
#
# 1. Wizualizacja nie przedstawia zamierzonego związku między zmiennymi. 
# Zamiarem autora było pokazanie relacji między długością spalania się figury Böögg a temperaturą latem następnego roku.
# Zamiast tego dobór osi sugeruje relację między rokiem a maksymalną temperaturą latem,
# długość spalania pokazana jest (bez skali) jako wielkość kropek.
# Rok jest praktycznie nieistotny, a został wyróżniony jako najważniejsza ze zmiennych.
# Odczytanie przez odbiorcę docelowego wykresu korelacji między wielkością kropki a osią Y jest trudne i mylące.
#
# 2. Dobór kolorów powoduje, że wizualizacja jest nieczytelna.
# Czerwone i fioletowe kropki zostały umieszczone na czerwonym tle, co przyczynia się do nieczytelności wykresu.
# Niewyjaśniony jest powód wyróżnienia średnich temperatur powyżej 19 st. C czerwonym kolorem –
# próg 19 stopni został co prawda wyróżniony przez dodatkową kolumnę w danych,
# jednak wykres nie przedstawia wyjaśnienia dla tego progu.
#
# 3. Temperatura maksymalna nie jest dobrym odzwierciedleniem "temperatury lata" w ujęciu ogólnym.
# Ogólny trend w danym roku lepiej przedstawia temperatura średnia – 
# maksymalna może zostać zaburzona przez jednorazową falę gorąca.

library(dplyr)
library(ggplot2)
library(scales)
library(sysfonts)
library(showtext)
library(ggrepel)

font_add_google("Rajdhani", family = "f1")
font_add_google("Exo 2", family = "f2")
font_add_google("Baloo 2", family = "f3")
showtext_auto()

data <- read.csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/refs/heads/main/data/2025/2025-12-02/sechselaeuten.csv")

data %>%
  select(year, duration, tre200m0, tre200mx) %>%
  filter(!is.na(duration)) %>%
  mutate(highlight=ifelse(
    (((tre200m0 < quantile(data$tre200m0, 0.06)) | 
        (tre200m0 > quantile(data$tre200m0, 0.94)) | 
           (duration > 50))), 
    year, "")) %>%
  ggplot(mapping=aes(x=duration, y=tre200m0, colour=tre200mx)) +
  geom_point(size=5, shape=18, alpha=0.9) +
  theme_minimal() +
  labs(
    x="Duration of the burning [minutes]",
    y="Average summer temperature [°C]",
    colour="Maximum\nsummer\ntemperature",
    title="Folk science vs hard science — does the Böögg predict weather?",
    caption="#TidyTuesday 2025-12-02 | Jerzy Adrjan | Techniki wizualizacji danych"
    ) +
  theme(
    plot.background=element_rect(fill='#fff5e6'),
    axis.text=element_text(size=31, family="f2"),
    axis.title=element_text(size=30, family="f1"),
    legend.title=element_text(size=26, family="f1", lineheight=0.45),
    legend.text=element_text(size=26, family="f2"),
    axis.title.x=element_text(margin=margin(t=8)),
    axis.title.y=element_text(margin=margin(r=8)),
    plot.title=element_text(size=40, hjust=0, margin=margin(t=5), family="f3"),
    plot.caption=element_text(size=18, family="f3", hjust=1.35)
    ) +
  scale_colour_binned(palette=c("#30e", "#70b", "#b07", "#e03"), 
                      limits=c(28.99, 33.01),
                      breaks=c(29, 31, 33),
                      oob = scales::oob_squish,
                      labels = function(x) paste0(x, "°C")) +
  scale_x_continuous(breaks=c(1, 5, 15, 30, 60), limits=c(3, 60), transform="sqrt") +
  scale_y_continuous(breaks=seq(15, 21, 2), limits=c(14.5, 22)) +
  geom_smooth(method="lm", colour="#000", alpha=0.15, fullrange=TRUE) +
  geom_text_repel(aes(label=factor(highlight)), 
                  family = "f2", colour="#111", size=6.5)

# Dlaczego przygotowany wykres jest lepszy?
#
# Wykres przedstawia związek między poprawnie wybranymi zmiennymi: długością spalania a temperaturą.
# Dzięki wykorzystaniu kontrastujących ze sobą kolorów jest czytelniejszy.
# Najważniejsze dane: długość spalania i średnia temperatura zostały wyróżnione.
# Niewykorzystywane jest trudne do odczytu skalowanie wielkości punktów.

