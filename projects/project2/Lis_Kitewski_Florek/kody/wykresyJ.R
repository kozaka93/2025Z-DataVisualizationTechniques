library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)

### Wczytanie danych z danej ramki

df_ruchy <- read.csv("TWD_Projekt2\\output_moves.csv")
df_dane_partii <- read.csv("TWD_Projekt2\\output_game_info.csv")
View(df_dane_partii)
View(df_ruchy)

##########################
df_ruchy2 <- read.csv("TWD_Projekt2\\output2_moves.csv")
df_dane_partii2 <- read.csv("TWD_Projekt2\\output2_game_info.csv")
View(df_ruchy2)
View(df_dane_partii2)

##########################
df_ruchy3 <- read.csv("TWD_Projekt2\\output3_moves.csv")
df_dane_partii3 <- read.csv("TWD_Projekt2\\output3_game_info.csv")
View(df_ruchy3)
View(df_dane_partii3)
##########################
#df_ruchy_full <- read.csv("TWD_Projekt2\\full_moves.csv")
#df_dane_partii_full <- read.csv("TWD_Projekt2\\full_game_info.csv")
#View(df_dane_partii_full)
#View(df_ruchy_full)
########################## DO PONIŻSZEGO KODU
df_ruchy <- read.csv("TWD_Projekt2\\full_moves.csv")
df_dane_partii <- read.csv("TWD_Projekt2\\full_game_info.csv")
View(df_dane_partii)
View(df_ruchy)


### Do wpisania nicki - potrzebne do wygranych czy ruchów
nick = c("FirejFox","BarMan-ek","GDgamers","bArmAnEk")

###########################
### Tworzenie wykresu ile sumarycznie gier w jakim dniu tygodnia

### Zamiana dat i tworzenie dnia tygodnia
df_dane_partii <- df_dane_partii %>% mutate(date_played = ymd(date_played)) %>% 
  mutate(weekday = wday(date_played, label=TRUE, abbr=FALSE))

### Dane do wykresu
df_dni_partie <- df_dane_partii %>% group_by(weekday) %>% summarise(ile = n())
View(df_dni_partie)

### Wykres
df_dni_partie %>% ggplot(aes(x=weekday, y = ile)) + geom_col() +
  labs(title="Rozkład partii na dni tygodnia")
###########################

### Tworzenie wykresu ile razy jaką figurą, czy pionkiem się ruszyłem

df_ruchy %>% filter(player %in% nick) %>% group_by(piece) %>% summarise(ile = n()) %>% 
  ggplot(aes(x=piece, y=ile)) + geom_col() + labs(title = "Ilość ruchów na typ figury")

### Ten sam pomysł, ale dzielimy ruchy na poszczególne figury
df_ruchy %>% filter(player %in% nick) %>% group_by(piece) %>% summarise(ile = n()) %>%
  mutate(ile = case_when(
    piece == "P" ~ ile/8,
    piece %in% c("R","B","N") ~ile/2,
    .default = ile
   )) %>% 
  ggplot(aes(x=piece, y=ile)) + geom_col() + labs(title = "Ilość ruchów na pojedynczą figurę")

### Rozkład partii względem długości
### UWAGA! Z jakiegoś powodu is_game_over nie zawsze wskazuje na 1 jak się partia skończyła
df_ruchy %>% select(game_id,move_no) %>% group_by(game_id) %>% summarise(ruchy = max(move_no)) %>% 
  ggplot(aes(x=ruchy)) + geom_histogram() + labs(title= "Rozkład partii względem ilości ruchów")

# NIE DZIAŁA
#df_ruchy %>% filter(is_game_over==1) %>% select(move_no) %>% ggplot(aes(x=move_no)) +
 # geom_histogram() + labs(title= "Rozkład partii względem ilości ruchów")

### Rozkład matów względem rodzaju figury, wynik trochę oczywisty
df_ruchy %>% filter(is_check_mate==1) %>% select(piece) %>% group_by(piece) %>% 
  summarise(ile = n()) %>% ggplot(aes(x=piece, y=ile)) + geom_col() +
  labs(title = "Rozkład matów względem typu figury")

### Heatmapa pól szachowych na planszy - ile na razy na jakie pole się ruszylismy, 
### czyli nie uwzględeniamy pól startowych

df_pola <- df_ruchy %>% select(to_square) %>% group_by(to_square) %>% summarise(ile = n())
df_pola <- df_pola %>% mutate(y = substr(to_square,2,2), x = substr(to_square,1,1)) %>% 
  select(-to_square)

df_pola %>% ggplot(aes(x=x, y=y, fill=ile)) + geom_tile()


### Średnia z partii
ilosc_partii <- dim(df_dane_partii)[1]

df_pola %>% mutate(ile = ile/ilosc_partii) %>% ggplot(aes(x=x, y=y, fill=ile)) + 
  geom_tile(color="black") +
  scale_fill_gradient(low = "white", high = "darkgreen") +theme_minimal()+
  theme(
    axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        )+
  labs(title="Średnie odwiedzanie pól względem partii")

### Zakończenie partii
### PROBLEM: Lichess i Chesscom dają inny komentarz
### Co zrobić z Normal, Time forfeit? Można pewnie z drugiej ramki odczytać wynik
### TO DO, DO ZROBIENIA

df_dane_partii %>% select(termination, winner, weekday) %>% mutate(koniec = case_when(
  substr(termination,0,5) == "Remis" ~ termination,
  termination == "Normal" ~ termination,
  termination == "Time forfeit" ~ termination,
  .default = substr(termination, regexpr(" ",termination)+1,nchar(termination))
)) %>% 
  mutate(wygrana =case_when(
  winner %in% nick ~ "wygrana",
  winner == "draw" ~ "remis",
  .default = "przegrana")) %>% group_by(koniec, wygrana) %>% summarise(ile = n())
 
df_dane_partii %>% select(termination) %>% distinct(termination)

### Wygrana w zależności od dnia tygodnia

df_dane_partii %>% select(winner,weekday) %>% mutate(wygrana=case_when(
  winner %in% nick ~ "wygrana",
  winner == "draw" ~ "remis",
  .default = "przegrana")) %>% filter(!(wygrana=="remis")) %>% 
  group_by(weekday,wygrana) %>% summarise(ile = n()) %>% 
  ggplot(aes(y=weekday,x=ile,fill=wygrana)) + geom_col(position = "dodge") +
  labs(title = "Wygrane i przegrane w zależności od dnia tygodnia")

######################### Średnia ilość figur na planszy ze względu na ruchy

df_ruchy %>% select(move_no,white_count,black_count) %>% mutate(liczba = white_count+black_count) %>% 
  group_by(move_no) %>% summarise(avg = mean(liczba)) %>% 
  ggplot(aes(x=move_no, y=avg)) + geom_line() +
  labs(title= "Średnia liczba figur na planszy ze względu na liczbę ruchów")

######################### Średni materiał na planszy ze względu na ruchy
df_ruchy %>% select(move_no,white_pawn_count,white_queen_count,white_bishop_count,white_knight_count,
                    white_rook_count,black_pawn_count,black_queen_count,black_bishop_count,
                    black_knight_count,black_rook_count) %>% 
  mutate(value = 9*(white_queen_count + black_queen_count)+
           5*(white_rook_count + black_rook_count)+
           3*(white_bishop_count+black_bishop_count+white_knight_count+black_knight_count)+
           (white_pawn_count+black_pawn_count)) %>% 
  select(move_no, value) %>% group_by(move_no) %>% summarise(avg = mean(value)) %>% 
  ggplot(aes(x=move_no, y = avg)) + geom_line() +
  labs(title = "Średni materiał na planszy ze względu na ruchy")

######################### Czy gra się kończyła matem
df_ruchy %>%  filter(is_game_over==1) %>% 
  select(is_check_mate, is_game_over) %>% group_by(is_check_mate) %>% 
  summarise(ile = n())

df_ruchy %>% select(game_id,move_no) %>% group_by(game_id) %>% summarise(ruchy = max(move_no)) %>% 
  left_join(df_ruchy, by=c("game_id"="game_id","ruchy"="move_no")) %>% 
  group_by(is_check_mate) %>% mutate(is_check_mate = case_when(
    is_check_mate == 1 ~ "tak",
    .default = "nie"
  )) %>% summarise(ile = n()) %>%
  ggplot(aes(x=is_check_mate,y=ile)) + geom_col() +
  labs(title="Ile gier skończyło się matem")
  


  # Coś tam wykres kołowy
  ggplot(aes(x="",y=n,fill=as.factor(is_check_mate))) + 
  geom_bar(stat="identity",width=1)+coord_polar("y",start = 0) + theme_minimal() +
  theme(axis.line = element_blank(),
        axis.text = element_blank(),
        plot.background = element_blank(),
        )
