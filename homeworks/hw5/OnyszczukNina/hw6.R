## Biblioteki -----------------------------------------------------------------
library(ggplot2)
library(gganimate)
library(gifski)

## Seed -----------------------------------------------------------------------
set.seed(67)

## Zbiór danych ---------------------------------------------------------------
# Dane do choinki -------------------------------------------------------------
n <- 25000    # ilość punktów
bins <- 250   # ilość przedziałów

breaks <- seq(0, 1, length.out = bins + 1)        # granice przedziałów
mid <- (breaks[-1] + breaks[-length(breaks)])/2   # środki przedziałów

p <- rev(mid)/sum(mid)  # prawdopodobieństwo

b <- sample.int(bins, size = n, replace = TRUE, prob = p)
y <- runif(n, min = breaks[b],  max = breaks[b+1])

df <- data.frame(y)

# Pole dla bombek -------------------------------------------------------------
adj = 0.25
d <- density(df$y, from = 0, to = 1, n = 500, adjust = adj)

max_width <- 0.45   # połowa szerokości
y_width <- function(val) {
  dens <- approx(d$x, d$y, xout = val, rule = 2)  # interpolacja
  (dens$y / max(d$y)) * max_width
}

# Bombki ----------------------------------------------------------------------
n_balls <- 200

bb <- sample.int(bins, size = n_balls, replace = TRUE, prob = p)
y_balls <- runif(n_balls, min = breaks[bb], max = breaks[bb+1])

w <- y_width(y_balls)
x_balls <- runif(n_balls, min = -w, max = w)

pal <- c(
  'Red' = '#8D1502',
  'Yellow' = '#B78C57',
  'Creme' = '#F5E5CF'
)

balls <- data.frame(x_balls, 
                    y_balls,
                    col_name = factor(
                      sample(names(pal), n_balls, replace = TRUE),
                      levels = c('Red', 'Yellow', 'Creme')
                    ))
balls$col <- pal[as.character(balls$col_name)]

star <- data.frame(x_star = 0, y_star = 1)

## Wykres ---------------------------------------------------------------------
p <- ggplot(df, aes(x = 0, y = y))+
  geom_violin(fill = '#304113',
              color = NA,
              adjust = adj)+
  geom_point(data = star,
             aes(x = x_star, y = y_star),
             color = '#B78C57',
             shape = 8,
             size = 12,
             stroke = 2)+
  geom_point(data = balls,
             aes(x = x_balls, y = y_balls, color = col, shape = col_name),
             size = 3)+
  xlim(-0.55,0.55)+
  ylim(0.05, 1)+
  scale_color_identity()+
  theme_void()+
  theme(legend.position = 'none')+
  transition_states(col_name)+
  enter_fade()+
  exit_fade()

gif <- animate(
  p,
  duration = 6,
  renderer = gifski_renderer()
)

anim_save('tree.gif', gif)
  
  