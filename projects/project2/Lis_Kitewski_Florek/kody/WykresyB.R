library(ggplot2)
library(dplyr)
library(RColorBrewer)


df <- read.csv("output2_game_info.csv")
nazwy_bartka <- c("BarMan-ek", "bArmAnEk")

kolory <- c(
  "FirejFox" = "orange",
  "GDgamers" = "blue",
  "BarMan-ek" = "violet",
  "bArmAnEk" = "violet"
)

########## Załadowanie danych

df_ruchy <- read.csv("TWD_Projekt2\\full_moves.csv")
df_dane_partii <- read.csv("TWD_Projekt2\\full_game_info.csv")
View(df_dane_partii)
View(df_ruchy)

###################### Bardzo źle wyglądające wykresy kołowe
######## Wykresy kołowe dzielące partie na ilość porażek, zwycięstw oraz remisów

df2 <- df %>% transmute(
  wynik = case_when(
    winner %in% nazwy_bartka ~ "win",
    winner == "draw" ~ "draw",
    .default = "lose"
  )
) %>% group_by(wynik) %>% summarise(n = n())


df2 %>% ggplot(aes(x = "", y = n, fill = wynik)) +
  geom_bar(stat="identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  
  theme_void() +
  
  geom_text(aes(label = wynik), position = position_stack(vjust = 0.5)) +
  scale_fill_brewer(palette="Set1")


pie(df2$n, labels = df2$wynik, border = "white", col = c("orange", "red", "green"))


####################



l1 <- df_ruchy %>% filter(move_no == 1) %>% select()



