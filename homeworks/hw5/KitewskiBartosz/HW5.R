library(ggplot2)
library(dplyr)
library(gganimate)
library(sf)
library(gifski)

tree_coords <- list(
  matrix(
    c(
      -4, 0,
      -2.45, 2,
      -3.33, 2, 
      -1.5, 4,
      -2.56, 4,
      -.75, 6,
      -1.7, 6,
      0, 8,
      1.7, 6,
      .75, 6,
      2.56, 4,
      1.5, 4,
      3.33, 2,
      2.45, 2,
      4, 0,
      -4, 0
    ), ncol = 2, byrow = TRUE
  )
)

cone_coords <- list(
  matrix(
    c(
      -1, 0,
      1, 0,
      1.5, -1,
      -1.5, -1,
      -1, 0
    ), ncol = 2, byrow = TRUE
  )
)

shade_coords <- list(
  matrix(
    c(
      -4, 0,
      -2.45, 2,
      -3.33, 2, 
      -1.5, 4,
      -2.56, 4,
      -.75, 6,
      -1.7, 6,
      0, 8,
      1.3, 6,
      .22, 6.2,
      1.93, 4,
      .4, 4.4,
      2.68, 2,
      .2, 2.7,
      3, 0,
      -4, 0
    ), ncol = 2, byrow = TRUE
  )
)

n <- 200
tree <- st_polygon(tree_coords)
cone <- st_polygon(cone_coords)
shade <- st_polygon(shade_coords)
points <- st_sample(tree, n)
atrybuty <- data.frame(
  kolor = sample(c("red", "blue","orange", "purple"), n, replace=TRUE),
  size = sample(2:4, n, replace = TRUE),
  shape = sample(c(21, 19, 8), n, TRUE)
) %>% mutate(
  time = case_when(
    kolor == "red" ~ 1,
    kolor == "blue" ~ 2,
    kolor == "orange" ~ 3,
    .default = 4
  )
)

points_sf <- st_sf(atrybuty, geometry=points)


t <- ggplot() +
  geom_sf(aes(), data=tree, fill="#213c18")+
  geom_sf(aes(), data=cone, fill="saddlebrown")+
  geom_sf(data = shade, fill = "forestgreen")+
  geom_sf(data=points_sf, color = atrybuty$kolor, size = atrybuty$size, shape = atrybuty$shape)+
  geom_point(aes(x=0,y=8), shape=24, fill="yellow", size=7, color="yellow")+
  geom_point(aes(x=0,y=8), shape=25, fill="yellow", size=7, color="yellow")+
  theme_void()+
  coord_sf(xlim = c(-5,5), ylim = c(-2, 10))+
  annotate("text",x=0, y=9.5, label = "Wesołych Świąt\nBożego Narodzenia!", size = 4, color="white")+
  theme(
    plot.background = element_rect(fill="black")
  )
t

animated_tree <- t +
  transition_time(time)+
  ease_aes("linear")


animate(
  animated_tree,
  renderer = gifski_renderer("animated_tree.gif"),
  duration = 6,
  bg = "black"
)


