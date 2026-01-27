library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(tibble)
library(ggrepel)
library(extrafont)

df_ruchy <- read.csv("TWD_Projekt2\\full_moves.csv")
df_dane_partii <- read.csv("TWD_Projekt2\\full_game_info.csv")
df_debiuty <- read.csv("TWD_Projekt2\\debiuty.csv")
View(df_dane_partii)
View(df_ruchy)
View(df_debiuty)

nick = c("FirejFox","BarMan-ek","GDgamers","bArmAnEk")

df_dane_partii<-df_dane_partii %>% 
  mutate(gracz = if_else(white %in% nick,white,if_else(black %in% nick,black, NA))) %>% 
  mutate(gracz = if_else(gracz=="BarMan-ek","bArmAnEk",gracz)) %>% 
  mutate(date_played = ymd(date_played)) %>% 
  mutate(weekday = wday(date_played, label=TRUE, abbr=FALSE)) %>% 
  mutate(year = year(date_played))

df_ruchy <- df_ruchy %>% left_join(df_dane_partii %>% select(game_id, gracz, weekday, year),
                                   by = "game_id")

df_debiuty <- df_debiuty %>% left_join(df_dane_partii %>% select(game_id, gracz, weekday, year),
                                   by = "game_id")
#######
rok = c(2017,2025)
gracze <- nick

########### Używane wykresy
####### 1 strona
####### Wygrane w dni tygodnia

poziomy = c("poniedziałek","wtorek","środa","czwartek","piątek","sobota","niedziela")

df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
  select(winner,weekday) %>% mutate(wygrana=case_when(
    winner %in% nick ~ "wygrana",
    winner == "draw" ~ "remis",
    .default = "przegrana")) %>% filter(!(wygrana=="remis")) %>% 
  group_by(weekday,wygrana) %>% summarise(ile = n()) %>% 
  mutate(weekday = factor(weekday, levels=poziomy))%>% 
  ggplot(aes(y=weekday,x=ile,fill=wygrana)) + geom_col(position = "dodge") +
  labs(title = "Wygrane i przegrane w zależności od dnia tygodnia", x = "liczba wygranych",
       y = "dzień tygodnia", fill="") +
  theme(
    panel.background = element_blank(),
    plot.background = element_rect(colour = "white"),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0.5),
    axis.text.x= element_text(color = "black",vjust=1,size=10),
    axis.text.y = element_text(color="black",size=10),
    axis.ticks.y = element_line(color="black"),
    panel.grid.major.y = element_line(color="black",linetype=1),
    panel.grid.minor.y = element_line(color="black"),
    panel.grid.minor.x = element_line(colour = "black"),
    axis.ticks.x = element_blank(),
    legend.text = element_text(color="black",size=14),
    legend.title = element_text(color="black",size=14),
    title = element_text(size=16),
    panel.grid.major.x = element_blank()
  ) + scale_fill_discrete(palette = c("green","red"), limits=c("wygrana","przegrana"))

####### Kołowy z porażkami

df_dane_partii %>%  filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
  select(winner,gracz) %>% mutate(wygrana=case_when(
    winner %in% nick ~ "wygrana",
    winner == "draw" ~ "remis",
    .default = "przegrana")) %>% group_by(wygrana) %>% summarise(ile = n()) %>% 
  ggplot(aes(x = "", y = ile, fill = wygrana)) +
  geom_bar(stat="identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  theme_void() +
  geom_text(aes(label = wygrana),size=6,position = position_stack(vjust = 0.5)) +
  scale_fill_brewer(palette = "Set1") + guides(fill = "none")

###### Kołowy 2


df_plot <- df_dane_partii %>% filter(year <= rok[2] & year >= rok[1]) %>%
  filter(gracz %in% gracze) %>% select(winner, gracz) %>% mutate(wygrana = case_when(
    winner %in% nick ~ "wygrana",
    winner == "draw" ~ "remis",
    TRUE ~ "przegrana"
  )) %>% group_by(wygrana) %>% summarise(ile = n(), .groups = "drop") %>%
  mutate( wygrana = factor(wygrana, levels = c("wygrana", "remis", "przegrana")),
    proc = ile / sum(ile) * 100,
    label = paste0(wygrana, " (", round(proc, 1), "%)"),
    ypos = cumsum(ile) - 0.5*ile
  )

ggplot(df_plot, aes(x = 1, y = ile, fill = wygrana)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  theme_void() +
  geom_text(aes(y = ypos, label = label),
            size = 5,
            position = position_nudge(x = 0.6)) +
  scale_fill_manual(values = c( "wygrana" = "#00b300",
      "remis" = "#0000b3","przegrana" = "#cc0000"),name = "Wynik") +
  guides(fill = "none") + xlim(0.5, 2) 


  
help()
####### 2 strona
####### Średni materiał

df_ruchy %>% filter(year<=rok[2] & year>=rok[1]) %>% 
  select(gracz, move_no,white_pawn_count,white_queen_count,white_bishop_count,white_knight_count,
         white_rook_count,black_pawn_count,black_queen_count,black_bishop_count,
         black_knight_count,black_rook_count) %>% 
  mutate(value = 9*(white_queen_count + black_queen_count)+
           5*(white_rook_count + black_rook_count)+
           3*(white_bishop_count+black_bishop_count+white_knight_count+black_knight_count)+
           (white_pawn_count+black_pawn_count)) %>% 
  select(move_no, value, gracz) %>% group_by(move_no, gracz) %>% summarise(avg = mean(value)) %>% 
  mutate(gracz = case_when(
    gracz == "FirejFox" ~ "Janek",
    gracz == "GDgamers"~ "Wojtek",
    .default = "Bartek"
  )) %>% 
  ggplot(aes(x=move_no, y = avg, color=gracz)) + geom_line(size=1) +
  labs(title = "Średni materiał na planszy ze względu na długość partii",
       x = "Liczba ruchów", y = "Średni materiał", color = "Gracz") +
  theme(
    panel.background = element_blank(),
    plot.background = element_rect(colour = "white"),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0.5),
    axis.text.x= element_text(color = "black",vjust=1,size=10),
    axis.text.y = element_text(color="black",size=10),
    axis.ticks.y = element_line(color="black"),
    panel.grid.major.y = element_line(color="black",linetype=1),
    panel.grid.minor.y = element_line(color="black"),
    panel.grid.minor.x = element_line(colour = "black"),
    axis.ticks.x = element_blank(),
    legend.text = element_text(color="black",size=14),
    legend.title = element_text(color="black",size=14),
    title = element_text(size=16),
    panel.grid.major.x = element_blank()
  )


####### Rozkład partii
df_ruchy %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
  select(game_id,move_no) %>% group_by(game_id) %>% summarise(ruchy = max(move_no)) %>% 
  ggplot(aes(x=ruchy)) + geom_histogram(fill="black",colour="lightgray",bins = 30) + 
  labs(title= "Rozkład partii względem ilości ruchów", x = "ilość ruchów",y = "liczba partii") +
  theme(
    panel.background = element_blank(),
    plot.background = element_rect(colour = "white"),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0.5),
    axis.text.x= element_text(color = "black",vjust=1,size=10),
    axis.text.y = element_text(color="black",size=10),
    axis.ticks.y = element_line(color="black"),
    panel.grid.major.y = element_line(color="black",linetype=1),
    panel.grid.minor.y = element_line(color="black"),
    panel.grid.minor.x = element_line(colour = "black"),
    axis.ticks.x = element_blank(),
    title = element_text(size=16),
    panel.grid.major.x = element_blank()
  )

######### Strona 3
##### Heatmapa ruchów

df_pola <- df_ruchy %>% select(to_square) %>% group_by(to_square) %>% summarise(ile = n())
df_pola <- df_pola %>% mutate(y = substr(to_square,2,2), x = substr(to_square,1,1)) %>% 
  select(-to_square)

ilosc_partii <- dim(df_dane_partii)[1]

df_pola %>% mutate(ile = ile/ilosc_partii) %>% ggplot(aes(x=x, y=y, fill=ile)) + 
  geom_tile(color="black") +
  scale_fill_gradient(low = "white", high = "darkgreen", name="Średnia") +theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x= element_text(color = "black",vjust=1,size=10),
    axis.text.y = element_text(color="black",size=10),
    legend.text = element_text(color="black",size=14),
    legend.title = element_text(color="black",size=14),
    legend.ticks = element_line(colour = "black"),
    title = element_text(size=16),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0)
  )+
  guides(fill = guide_colorbar(barwidth = 1.5, barheight = 15)) +
  labs(title="Średnie odwiedzanie pól względem partii") +
  coord_fixed()

##### Wykres kolumnowy debiuty DO SKOŃCZENIA

df_debiuty <- df_debiuty %>% filter(name!="")


df_debiuty %>% filter(player %in% c("bArmAnEk")) %>% group_by(game_id) %>% 
  filter(move_no<6) %>% summarise(debiut = last(name), .groups = "drop") %>% 
  group_by(debiut) %>% summarise(ile = n()) %>% top_n(5) %>% arrange() %>% 
  ggplot(aes(y=debiut,x=ile)) + geom_col(fill="black") + 
  labs(title="Top 5 rozegranych debiutów do 6 ruchów", x = "Liczba", y = "Debiut") +
  theme(
    panel.background = element_blank(),
    plot.background = element_rect(colour = "white"),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0.5),
    axis.text.x= element_text(color = "black",vjust=1,size=10),
    axis.text.y = element_text(color="black",size=10),
    axis.ticks.y = element_line(color="black"),
    panel.grid.major.y = element_line(color="black",linetype=1),
    panel.grid.minor.y = element_line(color="black"),
    panel.grid.minor.x = element_line(colour = "black"),
    axis.ticks.x = element_blank(),
    legend.text = element_text(color="black",size=14),
    legend.title = element_text(color="black",size=14),
    title = element_text(size=16),
    panel.grid.major.x = element_blank()
  )

######## Tabela z podsumowaniem


View(df_dane_partii)


View(df_ruchy)

rok <- c(2017,2020)

max_min_partia <- df_ruchy %>% filter(year<=rok[2] & year>=rok[1])%>% 
  select(gracz, move_no) %>% group_by(gracz) %>% 
  summarise(max_dlg = max(move_no), min_dlg = min(move_no)) %>% 
  mutate(gracz = case_when(gracz=="FirejFox"~"Janek",gracz=="GDgamers" ~ "Wojtek", .default = "Bartek"))


max_dzien <- df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% 
  select(gracz, date_played) %>% group_by(gracz, date_played) %>% summarise(ile = n()) %>% 
  group_by(gracz) %>% summarise(liczba_partii = max(ile))
wynik <- cbind(max_min_partia, max_dzien)[c(1,2,3,5)]


wynik <- t(wynik)

colnames(wynik) <- (unlist(wynik[1,]))

wynik<-wynik[-1,,drop=FALSE]

wynik <- cbind(kategoria =c("najdłuższa gra", "najkrótsza gra", "najwięcej gier jednego dnia"), wynik )



font_import()      # pierwszy raz importuje czcionki systemowe
loadfonts(device = "win")  # dla Windows




p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  labs(title = "Przykładowy wykres") +
  theme(
    text = element_text(family = "Calibri"),     
    plot.title = element_text(size = 16)
  )



rok <- c(2017,2025)
player <- nick

if (player=="all")
  player = nick

dane<-df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(player)) %>% 
  filter(winner==gracz)
dim(dane)[1]

