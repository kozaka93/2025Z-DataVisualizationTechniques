library(ggplot2)


set.seed(420)

n_igly <-2137
y_igly <-runif(n_igly, 0, 1)
max_x <- 1 -  y_igly
x_igly <- runif(n_igly, -max_x, max_x)



igly <- data.frame(
  typ = "igla" ,
  x = x_igly,
  y = y_igly
)  

n_ozdoby <- 7*7
y_b <- runif(n_ozdoby, 0.1, 0.95)
max_xb <- 1 - y_b
x_b <- runif(n_ozdoby, -max_xb, max_xb)
kategoria <- sample(c("a", "b", "c"), n_ozdoby, replace = TRUE)

ozdoby <- data.frame(
  typ = "ozdoba",
  x = x_b,
  y = y_b,
  kategoria = kategoria
)


gwiazda <- data.frame(
  typ = "gwiazdkaa",
  x = 0,
  y = 1.05
)

p <- ggplot() +
  geom_point(data = igly, aes(x, y), size = 0.7, alpha = 0.8, color = "darkgreen") +
  geom_point(data = ozdoby, aes(x, y, color = kategoria), size = 3, alpha = 0.95) +
  geom_point(data = gwiazda, aes(x, y), size = 6, shape = 8, color = "yellow") +
  annotate("rect", xmin = -0.12, xmax = 0.12, ymin = -0.15, ymax = 0.05,
           fill = "brown", color = NA) +
  coord_equal(xlim = c(-1.05, 1.05), ylim = c(-0.2, 1.15), expand = FALSE) +
  theme_void() +
  theme(legend.position = "bottom") 

ggsave("choinka.png", p, width = 6, height = 7, dpi = 200)
