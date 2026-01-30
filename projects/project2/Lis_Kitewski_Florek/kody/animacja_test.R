library(plotly)
library(tidyverse)
library(ggplot2)
library(dplyr)


square_to_xy <- function(square) {
  x <- match(substr(square, 1, 1), letters[1:8])
  y <- as.numeric(substr(square, 2, 2))
  c(x, y)
}



moves <- tribble(
  ~frame, ~piece, ~x, ~y,
  1, "♔", 5, 0.9,
  1, "♕", 4, 0.9,
  2, "♔", 5, 0.9,
  2, "♕", 4, 2.9,
  3, "♔", 5, 2.9,
  3, "♕", 4, 2.9
)

# pionki białe, pionki czarne, skoczek b, skoczek cz, goniec b, gońce cz, wieże b, wieże cz.

# Kopia ramki danych to aktualna pozycja na planszy
# Trzeba tylko jedną usuną i jedną wstawić
# Działam na kopii, czyli usuwam jeden wiersz i jeden dodaje (a jak bicie, to?)

# Muszę wiedzieć co się zmieniło?

pocz_x = c(1:8,1:8,2,7,2,7,3,6,3,6,1,8,1,8,4,5,4,5)
pocz_y = c(rep(2,8),rep(7,8),rep(c(1,1,8,8),4))
pocz_figury = c(rep(figury_białe[1],8),rep(figury_czarne[1],8), rep(figury_białe[2],2),
                rep(figury_czarne[2],2),rep(figury_białe[3],2),rep(figury_czarne[3],2),
                rep(figury_białe[4],2),rep(figury_czarne[4],2), figury_białe[5],figury_białe[6],
                figury_czarne[5],figury_czarne[6])
klatka = rep(1,32)


df <- data.frame(frame=klatka, piece=pocz_figury, x=pocz_x,y=pocz_y)

#Robić kopię poprzedniej ale z 1 zmianą - tak?
# Ze spisu ruchów wyciągnąć to info, tylko, że w przypadku bić to się może zmienić.
# Mogę zrobić kopię roboczej i tam zrobić jedną zmianę, czyli uwzględnić wszystko?
#

View(df)




# Dla każdej (32) figury osobna lista?

figury_białe = c("♙","♘","♗","♖","♕","♔")
figury_czarne = c("♟","♞","♝","♜","♛","♚")

debiuty_ruchy = read.csv("TWD_Projekt2\\lista_debiut.csv")
View(debiuty_ruchy)

board_shapes <- lapply(1:8, function(x) {
  lapply(1:8, function(y) {
    list(
      type = "rect",
      x0 = x - 0.5,
      x1 = x + 0.5,
      y0 = y - 0.5,
      y1 = y + 0.5,
      fillcolor = ifelse((x + y) %% 2 == 0, "#769656", "#EEEED2"),
      line = list(width = 0),
      layer="below"
    )
  })
}) |> unlist(recursive = FALSE)


fig <- plot_ly() %>%
  
  add_text(
    data = df,
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
    showlegend=FALSE
    
  )

fig

#ramka danych: frame, piece, x, y

# Zmontować początkowy układ + potem 


square_to_xy("c3")
