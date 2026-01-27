library(ggplot2)
library(tidyr)
library(dplyr)

df <- data.frame(
  
  r1 =  c(0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0),
  r2 =  c(0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0),
  r3 =  c(0,0,0,0,0,0,2,1,1,2,0,0,0,0,0,0),
  r4 =  c(0,0,0,0,0,0,1,1,1,4,0,0,0,0,0,0),
  r5 =  c(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
  r6 =  c(0,0,0,0,0,1,3,1,1,1,1,0,0,0,0,0),
  r7 =  c(0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0),
  r8 =  c(0,0,0,0,1,1,1,4,1,1,5,1,0,0,0,0),
  r9 =  c(0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
  r10 = c(0,0,0,5,1,1,1,1,1,1,1,1,1,0,0,0),
  r11 = c(0,0,0,1,1,1,1,1,4,1,1,3,1,0,0,0),
  r12 = c(0,0,1,1,1,3,1,1,1,1,5,1,1,1,0,0),
  r13 = c(0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0),
  r14 = c(0,1,4,1,1,1,5,1,4,1,1,1,3,1,1,0),
  r15 = c(0,1,1,1,3,1,1,1,1,1,1,1,1,1,5,0),
  r16 = c(0,0,0,0,0,0,0,6,6,0,0,0,0,0,0,0)
)

df <- as.data.frame(t(df))
df_2 <- df_t %>%
  mutate(y = row_number()) %>%
  pivot_longer(cols = -y, names_to = "x", values_to = "val") %>% 
  mutate(x = as.integer(sub("V", "", x)))                        


ggplot(df_2, aes(x = x, y = y, fill = factor(val))) +
  geom_tile() +
  coord_equal() +
  scale_y_reverse() +
  scale_fill_manual(
    values = c("0" = "white", "1" = "darkgreen", "2" = "gold", "3" = "red", "4" = "blue", "5" = "pink", "6" = "brown")
  ) +
  theme_void()+
  theme(legend.position = "none")

