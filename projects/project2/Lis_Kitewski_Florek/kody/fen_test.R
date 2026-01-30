
library(dplyr)
library(plotly)
library(ggplot2)
library(showtext)

install.packages("showtext")


df_ruch_debiut <- read.csv("TWD_Projekt2\\debiuty.csv")
df_debiuty <- read.csv("TWD_Projekt2\\lista_debiut.csv")


View(df_ruch_debiut)

#Czcionka do figur
piece_map <- c(
  R = "♖", N = "♘", B= "♗", Q= "♕", K = "♔", P = "♙",  
  r = "♜", n= "♞", b= "♝", q= "♛", k = "♚", p= "♟"   
)

#Pomocnicza funkcja
fen_to_df <- function(fen, klatka) {
  
  #Dzielimy na wiersze szachownicy
  rows <- strsplit(fen, "/")[[1]]
  #Przygotowanie wyniku
  result <- list()
  
  #Po wierszach szachwonicy
  for (i in seq_along(rows)) {
    
    row <- rows[i]
    #Znam kolejność, wczytywania (wiersz od y się zmianiają powoli)
    y <- 9 - i        
    x <- 1
    
    chars <- strsplit(row, "")[[1]]
    
    for (ch in chars) {
      
      if (grepl("[0-9]", ch)) {
        x <- x + as.numeric(ch)
      } else {
        result[[length(result) + 1]] <- data.frame( frame=klatka,
          piece = piece_map[ch], x = x, y = y-0.1
        )
        x <- x + 1
      }
    }
  }
  
  #Łączenie wyników
  bind_rows(result)
}


one_game_leading_to_debut <- function(data, debut_name) {
  #Uwzględniam początkową pozycję do animacji
  fen0 <- "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  # Znajdź pierwsze id, w którym występuje debiut
  first_id <- data %>% filter(name == debut_name) %>%
    arrange(game_id) %>% slice(1) %>% pull(game_id)
  
  #W razie czego, zwracam pozycję 0
  if (length(first_id) == 0 || is.na(first_id)) {
    return (data.frame(fen=fen0))
  }
  
  #Zwracam feny do momentu debiutu włącznie
  fens<-data %>% filter(game_id == first_id) %>% mutate(step = row_number()) %>% 
    filter(step <= min(step[name == debut_name])) %>% select(fen)
  
  #Połączenie
  fens<-rbind(fen0,fens)
}

fen_rows_to_df <- function(fens_df) {
  
  out <- list()
  idx <- 1
  
  for (i in seq_len(nrow(fens_df))) {
    #Ramka z klatek na fen
    tmp <- fen_to_df(fens_df$fen[i],i)
    #Lista ramek danych, idx - indeks na który zapisujemy ramkę danych
    out[[idx]] <- tmp
    idx <- idx + 1
  }
  #Wywołąnie rbind, na out (pola listy out to ramki danych)
  do.call(rbind, out)
}

#Tworzenie szachownicy, pętla w pętli, funkcja definiowana w miejscu,
# W środku jest informacja co robię dla każdej pary (x,y) (64 pola) o środku w punkcie (x,y)
# na koniec spłaszczenie
board_shapes <- lapply(1:8, function(x) {
  lapply(1:8, function(y) {
    list(
      type = "rect",
      x0 = x - 0.5,
      x1 = x + 0.5,
      y0 = y - 0.5,
      y1 = y + 0.5,
      fillcolor = ifelse((x + y) %% 2 == 0, "#769656", "#EEEED2"),
      line = list(width = 1),
      layer="below"
    )
  })
}) |> unlist(recursive = FALSE)






debiut<-"Semi-Slav Defense: Accelerated Move Order";

wynik<- fen_rows_to_df(one_game_leading_to_debut(df_ruch_debiut,debiut))


t <- list(
  family = "roboto",
  size = 25,
  color = "black")


fig <- plot_ly() %>%
  
  add_text(
    data = wynik,
    x = ~x,
    y = ~y,
    text = ~piece,
    frame = ~frame,
    textfont = list(size = 30),
    hoverinfo="skip"
  ) %>%
  
  layout(
    shapes = board_shapes,
    xaxis = list(
      range = c(0.5, 8.5),
      tickvals = 1:8,
      ticktext = letters[1:8],
      tickfont = list(size=14),
      fixedrange = TRUE,
      showgrid=FALSE,
      title="",
      constrain="domain"
      
    ),
    yaxis = list(
      range = c(0.5, 8.5),
      tickvals=1:8,
      ticktext = 1:8,
      tickfont = list(size=14),
      scaleanchor = "x",
      fixedrange = TRUE,
      showgrid=FALSE,
      title="",
      automargin=FALSE
      
    ),
    showlegend=FALSE,
    title=list(text=paste(debiut),font=t)
    
  ) %>% animation_opts(transition = 0)

fig


###Czcionki
font_add(family="roboto",regular="C:\\Users\\Administrator\\Downloads\\Roboto\\Roboto-VariableFont_wdth,wght.ttf")
font_add(family="aovel",regular="C:\\Users\\Administrator\\Desktop\\Studia\\3 semestr\\TWD\\TWD_Projekt2\\aovel-sans-rounded-font\\AovelSansRounded-rdDL.ttf")
font_add(family = "mon", regular = "C:\\Users\\Administrator\\Downloads\\montserrat-font\\MontserratBlack-3zOvZ.ttf")
font_add(family = "lato", regular = "C:\\Users\\Administrator\\Downloads\\Lato\\Lato-Regular.ttf")

showtext_auto()


ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_minimal() +
  theme(
    text = element_text(family = "lato"),
    plot.title = element_text(size = 18)
  ) +
  labs(title = "Mój wykres")
