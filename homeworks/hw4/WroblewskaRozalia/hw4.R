# LINK DO POSTA: https://x.com/PursuitOfDS/status/1587428781832032256?s=20
# post zawiera 4 wizualizacje, ja skupiłam się na pierwszej z nich (pobrana wizualizacja jest w folderze)
# LINK DO DANYCH: https://raw.githubusercontent.com/rfordatascience/tidytuesday/refs/heads/main/data/2022/2022-11-01/horror_movies.csv'
# są to dane użyte przez autora posta oraz przeze mnie

# NIEPRAWIDŁOWOŚCI, jakie zauważyłam w oryginalnej wizualizacji:
# -> prawie wszystkie punkty znajdują się w jednej częsci wykresu,
#    co sprawia, że  na siebie nachodzą i zasłaniają siebie nawzajem
# -> kolory jakie zostały przyporządkowane poszczególnym językom (language) i parametr alpha, 
#    potrafią wprowadzić w błąd tzn. gdy punkty o kolorach żółtym (Other) i niebieskim (English)
#    są położone b. blisko siebie, to tworzą kolor zielony (Espagnol)
# -> wykres przedstawia wiele danych jednocześnie - average rating, popularity, language
#    w takiej sutuacji praktycznie wszystkie punkty tworzą jedną plamę, co sprawia, że
#    z wykresu trudniej wyciągnąć wnioski (nie widać żadnej korelacji między średnią oceną i popularnością filmu)
#
# Co można zmienić: typ wykresu, dobór osi (może niekoniecznie trzeba pokazywać tak dużo informacji naraz)


library(ggplot2)
library(dplyr)
library(tidyr)
install.packages('forcats')
library(forcats)
install.packages('stringr')
library(stringr)
library(RColorBrewer)


horror_movies <- read.csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/refs/heads/main/data/2022/2022-11-01/horror_movies.csv')

View(horror_movies)

horror_movies %>% 
  mutate(original_language = fct_lump(str_to_upper(original_language), n = 5)) %>% 
  filter(popularity > 1,
         vote_average > 0,
         vote_count > 10) %>% 
  ggplot(aes(x = vote_average, fill = original_language)) +
  geom_histogram(color = 'white', bins = 79) +
  theme(plot.background = element_rect(fill = "darkgray"), 
        panel.background = element_rect(fill = "darkgray"),
        legend.background = element_rect(fill = "darkgray"),
        plot.title = element_text(hjust = 0.5),
        panel.grid = element_line(colour = "black")) +
  scale_fill_brewer(palette = "Accent") +
  labs(y = "Count",
       x = "Average vote",
       fill = "Language",
       title = "Movie Rating")


# Uważam, że przygotowany wykres jest lepszy od oryginału, ponieważ można zobaczyć wszystkie dane (nie zasłaniają siebie).
# Można także łatwiej wyciągnąć pewne wnioski: np. jaki jest stosunek liczby filmów angielsko języcznych do innych,
# rozkład średnich ocen dla filmów bardzo przypomina rozkład normalny.