library(ggplot2)

set.seed(123)

wariancje <- rev(c(0.4, 0.6, 0.8, 1.2, 1.6, 2.2))

dane_violin <- do.call(rbind, lapply(1:6, function(i) {
  data.frame(
    warstwa = factor(i, levels = 1:6),
    x = rnorm(500, 0, wariancje[i])
  )
}))

liczba_bombek <- c(7, 6, 4, 3, 2, 1)

bombki <- do.call(rbind, lapply(1:6, function(i) {
  
  n_b <- liczba_bombek[i]
  
  d <- density(dane_violin$x[dane_violin$warstwa == i], n = 512)
  
  W <- quantile(abs(d$x[d$y > 0.4 * max(d$y)]), 0.9)
  
  x <- if (n_b == 1) 0 else seq(-W, W, length.out = n_b)
  
  data.frame(
    y = factor(i, levels = 1:6),
    x = x,
    kolor = sample(
      c("red", "gold", "deepskyblue", "orange", "pink"),
      n_b,
      replace = TRUE
    )
  )
}))

#gwiazdka
n <- 5
katy <- seq(0, 2*pi, length.out = 2*n + 1)
R <- 0.3
r <- 0.1

promien <- rep(c(R, r), n)
promien <- c(promien, R)

gwiazda <- data.frame(
  x = promien * cos(katy),
  y = promien * sin(katy) + 6.5
)

#choinka
obraz <- ggplot(dane_violin, aes(x = x, y = warstwa, fill = warstwa)) +
  
  geom_violin(
    scale = "width",
    trim = TRUE,
    color = "darkgreen"
  ) +
  
  geom_point(
    data = bombki,
    aes(x = x, y = y, color = kolor),
    size = 3,
    inherit.aes = FALSE
  ) +
  
  geom_polygon(
    data = gwiazda,
    aes(x = x, y = y),
    fill = "gold",
    color = "orange",
    linewidth = 1,
    inherit.aes = FALSE
  ) +
  
  scale_fill_manual(values = rev(c(
    "#4FB3A2",
    "#2A8C82",
    "#1B6F7A",
    "#145C6E",
    "#0F4C5C",
    "#0B3C59"
  ))) +
  
  scale_color_identity() +
  
  scale_y_discrete(expand = expansion(add = c(0.3, 1.2))) +
  
  coord_cartesian(xlim = c(-5, 5)) +
  
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#4b72c2", color = NA)
  )
obraz
ggsave("choinka.png", plot = obraz,width = 8, height = 9 )

