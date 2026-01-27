library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)


df_ruchy <- read.csv("TWD_Projekt2\\full_moves.csv")
df_dane_partii <- read.csv("TWD_Projekt2\\full_game_info.csv")
df_debiuty <- read.csv("TWD_Projekt2\\debiuty.csv")
View(df_dane_partii)
View(df_ruchy)
View(df_debiuty)


nick = c("FirejFox","BarMan-ek","GDgamers","bArmAnEk")

df_debiuty <- df_debiuty %>% filter(name!="")


df_debiuty %>% filter(player %in% c("FirejFox")) %>%  group_by(game_id) %>% 
  summarise(dlug = max(move_no)) %>% summarise(srednia = mean(dlug))



### 5 najczęściej granych debiutow do 6 ruchów
df_debiuty %>% filter(player %in% c("bArmAnEk")) %>% group_by(game_id) %>% 
  filter(move_no<6) %>% summarise(debiut = last(name), .groups = "drop") %>% 
  group_by(debiut) %>% summarise(ile = n()) %>% top_n(5) %>% arrange() %>% 
  ggplot(aes(y=debiut,x=ile)) + geom_col()

