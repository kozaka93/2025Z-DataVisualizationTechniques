library(ggplot2)
library(tidyr)
library(dplyr)

df <- as.data.frame(rbind(
            c(rep(2,11)),
            c(rep(2,11)),
            c(rep(2,5),4,rep(2,5)),
            c(rep(2,4),rep(4,3),rep(2,4)),
            c(rep(2,4),3,4,3,rep(2,4)),
            c(rep(2,3),rep(3,5),rep(2,3)),
            c(rep(2,2),3,5,rep(3,3),7,3,rep(2,2)),
            c(2,rep(3,4),6,rep(3,4),2),
            c(rep(2,4),rep(3,3),rep(2,4)),
            c(rep(2,3),rep(3,5),rep(2,3)),
            c(rep(2,2),6,3,7,rep(3,2),5,3,rep(2,2)),
            c(2,rep(3,9),2),
            c(rep(2,4),3,6,3,rep(2,4)),
            c(rep(2,3),rep(3,5),rep(2,3)),
            c(rep(2,2),rep(3,2),5,rep(3,2),7,3,rep(2,2)),
            c(2,rep(3,9),2),
            c(rep(2,4),rep(1,3),rep(2,4)),
            c(rep(2,4),rep(1,3),rep(2,4)),
            c(rep(2,4),rep(1,3),rep(2,4)),
            c(rep(0,4),rep(1,3),rep(0,4)),
            c(rep(0,4),rep(1,3),rep(0,4)),
            c(rep(0,11)),
            c(rep(0,11)),
            c(rep(0,11))
            ))

df <- df %>% 
  mutate(y = 25 - row_number())  %>% 
  pivot_longer(-y, names_to = "x", values_to = "wartosc") %>% 
  select(-x) %>% 
  mutate(x=rep(1:11,24))

ggplot(df, aes(x = x, y = y, fill = factor(wartosc))) +
  geom_tile() +
  scale_fill_manual(values = c(
    "0" = "#FAFAFA",
    "1" = "brown",
    "2" = "blue",
    "3" = "green",
    "4" = "yellow",
    "5" = "red",
    "6" = "orange",
    "7" = "lightblue"
  )) +
  coord_fixed() +                         
  theme_void() +
  theme(legend.position = "none")
