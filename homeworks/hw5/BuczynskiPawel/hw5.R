library(dplyr)
library(ggplot2)
library(forcats)

N <- 18
lights <- tibble(
  x = unlist(sapply(1:N, function(n) (1:n-0.5)/n)),
  y = unlist(sapply(1:N, function(n) rep(n, n)))
) %>%
  mutate(x = x*4+10,
         y = y*0.9/N+0.05) %>%
  mutate(color = sample(c("r", "y", "b", "p"), n(), replace = TRUE)) %>%
  mutate(x = jitter(x, 100), y = jitter(y, 1))

stars <- tibble(
  x = unlist(sapply(1:N, function(n) (1:n-0.5)/n)),
  y = unlist(sapply(1:N, function(n) rep(n, n))),
) %>%
  mutate(x = x*13+5.5, y = y/N) %>%
  mutate(x = jitter(x, 100), y = jitter(y, 10)) %>%
  mutate(size = 10**runif(n(), -2, -1)) %>%
  filter(y < 1.05)

star_min <- 0.05
star_mid <- 0.06
star_max <- 0.09
star_contour <- tibble(x = seq(0, 24, length.out = 25),
                    y = c(rep(c(star_max, star_mid, star_min, star_mid), 6), star_max))
star_fill <- tibble(x = c(0, seq(0, 24, length.out = 25), 24),
       y = c(0, rep(c(star_max, star_mid, star_min, star_mid), 6), star_max, 0))
star_center <- tibble(x = seq(0, 20, length.out = 6),
                      y = rep(star_max, 6))
star_minor <- tibble(x = seq(2, 22, length.out = 6),
                      y = rep(star_min, 6))
star_color <- "#f80"

tree <- tibble(y = rep(seq(0.1, 1, length.out = 10), each = 2),
               x = 2+rep(c(1.5, -0.5), 10)/y/10)
tree <- rbind(tibble(y = 0, x = 0), tree, tibble(y = 1, x = 0))

window <- tibble(x = c(5, 5,
                       seq(5.731, 8.5, length.out = 50),
                       seq(8.5, 11.269, length.out = 50),
                       11.8, 11.8),
                 y = c(0, 1.05,
                       0.2/cos((x[3:52]-11)*pi/12),
                       0.2/cos((x[53:102]-6)*pi/12),
                       1.05, 0))

tibble(name = fct_relevel(c("ceilL", "wallL", "trunk", "wallR", "ceilR"),
                          c("ceilL", "wallL", "trunk", "wallR", "ceilR")),
       value = c(5, 6.8, 0.4, 6.8, 5)) %>%
  ggplot() +
  geom_col(aes(x = cumsum(value) - value/2, y = 1.05, group = name, fill = name, width = value)) +
  scale_fill_manual(values = c("#ddd", "#003", "#531", "#003", "#ddd")) +
  geom_point(data = stars, aes(x = x, y = y), color = "white", size = 0.1) +
  geom_polygon(data = window, aes(x = x, y = y), fill = "#bbb") +
  geom_polygon(data = window %>% mutate(x = 24-x), aes(x = x, y = y), fill = "#aaa") +
  geom_polygon(data = tree, aes(x = 12+x, y = y), fill = "#060") +
  geom_polygon(data = tree, aes(x = 12-x, y = y), fill = "#060") +
  geom_segment(data = tibble(y = seq(0.075, 0.975, length.out = N+1)),
               aes(x = 10, xend = 14, y = y, yend = y),
               linetype = "dashed",
               linewidth = 0.5,
               color = "#ccc") +
  geom_point(data = lights,
             aes(x = x, y = y, color = color),
             size = 1) +
  geom_point(data = lights,
             aes(x = x, y = y),
             color = "white",
             alpha = 0.7,
             size = 0.2) +
  scale_color_manual(values = c("#f33", "#ec0", "#0af", "#d4f")) +
  geom_polygon(data = star_fill, aes(x = x, y = y), fill = "#fd0") +
  geom_line(data = star_contour,
            aes(x = x, y = y),
            color = star_color,
            linewidth = 0.3) +
  geom_segment(data = star_center,
               aes(x = x, xend = x, y = 0, yend = y),
               color = star_color,
               linewidth = 0.3) +
  geom_segment(data = star_minor,
               aes(x = x, xend = x, y = 0, yend = y),
               color = star_color,
               linewidth = 0.3) +
  coord_polar(start = 0) +
  theme_void() +
  theme(legend.position = "none")
