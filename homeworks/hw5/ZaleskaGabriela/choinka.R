library(animation)

set.seed(3)

# glowna czesc choinki
n <- 4000
H <- 15
y <- runif(n, 0, H)
# obracamy, bo choinka jest szersza na dole
w <- (H - y)
# dzieki sinusowi tworzymy cos na podobe galezi, dopasowujemy parametry zeby choinka byla "ladna", nie zbyt waska czy szeroka
galezie <- sin(3 * y) + 0.3
x <- rnorm(n, 0, sd = w / 7 * abs(galezie))
dobre <- abs(x) < w / 2 # odrzucamy skrajne

# pień, zwykly prostokat
n_pien <- 200
x_pien <- runif(n_pien, -0.5, 0.5)
y_pien <- runif(n_pien, -2, 0)

# gwiazda
# w tworzeniu gif

# śnieg
n_snieg <- 3000
x_snieg <- runif(n_snieg, -20, 20)
y_snieg <- runif(n_snieg, -3, -2)

# bombki
n_bombki <- 200
bombki_idx <- sample(which(dobre), n_bombki, replace = TRUE)
kolory_bombki <- c("red", "yellow", "blue", "orange")

# tworzymy gif
saveGIF({
  for (i in 1:50) {
    # losowy wybór kolorów dla bombek aby stworzyc efekt migania
    col_bombki <- sample(kolory_bombki, n_bombki, replace = TRUE)
    
    # nowy plot z granatowym tłem
    plot(
      0,
      0,
      type = "n",
      xlim = range(x) * 1.1,
      ylim = c(-3, H + 1),
      axes = FALSE,
      xlab = "",
      ylab = "",
      asp = 1
    )
    rect(
      par("usr")[1],
      par("usr")[3],
      par("usr")[2],
      par("usr")[4],
      col = "#000033",
      border = NA
    )
    
    # choinka
    points(
      x[dobre],
      y[dobre],
      pch = '*',
      col = "darkolivegreen",
      cex = 1.5
    )
    
    # pień
    points(
      x_pien,
      y_pien,
      pch = "|",
      col = "sienna",
      cex = 1
    )
    
    # gwiazda
    points(0,
           H,
           pch = "*",
           col = "gold3",
           cex = 6)
    
    # śnieg
    points(
      x_snieg,
      y_snieg,
      pch = "*",
      col = "white",
      cex = 1.5
    )
    
    # bombki migające
    points(
      x[bombki_idx],
      y[bombki_idx],
      pch = 21,
      bg = col_bombki,
      col = "black",
      cex = 1.5
    )
    
    ani.pause(0.2)
  }
}, movie.name = "choinka.gif", interval = 0.2, ani.width = 600, ani.height = 800)
