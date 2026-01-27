library(tidyverse)
library(ggplot2)
library(ggtext)
library(patchwork)


tuesdata <- tidytuesdayR::tt_load('2024-03-12')

fiscal_sponsor_directory <- tuesdata$fiscal_sponsor_directory


#### Linki
# Link do posta, na którym jest udostępniony wykres: "https://x.com/simisani10/status/1771460567858913638";
# Link do zestwau danych z Repozytorium TidyTuesday: "https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-03-12/fiscal_sponsor_directory.csv",

# Ten wykres ma kilka problemów:
# 1) Nieczytelne są podpisy na wykresie - nie są one w dobrym kolorze, 
# ponieważ zlewają się z obramowaniem wykresu. Do tego niektóre podpisy nachodzą na siebie.
# 2) Kolejnym problemem jest ustawienie tych danych w wykresie "donutowym"/kołowym. Suma donacji na podanych 
# wykresach nie sumuje się do 100%. Z tego powodu wykorzystanie wykresu donatowego jest
# nieuzasadnione. Mylące jest też rozbicie go na 2 wykresy, co sugeruje, że są to kompletnie inne dane.
# 3)Do tego dane minimum times sponsors have donated, to wybrane konkretne wiersze, a nie dokładnie 
# nazwy podmiotów z najmniejszą liczbą donacji. Nawet w największej liczbie donacji znajduje się wiersz 
# z poza top 10.

fiscal_max <- slice_max(fiscal_sponsor_directory, order_by = n_sponsored, n =10)

fiscal_min <- fiscal_sponsor_directory %>% 
  slice_min( order_by = n_sponsored, n =10)


p1 <- fiscal_max %>%
  mutate(
    name1 = forcats::fct_reorder(name, n_sponsored)
  ) %>%   ggplot(aes(x= n_sponsored, y = name1)) +
  geom_col(fill = "#00AB00") +
  theme_minimal()+
  lims(x= c(0, 850)) +
  labs(
    title = "Które podmioty zasponsorowały finansowo największą, a które najmniejszą liczbę projektów?",
    subtitle = "10 sponsorów z największą liczbą zasponsorowanych projektów"
  ) + geom_text(aes(x = 0, y = name, label = paste(name,"(", n_sponsored,")")),
                hjust = -0.03,
                color = "black",
                size = 4) +
  theme(  
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_line(size = 0.5, color = "grey50"),
    panel.grid.major.x = element_line(size = 0.5, color = "grey50"),
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    plot.title = element_text(size = 25, vjust = 0.5, face = "bold"),
    axis.text.x = element_blank(),
    axis.ticks.length.x = element_blank(),
    axis.title.x = element_blank(),
    plot.subtitle = element_text(size = 10, color = "grey50"),
  )


p2 <- fiscal_min %>%
  mutate(
    name1 = forcats::fct_reorder(name, n_sponsored)
  ) %>%   ggplot(aes(x= n_sponsored, y = name1)) +
  geom_col(fill = "#A00000") +
  theme_minimal()+
  lims(x = c(0, 850)) +
  labs(
    subtitle = "10 sponsorów z najmniejszą liczbą zasponsorowanych projektów",
    x = "Liczba zasponsorowanych projektów"
  ) + geom_text(aes(x = 0, y = name, label = paste(name,"(", n_sponsored,")")),
                hjust = -0.03,
                color = "black",
                size = 4) +
  theme(  
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_line(size = 0.5, color = "grey50"),
    panel.grid.major.x = element_line(size = 0.5, color = "grey50"),
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    plot.subtitle = element_text(size = 10, color = "grey50"),
    plot.title = element_blank(),
    axis.title.x = element_text(size = 20)
  )

n <- ggplot() + theme_void() +
  labs(y = "Sponsor") + theme(axis.title.y = element_text(size = 20, angle = 90)) +
  plot_layout(widths = c(5))

wynik <- n + (p1 + p2 + plot_layout(nrow =2)) + plot_layout(widths = c(1, 40))


# (1) Ten wykres jest lepszy w tym, że jest czytelniejszy. Łatwiej jest odczytać
# nazwy. Uważam też, że podpisy(tytuł, podtytuły) są minimalnie bardziej
# informatywne od tych na oryginalnym wykresie.
# (2) Ten wykres ma większy sens od donutowego. Stworzenie wykresu
# donutowego nie tylko może mylić odbiorcę, ale również z większą trudnością jest
# porównuje się wartości. Barplot jest lepszym sposobem do wizualizacji
# tych danych, gdyż nie sugeruje, że mają one się sumować do większej całości



#################

ggsave("plot.png", wynik) 
