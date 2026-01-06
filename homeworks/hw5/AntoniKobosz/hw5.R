library(dplyr)
library(ggplot2)

N = 3
liscie_x <-  c(-1.5,0,1.5,
             -1.2,0,1.2,
             -.8,0,.8)
liscie_y <- c(1,2.5,1
             ,1.8,3.5,1.8,
             2.8,4.4,2.8) - 0.5
kolory_lisci <- c("#0B6623", "#1E8449", "#3CB371")
# licie
trojkaty <- data.frame(
  id = rep(seq(1,N),each=3),
  kolor = rep(kolory_lisci,each=3),
  x = liscie_x,
  y = liscie_y
)
# Pień
pien <-  data.frame(
x = c(-0.3,0.3,0.3,-0.3),
y = c(0,0,1,1)
)
# Gwiazdka
gwiazda <- data.frame(x=0,y=3.9)
# Bombki
bombki <-  data.frame(
  x = c(-1, 0.7, -0.3, 0.4,-0.5,0.1,-0.4,-0.9,0.7,0.3),
  y = c(0.8, 0.6, 1, 1.4,2,2.5,3,1.5,1.8,2.8),
  kolor = c("#d9c232", "#b11226", "#b11226", "#d9c232", "#b11226","#d9c232", "#b11226", "#d9c232","#b11226", "#d9c232")
)
pien_warstwa <- geom_polygon(data = pien,aes(x=x,y=y,fill = "#4d3417")) 
liscie_warstwa <- geom_polygon(data=trojkaty,aes(x=x,y=y,group=id,fill=kolor))
gwiazda_warstwa <- geom_point(data=gwiazda,aes(x=x,y=y),shape=8,size=14,stroke = 3,color="#d9c232")
bombki_warstwa <- geom_point(data=bombki,aes(x=x,y=y,color=kolor),size=7)

ggplot() +
  pien_warstwa +
  liscie_warstwa  +
  gwiazda_warstwa +
  bombki_warstwa + 
  scale_fill_identity() +
  scale_color_identity() +
  coord_fixed(ratio = 1,ylim = c(0, 4.4)) +
  theme_void() + 
  theme(plot.background = element_rect(fill="#132b47"))

  