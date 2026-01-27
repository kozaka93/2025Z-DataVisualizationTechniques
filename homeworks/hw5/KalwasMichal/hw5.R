library(ggplot2)
library(dplyr)

set.seed(2115)

create_layer <- function(n,y_min,y_max,width){
  y <- runif(n,min = y_min,max=y_max)
  x <- rnorm(n, mean=0 ,sd=(y_max-y)*width)
  return(data.frame(x=x,y=y,type="igly"))
}
layer1 <- create_layer(2000,6.5,10,0.25)
layer2 <- create_layer(3000,3.5,6.5,0.35)
layer3 <- create_layer(4000,0.5,3.5,0.45)

tree <- bind_rows(layer1,layer2,layer3) %>% 
  mutate(type= replace(type,sample(n(),300),"bombki"))



bottom <- data.frame(
  x=runif(1000,-0.5,0.5),
  y=runif(1000,-1.5,0.5),
  type="pien"
)

tree<- bind_rows(tree,bottom)


tree %>%
  ggplot(aes(x,y,color=type,size=type))+
  geom_point()+
  scale_color_manual(values = c(
    "igly" = "darkgreen",
    "pien"="brown",
    "bombki"="red"
  ))+
  scale_size_manual(values = c(
    "igly" = 1,
    "pien"=1,
    "bombki"=3
  ))+
  theme_void()+
  theme(
    plot.background = element_rect(fill = "#051e3e", color = NA),
    legend.position = "none",
  )+
  annotate("text",x=0,y=10.5,label = "★",color="gold",size=10)

