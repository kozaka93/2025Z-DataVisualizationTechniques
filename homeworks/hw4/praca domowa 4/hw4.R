# Wstęp -----------------------------------------------------------------------
# Oryginalny wykres:  https://www.instagram.com/p/C6_NecdrKQF/?utm_source=ig_web_copy_link
# Dane do wykresu:    https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-05-14/readme.md#coffee_surveycsv
#
# Nieprawidłowości w oryginalnym wykresie:
# -   liczby na osi y nic nie wnoszą (nie da się z nich odczytać ilości preferowanych połączeń),
# -   'wstęgi' nie nachodzą na cały obszar pól (jest delikatny odstęp),
# -   kategorie dodatków nie zostały poprawnie rozdzielone (występuje kawa czarna z dodatkiem mleka, co jest sprzecznością),
# -   napisy po prawej stronie wykresu są momentami nieczytelne, przez to, że nachodza na wykres.
#
# Poniższy wykres jest lepszy od oryginału ze wzgędu na poprawioną czytelnośc oraz 
# mniejszą ilość niedopracowanych elementów (tak jak wyżej wspomniany odstęp).
#
# Pakiety ---------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(stringr)
library(ggalluvial)

# Dane ------------------------------------------------------------------------
coffee_survey <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-14/coffee_survey.csv')

# Porządkowanie danych --------------------------------------------------------
cof_fav <- coffee_survey %>% 
  select(favorite, additions) %>% 
  na.omit()

# Zamiana na krótsze i bardziej czytelne nazwy
cof_fav <- cof_fav %>% 
  mutate(additions = sub('Milk, dairy alternative, or coffee creamer', 'Milk/Creamer', additions),
         additions = sub('Sugar or sweetener', 'Sugar', additions),
         additions = sub('No - just black', 'Black', additions)
         ) 

# Separacja kombinacji na kawę czarną i kawę z dodatkami
# (aby wyeliminować przypadek kategorii 'Black' i 'Black, Milk/Creamer')
cof_fav <- cof_fav %>% 
  mutate(black = ifelse(str_detect(additions, 'Black'), 'Black', NA_character_),
         other = str_remove_all(additions, ',?\\s*Black[,]?\\s*'),
         other = na_if(other, "")
         ) %>%
  select(favorite, black, other) %>% 
  pivot_longer(!favorite, names_to = 'del', values_to = 'additions', values_drop_na = TRUE) %>% 
  select(favorite, additions)

# Wybór top 20 kombinacji 
# (jak w oryginale)
cof_fav <- cof_fav %>% 
  group_by(favorite, additions) %>% 
  summarise(n = n(), .groups = 'drop') %>% 
  arrange(desc(n)) %>% 
  head(20)

cof_fav <- cof_fav %>% 
  mutate(id = row_number())

colnames(cof_fav) <- str_to_title(colnames(cof_fav))

# Wykres ----------------------------------------------------------------------
cof_lodes <- to_lodes_form(cof_fav,
                           key = 'axis',
                           value = 'stratum',
                           axes = c('Favorite', 'Additions'),
                           id = 'Id') %>% 
  group_by(Id) %>% 
  mutate(fav_fill = first(stratum[axis == 'Favorite'])) %>% 
  ungroup()

col_pal <- c(
  "#1E1311",  
  "#3C1A10",  
  "#4B2E2F",  
  "#62231B",  
  "#73331E",  
  "#8B4513",  
  "#A0522D",  
  "#B5651D",  
  "#CD853F",  
  "#D2691E",  
  "#DEB887"
)

p <- cof_lodes %>% 
  ggplot(aes(x = axis, stratum = stratum, alluvium = Id, y = N))+
  geom_alluvium(aes(fill = fav_fill), width = 1/12, alpha = 0.4)+
  geom_stratum(aes(fill = ifelse(axis == 'Favorite', as.character(fav_fill), NA_character_)),
               width = 1/12, alpha = .4)+
  ggrepel::geom_text_repel(aes(label = after_stat(stratum)),
                           stat = 'stratum',
                           data = subset(cof_lodes, axis == 'Favorite'),
                           size = 3.5,
                           direction = 'y',
                           nudge_x = -0.15,
                           hjust = 1,
                           min.segment.length = 1
                           )+
  ggrepel::geom_text_repel(aes(label = after_stat(stratum)),
                           stat = 'stratum',
                           data = subset(cof_lodes, axis == 'Additions'),
                           size = 3.5,
                           direction = 'y',
                           nudge_x = 0.15,
                           hjust = 0
                           min.segment.length = 1
                           )+
  scale_fill_manual(values = col_pal, na.value = NA)


p <- p+
  labs(title = 'Coffee preferences and additions',
       subtitle = 'Top 20 combinations based on number of responses')+
  theme_void()+
  theme(legend.position = 'none',
        #plot.title.position = 'plot',
        #plot.subtitle.position = 'plot',
        plot.title = element_text(face = 'bold', size = 16, hjust = 0.1),
        plot.subtitle = element_text(size = 12, hjust = 0.1),
        axis.text.x = element_text(face = 'bold', size = 12))

ggsave('Poprawiony_wykres.png', plot = p, width = 850, height = 700, units = 'px', dpi = 300, bg = 'white', scale = 3)
