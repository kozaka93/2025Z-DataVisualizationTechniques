# link do, w mojej ocenie, nieprawidłowej wizualizacji: https://x.com/lpicci96/status/1651544026674331648
# link do danych: https://github.com/rfordatascience/tidytuesday/tree/main/data/2023/2023-04-25

# Błędy w wybranej przeze mnie wizualizacji:

#. 1. Sposób pokazania liczby osób startujących w maratonie jest bardzo nieczytelny,
# występuje duża róznica skali, wykres nie uwidacznia ani trochę spadającego odsetka
# przyjmowanych do startu w maratonie.

# 2. Nieprecyzyjne opisy osi i sposób przedstawienia legendy w podtytule uniemożliwiają
# szybką i intuicyjną interpretacje wizualizacji.

# Moim zdaniem przygotowany przeze mnie wykres jest lepszy od oryginału, gdyż czytelniej pokazuje,
# że przy wzrastającej liczbie aplikacji do maratonu do startu dopuszczany jest coraz mniejszy odsetek
# aplikujących. Moja wizaulizacja jest również dużo lepiej opisana, zarówno osie, podtytuł i tytuł,
# a użyte kolory i styl przedstawienia legendy pozwala na dużo bardziej intuicyjne i szybsze zorientowanie się,
# co przedstawia.




library(ggplot2)
library(dplyr)
library(scales)


london_marathon <- read.csv("C:\\Users\\krzys\\OneDrive\\Pulpit\\RybickiKrzysztof\\london_marathon.csv")


data <- london_marathon %>% 
  filter(Year >= 2010, Year <= 2020) %>% 
  mutate(Percent = Starters / Applicants * 100)


max_y <- max(data$Applicants)
mnoznik <- max_y / 100


kolor_slupka <- "steelblue"
kolor_linii <- "firebrick"
kolor_tla_kremowy <- "oldlace" 
kolor_siatki <- "lightgrey"     

ggplot(data, aes(x = Year)) +
  
  
  geom_col(aes(y = Applicants, fill = "Liczba aplikacji"), 
           width = 0.8, color = "black") +

  geom_line(aes(y = Percent * mnoznik, color = "Odsetek przyjętych (%)"),size=1.4 ) +
  
  geom_point(aes(y = Percent * mnoznik, color = "Odsetek przyjętych (%)"), size = 3.5) +
  
  scale_y_continuous(
    name = "Liczba aplikacji o start w maratonie",
    labels = label_number(big.mark = " "),
    breaks = seq(0, 450000, 50000),
    sec.axis = sec_axis(~ . / mnoznik, name = "Odsetek przyjętych do startu (%) ",breaks = seq(0, 100, 10))
  ) +
  
  scale_x_continuous(breaks = 2010:2020)+
  
  scale_fill_manual(name = "", values = c("Liczba aplikacji" = kolor_slupka)) +
  
  scale_color_manual(name = "", values = c("Odsetek przyjętych (%)" = kolor_linii)) +
  
  labs(
    title = "London Marathon: Rosnące zainteresowanie, malejące szanse",
    subtitle = "Zestawienie liczby chętnych (słupki) z procentem osób startujących (linia,kropki)
     W roku 2020 z powodu COViDu dopuszczono tylko 77 elitarnych biegaczy",
    x = NULL
  ) +
  
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = kolor_tla_kremowy, color = NA),
    
    panel.background = element_rect(fill = kolor_tla_kremowy, color = NA),
  
    panel.grid.minor = element_blank(),  
    
    panel.grid.major.x = element_blank(),     

    panel.grid.major.y = element_line(color = kolor_siatki, linetype = "solid"),
    
    legend.position = "bottom",
    
    legend.background = element_rect(fill = kolor_tla_kremowy, color = NA),
    
    plot.title = element_text(face = "bold", size = 16),
    
    plot.subtitle=element_text(size=13,lineheight = 1.4, face="italic", margin=margin(b=10)),
    
    axis.text.x = element_text(angle = 45, hjust = 1),
    
    axis.title.y = element_text(margin = margin(r = 10), size=12),
    
    axis.title.y.right = element_text(color = kolor_linii,margin = margin(l = 12), size=12),
    
    axis.text.y.right = element_text(color = kolor_linii)
  )

