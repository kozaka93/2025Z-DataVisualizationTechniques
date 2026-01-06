library(ggplot2)
library(dplyr)
library(ggnewscale)

set.seed(65432)
ozdoby <- data.frame(
  y=runif(30,0.5,0.9),
  x= sample(-98:98,30),
  col=sample(1:5,30,replace = TRUE)
) %>% mutate(x = 0.01*x*abs((1/(2*y)-0.5)))


df <- data.frame(y = seq(0.5,0.95,by=0.02)) %>% mutate(width=(1/(2*y)-0.5))


choinka <- ggplot(df) +
  geom_rect(
    aes( xmin = -0.1, xmax = 0.1,
         ymin = 0.35, ymax = 0.5),
    fill = "#994d00", alpha = 0.9)+
  geom_segment(
    aes(x = -width, xend = width, y = y, yend = y, color=y),
    linewidth = 6,)+ 
  scale_color_gradient(low="#006622", high="#00b33c")+
  new_scale_color()+
  geom_point(data = ozdoby, aes(x, y,color=as.factor(col)), size =5)+
  scale_color_manual(values=c("#ff1a1a","#0000e6","#ff9933","yellow","#cc80ff"))+
  annotate("text",
           x = 0, y = 0.97,
           label = "★",
           size = 20,
           color = "gold")+
  coord_cartesian(ylim=c(0.35,1)) + theme_void() +
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "#cce6ff", color = NA),
    plot.background  = element_rect(fill = "#cce6ff", color = NA),
    legend.background  = element_rect(fill = "#cce6ff", color = NA))


ggsave("choinka.png",choinka,bg = "transparent", width = 10, height = 6, dpi = 600)

 
