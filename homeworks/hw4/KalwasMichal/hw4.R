
# Link do błędnej wizualizacji: https://x.com/GarethBurns4/status/1745579420247597130/photo/1
# Link do danych: https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-01-09

#Błędy oryginału : 
#Autor niepotrzebnie korzysta z współrzędnych biegunowych, co znacząco zmniejsza czytelność 
#oryginalnego wykresu. Poza tym na oryginalnym wykresie brakuje odpowiedniego opisu wartości na osiach
#przez co odbiorca musi się domyślać co się na nich znajduje. Autor oryginału wspomina także o krajach nordyckich
# jednak w żaden sposób nie zaznacza ich na swoim wykresie.

#Uzasadnienie:
#Poprawiona wersja odchodzi od współrzędnych biegunowych na rzecz współrzędnych kartezjańskich, znacząco 
#poprawiając czytelność wykresu. Posiada odpowiednie opisy osi, potrzebne do poprawnego zinterpretowania danych.
#Poza tym oznacza wspomniane przez autora oryginału kraje nordyckie oraz dodaje etykiete dla największej wartości,
#ułatwiając tym odczytywanie wykresu.






library(dplyr)
library(tidyr)
library(ggplot2)
library(forcats)


tuesdata <- tidytuesdayR::tt_load('2024-01-09')

canada_births_1991_2022 <- tuesdata$canada_births_1991_2022
nhl_player_births <- tuesdata$nhl_player_births
nhl_rosters <- tuesdata$nhl_rosters
nhl_teams <- tuesdata$nhl_teams


data <- nhl_rosters %>% 
  filter(season==20232024 & !(birth_country %in% c("CAN","USA"))) %>% 
  group_by(birth_country) %>% 
  summarise(count=n()) %>% 
  mutate(nordic_countries= (birth_country %in%c("SWE", "FIN", "DNK", "NOR")),birth_country=fct_reorder(birth_country,count))

data %>% 
  ggplot(aes(x=birth_country,y=count,fill=nordic_countries))+
  geom_col()+
  geom_text(aes(label=ifelse(birth_country == "SWE",count,"")),vjust= -0.25)+
  scale_fill_manual(values = c( "TRUE" = "#0072B2","FALSE" = "darkgray"),name= "Nordic Countries", labels=c("No","Yes"))+
  labs(title = "Nationality of Forgein Players in NHL", subtitle = "In the latest NHL season there were 798 players born outside of North America. These\ncame from 19 different countries with 50% of players coming from Nordic countries"
       ,x= "Nationality", y= "Count" )

