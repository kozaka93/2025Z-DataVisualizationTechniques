library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)
library(showtext)


#Źródło oryginalnego posta + link do repozytorium autorki:

#https://x.com/FGazzelloni/status/1588294629002481664
#https://github.com/Fgazzelloni/TidyTuesday/tree/main/data/2022/w44_horror_movies  

#Problemy oryginalnego posta to:
# - Brak podpisu skali revenue (nie wiemy, że to skala logarytmiczna, od jakiego
# punktu się zaczyna i na jakim kończy)
# - Nie wiemy, w jakiej walucie liczone jest revenue
# - Nieczytelny podpis kolorów jako języki
# - Ogólny brak czytelności wykresu


#Źródło danych:

#https://github.com/rfordatascience/tidytuesday/tree/main/data/2022/2022-11-01


horror_movies <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2022/2022-11-01/horror_movies.csv')

# Revenue w dolarach amerykańskich [$]

data2 <- horror_movies %>% 
  arrange(release_date) %>% 
  filter(str_detect(genre_names,"horror|Horror"), status=="Released", revenue> 0) %>% 
  mutate(lang_clean = fct_lump_n(original_language, n = 8, other_level = "other"),
         release_year = as.numeric(str_sub(release_date,1,4)),
         revenue_in_mil = (as.numeric(revenue))) %>% 
  select(id,title,lang_clean, release_year, genre_names,vote_average,budget,revenue) %>% 
  group_by(release_year, lang_clean) %>% summarise(total_revenue_mil = (sum(revenue)/1e6), .groups = "drop") 

#Styl ma być jak oryginału - halloween

font_add_google("Creepster", "creepster")
font_add_google("Special Elite", "special")
showtext_auto()

wykres <- data2 %>% 
  mutate(total_revenue_mil = if_else(total_revenue_mil < 0.5, 0.5, total_revenue_mil)) %>% 
  ggplot(aes(x = release_year, y = total_revenue_mil, 
             fill = lang_clean)) + 
  geom_col(position = "stack", alpha = 0.8) +
  labs(title = "Horror Movies",
       subtitle = "Revenue by original language",
       caption="DataSource: #TidyTuesday 2022 week 44: Horror Movies by The Movie Database",
       x = "Year", y = "Revenue", fill = "Language \nabbreviation:") +  
  scale_y_log10(
    breaks = c(1e-3, 1e-2,1e-1, 1e0, 1e1, 1e2, 1e3, 1e4,1e5,1e6,1e7,1e8,1e9),
    labels = scales::dollar_format(suffix = " M")
  ) +
  scale_x_continuous(breaks = scales::breaks_width(10)) +
  scale_fill_brewer(palette = "Paired") +
  theme_minimal() +
  theme(
    text = element_text(color = "white", family = "creepster", size = 8),
    plot.title = element_text(size = 20, family = "creepster"),
    plot.subtitle = element_text(size = 16),
    plot.caption = element_text(size = 10),
    axis.title = element_text(size = 16),
    axis.text.x = element_text(color = "white", size = 10),
    axis.text.y = element_text(color = "white", size = 10),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    panel.grid.minor = element_line(color = "grey60"),
    panel.grid.major = element_line(color = "grey60"),
    plot.background = element_rect(color = "grey5", fill = "grey5")
  )

wykres

# Mój wykres:
# - poprawił czytelność danych
# - zawiera podpisy osi, czytelną podziałkę oraz podpisy języków
# - zachował estetykę Halloween pierwotnego posta
