library(ggplot2)
#aby narysować bombki:
install.packages('ggforce')
library(ggforce)
#aby narysować gwiazdę:
install.packages('ggstar')
library(ggstar)

x <- seq(0, 15, by = 0.2)
x1 <- sort(unique(c(-x,0,x)))
x2 <- x1[abs(x1) <= 12]
x3 <- x1[abs(x1) <= 10]
x4 <- x1[abs(x1) <= 5]

prettier_tree <- function(x){
  y = abs( x ^ (1/2) - 4) + 1
}

y1 <- prettier_tree(x1[ x1 >= 0 ])
y1 <- c(rev(y1 [2:length(y1)] ), y1)
y2 <- prettier_tree(x2[ x2 >= 0 ]) + 2
y2 <- c(rev(y2 [2:length(y2)] ), y2)
y3 <- prettier_tree(x3[ x3 >= 0 ]) + 4
y3 <- c(rev(y3 [2:length(y3)] ), y3) 
y4 <- prettier_tree(x4[ x4 >= 0 ]) + 5
y4 <- c(rev(y4 [2:length(y4)] ), y4)
triangles <- data.frame(x = c(x1,x2,x3,x4),
                        y = c(y1,y2,y3,y4),
                        id = rep(c('A', 'B', 'C', 'D'), 
                                 c(length(x1), length(x2), length(x3), length(x4))))

chunk <- data.frame(x = c(-1, 1, 1, -1),
                    y = c(0, 0, 1.2, 1.2),
                    id = 'E')
shapes <- NULL
shapes$x <- c(triangles$x, chunk$x)
shapes$y <- c(triangles$y, chunk$y)
shapes$id <- c(triangles$id, chunk$id)
shapes <- data.frame(shapes)

mycolors <- c('A' = "#054f2a",
              'B' = "#054f2a",
              'C' = "#054f2a",
              'D' = "#054f2a",
              'E' = "#4b3a2f")

tree <- ggplot() + 
  geom_polygon(data = shapes, 
               mapping = aes(x = x, y = y, group = id, fill = id), show.legend = F) +
  geom_circle(mapping = aes(x0 = 4, y0 = 4, r = 0.25), fill = '#ee5d6c', color = '#ee5d6c') +
  geom_circle(mapping = aes(x0 = -2, y0 = 4.4, r = 0.25), fill = '#ce4993', color = '#ce4993') +
  geom_circle(mapping = aes(x0 = -7, y0 = 1.5, r = 0.25), fill = '#6a0d83', color = '#6a0d83') +
  geom_circle(mapping = aes(x0 = 3, y0 = 2.5, r = 0.25), fill = '#eeaf61', color = '#eeaf61') +
  geom_circle(mapping = aes(x0 = -1.5, y0 = 7, r = 0.25), fill = '#ee5d6c', color = '#ee5d6c') +
  geom_circle(mapping = aes(x0 = 5, y0 = 6.2, r = 0.25), fill = '#eeaf61', color = '#eeaf61') +
  geom_circle(mapping = aes(x0 = 10, y0 = 1.5, r = 0.25), fill = '#6a0d83', color = '#6a0d83') +
  geom_circle(mapping = aes(x0 = -5, y0 = 6.5, r = 0.25), fill = '#ce4993', color = '#ce4993') +
  geom_circle(mapping = aes(x0 = 1, y0 = 8, r = 0.25), fill = '#6a0d83', color = '#6a0d83') +
  geom_circle(mapping = aes(x0 = -4, y0 = 2, r = 0.25), fill = '#90476d', color = '#90476d') +
  geom_circle(mapping = aes(x0 = 2, y0 = 5.2, r = 0.25), fill = '#90476d', color = '#90476d') +
  geom_star(aes(x = 0, y = 10), fill = '#eeaf61', color = '#eeaf61', size = 10, starshape = 'anise star4') +
  scale_fill_manual(values = mycolors) + 
  theme_void()
  
tree
