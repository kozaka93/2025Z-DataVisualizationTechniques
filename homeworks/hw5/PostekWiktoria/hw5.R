library(ggplot2)
library(dplyr)
library(gganimate)

bg_color <- "#87CEFA"
snow_speed <- 0.01
blink_speed <- 12
n_frames <- 100
fps <- 15
set.seed(123)

tree_layers <- data.frame(
  x = c(0, -1.8, 1.8,  0, -3, 3,  0, -4, 4),
  y = c(10, 7, 7,  8, 4, 4,   5, 1, 1),
  group = rep(c("T", "M", "L"), each = 3))

y_gora <- runif(15, 7.2, 9.5)
y_srod <- runif(15, 4.2, 6.8)
y_dol  <- runif(15, 1.5, 3.8)

ornaments <- data.frame(
  y = c(y_gora, y_srod, y_dol),
  w = c((10-y_gora)*0.5, (8-y_srod)*0.65, (5-y_dol)*0.85))
ornaments$x <- runif(45, -ornaments$w + 0.2, ornaments$w - 0.2)
ornaments$id <- 1:45
ornaments$color <- sample(c("#FF3333", "#FFD700", "#FFFFFF", "#FF69B4"), 45, replace = TRUE)

full_data_anim <- data.frame()

for(f in 1:n_frames) {
   snow <- data.frame(
    x = runif(70, -5, 5),
    y = (runif(70, 0, 12) - (f * snow_speed)) %% 12,
    color = "white", alpha = 0.5, size = 1.2, frame = f)
  
  state <- (f + ornaments$id) %/% blink_speed %% 2
  bombs <- ornaments
  bombs$alpha <- ifelse(state == 0, 1, 0.2)
  bombs$size <- ifelse(state == 0, 4.5, 2.5)
  bombs$frame <- f
  
  klatka_data <- bind_rows(snow, bombs[, c("x", "y", "color", "alpha", "size", "frame")])
  full_data_anim <- rbind(full_data_anim, klatka_data)}


boxes <- data.frame(
  xmin = c(-3.5, 0.8, 3.2), xmax = c(-1.8, 2.8, 4.6),
  ymin = c(0.05, 0.05, 0.05), ymax = c(1.4, 1.7, 1.2),
  fill = c("#D64541", "#F5B041", "#2E86C1"))

boxes$mid_x <- (boxes$xmin + boxes$xmax) / 2
boxes$mid_y <- (boxes$ymin + boxes$ymax) / 2
ribbon_w <- 0.18

p <- ggplot() +
  geom_polygon(data = data.frame(x=c(-0.4, 0.4, 0.4, -0.4), y=c(1, 1, 0, 0)), aes(x=x, y=y), fill="#3E2723") +
  geom_polygon(data = tree_layers, aes(x=x, y=y, group=group), fill="#0D5302") +
  
  geom_rect(data = boxes, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=fill), color="black") +
  geom_rect(data = boxes, aes(xmin=mid_x - ribbon_w/2, xmax=mid_x + ribbon_w/2, ymin=ymin, ymax=ymax), fill="#FFF9C4") +
  geom_rect(data = boxes, aes(xmin=xmin, xmax=xmax, ymin=mid_y - ribbon_w/2, ymax=mid_y + ribbon_w/2), fill="#FFF9C4") +
  
  geom_point(aes(x=0, y=10.1), shape=8, size=10, color="#FFD700", stroke=2) +
  geom_point(data = full_data_anim, aes(x=x, y=y, color=color, alpha=alpha, size=size)) +
  
  scale_fill_identity() + scale_color_identity() + scale_alpha_identity() + scale_size_identity() +
  coord_cartesian(xlim = c(-5, 5), ylim = c(0, 11), expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = bg_color, color = NA),
    panel.background = element_rect(fill = bg_color, color = NA)
  ) +
  transition_manual(frame)


final_anim <- animate(p, nframes=n_frames, fps=fps, width=500, height=600, 
                      renderer=gifski_renderer(loop=TRUE), bg = bg_color)

anim_save("choinka_hw5.gif", animation = final_anim)
