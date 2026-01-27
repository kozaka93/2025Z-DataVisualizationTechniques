install.packages("gganimate")
install.packages("gifski")
library(dplyr)
library(ggplot2)
library(gganimate)

#dane
choinka <- data.frame(strona = 1,
                       x = 10:100)
choinka <- choinka %>% 
   mutate(y = -1/3*x + 100/3)
choinka2 <- choinka
choinka2$strona <- -1
choinka <- rbind(choinka, choinka2)
trzon <- data.frame(strona = 1,
                     x = 0:10,
                     y = 3)
trzon2 <- trzon
trzon2$strona <- -1
trzon <- rbind(trzon,trzon2)
ozdoby1 <- data.frame(kolor = rep(c("#ff88dc", "#ffcbdd", "#fce762", "#7c0b2b"), length.out = 17),
                      etap = 1,
                      x = c(80, 73, 64, 56, 47, 35, 29, 20, 16, 92, 59, 41, 45, 31, 23, 13, 11), 
                      y = c(5, -7, 2, 12, 3, 8, 19, 4, 22, -2, -5,-1, -15, -10, -21, -3, -25))
ozdoby2 <- ozdoby1 %>% 
   mutate(etap = 2,
          kolor = rep(c("#ffcbdd", "#fce762", "#7c0b2b", "#ff88dc"), length.out = 17) )
ozdoby3 <- ozdoby1 %>% 
   mutate(etap = 3,
          kolor = rep(c("#fce762", "#7c0b2b", "#ff88dc", "#ffcbdd"), length.out = 17))
ozdoby4 <- ozdoby1 %>% 
   mutate(etap = 4,
          kolor = rep(c( "#7c0b2b", "#ff88dc", "#ffcbdd", "#fce762"), length.out = 17))
ozdoby <- rbind(ozdoby1, ozdoby2, ozdoby3, ozdoby4)
#wykres
gif <- ggplot()+
   geom_col(data = trzon, aes(x = x,
                              y = ifelse(strona == 1 , y, -y)
                              ),
           fill = '#a1683a', color = '#a1683a')+
  geom_col(data = choinka, aes(x = x,
                                  y = ifelse(strona == 1, y, -y)
                                ),
            fill = '#228b22', color = '#228b22')+
   geom_point(aes(x = 102, y = 0), shape = "*", color = "gold", size = 20)+
   geom_point(data = ozdoby, aes(x=x, y=y, color = kolor, group = x), size = 5)+
   scale_color_identity()+
   xlim(0,110)+
   ylim(-50,50)+
   coord_flip()+
   theme_minimal()+
   theme(
     panel.background = element_rect(fill = "#020122", colour = "black"),
     plot.background = element_rect(fill = "#020122", colour = "black"),
     panel.grid = element_blank(),
     axis.text = element_blank(),
     axis.title = element_blank(),
     legend.position = "none")+
   transition_states(etap, transition_length = 1, state_length = 1)+
   enter_fade()+
   exit_fade()
animate(gif, fps=10, duration=4)
#anim_save("choinka.gif")
