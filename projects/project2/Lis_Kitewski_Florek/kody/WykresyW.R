library(dplyr)
full_ruchy <- read.csv("full_moves.csv")
full_dane_partii <- read.csv("full_game_info.csv")
w_ruchy <- read.csv("output3_moves.csv")
w_dane_partii <- read.csv("output3_game_info.csv")
j_ruchy <- read.csv("output_moves.csv")
j_dane_partii <- read.csv("output_game_info.csv")
b_ruchy <- read.csv("output2_moves.csv")
b_dane_partii <- read.csv("output2_game_info.csv")

max_w<-max(w_ruchy$move_no_pair)
max_j<-max(j_ruchy$move_no_pair)
max_b<-max(b_ruchy$move_no_pair)
min_w<-min(w_ruchy$move_no_pair)
min_j<-min(j_ruchy$move_no_pair)
min_b<-min(b_ruchy$move_no_pair)

daty_w<-table(w_dane_partii$date_played)
daty_j<-table(j_dane_partii$date_played)
daty_b<-table(b_dane_partii$date_played)

wynik_w<-daty_w[daty_w==max(daty_w)]
wynik_j<-daty_j[daty_j==max(daty_j)]
wynik_b<-daty_b[daty_b==max(daty_b)]


df <- data.frame(
  Wojtek = c(max_w,min_w,wynik_w),
  Janek = c(max_j,min_j,wynik_j),
  Bartek = c(max_b,min_b,wynik_b)
)
rownames(df) <- c("najdłuższa gra", "najkrótsza gra", "najwięcej gier jednego dnia")
View(df)
write.csv(df,"podsumowanie.csv")
