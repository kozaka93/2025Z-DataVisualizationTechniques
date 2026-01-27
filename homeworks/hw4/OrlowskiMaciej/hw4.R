## LINK DO POPRAWIANEJ WIZUALIZACJI : ##
# https://x.com/geokaramanis/status/1868349392111259660?s=46
## LINK DO ZESTWU DANYCH : ##
# https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-12-10

# Wybrałem ten wykres jako przykład wykresu z nieprawidłowościami, ponieważ
# wykres ten jest z początku mało czytelny - zanikające nazwy do środka koła, a 
# także na zewnątrz mocno zaburzają czytelność wykresu. Nie ma tutaj żadnej legendy
# pokazującej jak bardzo faktycznie poszczególne zapachy ze sobą korelują. 
# Na wykresie jest też za długi tytuł z opisem wykresu - to powinno być w innym miejscu.

###########################################################

library(ggplot2)
library(tidyr)
library(dplyr)

##################### WCZYTANIE DANYCH ##################### 
tuesdata <- tidytuesdayR::tt_load('2024-12-10')
parfumo_data_clean <- tuesdata$parfumo_data_clean

##################### OBROBIENIE DANYCH ####################

MainAccords <- parfumo_data_clean %>% 
  filter(is.na(Main_Accords) == FALSE) %>% 
  separate_rows(Main_Accords, sep = ", ") 

unique_accords <- unique(MainAccords$Main_Accords)
unique_accords2 <- unique_accords[-length(unique_accords)]

MainAccords2 <- MainAccords %>% 
  unique() %>%
  mutate(acc = 1) %>% 
  pivot_wider(names_from = Main_Accords,
              values_from = acc,
              values_fill = 0) %>% 
  select(all_of(unique_accords2)) 

accords_cor <- cor(MainAccords2)

############## RYSOWANIE MACIERZY KORELACJI ################

accords_cor_to_plot <- as.data.frame(accords_cor) %>%
  mutate(names1 = rownames(.)) %>%
  pivot_longer(cols = -names1, names_to = "names2", values_to = "correlation")

ggplot(accords_cor_to_plot, aes(x = names1, y = names2, fill = correlation)) +
  geom_tile()+                 
  scale_fill_gradient2(                        
    low = "darkred", 
    mid = "#f7f7f7", 
    high = "darkgreen", 
    midpoint = 0, 
    limit = c(-1, 1)
  ) +
  labs(
    title = "Siła powiązań między nutami zapachowymi",
    x = "",
    y = "",
    fill = "Współczynnik\nkorelacji"
  ) +
  theme(
    axis.text.x = element_text(angle = 90),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 15),
    legend.title = element_text(hjust = 0.5)
  ) 


###########################################################

# Przygotowany wykres jest lepszy od oryginału, ponieważ łatwiej
# na nim zauważyć, które nuty konkretnie są powiązane ze sobą, a które
# już nie. Posiada również czytelną legendę, która pozwala sprawdzić 
# jak silna jest korelacja faktycznie. W odróżnieniu od tamtego wykresu 
# pokazuje wszystkie możliwe relacje pomiędzy nutami, nie ma efektu "zanikania".
# Nie jest on przeładowany efektami dekoracyjnymi, dzięki czemu jest łatwiejszy 
# w analizie i interpretacji.


