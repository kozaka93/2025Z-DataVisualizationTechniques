library(ggplot2)
library(tidyr)
library(gifski)

dol_x1 <- seq(0, 35, length.out = 100)
gora_x1 <- seq(12, 22, length.out = 100)

dol_x2 <- seq(5, 30, length.out = 100)
gora_x2 <- seq(15, 20, length.out = 100)

dol_x3<- seq(10, 25, length.out = 100)

xp<-seq(15,19,length.out=100)

s_x<-runif(100,0,35)
s_y<-runif(100,0,14)

df <- data.frame(
  #dolna czesc choinki
  x0 = dol_x1,
  y0 = 2,
  x1 = gora_x1,
  y1 = 7,
  #srodkowa czesc choinki
  x01=dol_x2,
  y01=7,
  x11=gora_x2,
  y11=11,
  #gorna czesc choinki
  x02=dol_x3,
  y02=11,
  x12=17.5,
  y12=14,
  #pieniek
  pieniek_x=xp,
  pieniek_dol_y=1,
  pieniek_gora_y=2
)
df_snieg<-data.frame(
  #snieg
  snieg_x=s_x,
  snieg_y=s_y,
    t=1:100
)
  


p<-ggplot() +
  geom_segment(data=df,aes(x = x0, y = y0, xend = x1, yend = y1),
               color = "darkgreen",linewidth = 0.8) +
  geom_segment(data=df,aes(x = x01, y = y01, xend = x11, yend = y11),
               color = "darkgreen",linewidth =0.8 ) +
  geom_segment(data=df,aes(x = x02, y = y02, xend = x12, yend = y12),
               color = "darkgreen",linewidth = 0.8) +
  geom_segment(data=df,aes(x = pieniek_x, y = pieniek_dol_y, xend = pieniek_x, yend =pieniek_gora_y),
               color = "brown")+
  geom_text(aes(x = 17.5, y = 14.4), label ="★", size = 18, color = "gold")+
  geom_point(data=df_snieg,aes(x=snieg_x,snieg_y),shape=8,size=4,color="white")+
  transition_time(t) +
  shadow_wake(wake_length = 0.3)+
  theme(panel.background = element_rect(fill = "#b8d5e6"),
        panel.grid = element_blank(),       
        axis.line = element_blank(),         
        axis.ticks = element_blank(),        
        axis.text = element_blank(),         
        axis.title = element_blank()         
  )
ani<-animate(
  p,
  renderer = gifski_renderer(),
  width = 1200,
  height = 1200,
  nframes = 100,
  fps = 10,
  res = 150
)

anim_save("choinka.gif", animation = ani)
