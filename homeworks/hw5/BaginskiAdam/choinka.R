library(igraph)
library(ggraph)
library(ggplot2)

# Połączenia w grafie
edges <- data.frame(
  from = c(1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 
           8,8, 9,9, 10,10, 11,11, 12,12, 13,13, 14,14, 15,15),
  to   = c(2,3, 4,5, 6,7, 8,9, 10,11, 12,13, 14,15, 
           16,17, 18,19, 20,21, 22,23, 24,25, 26,27, 28,29, 30,31))

g <- graph_from_data_frame(edges)

# Ułożenie węzłów
x_coords <- c(
  0,
  -0.4, 0.4,
  -0.8, -0.3, 0.3, 0.8,
  seq(-1.5, 1.5, length.out = 8),
  seq(-2.2, 2.2, length.out = 16))

y_coords <- c(5, 4, 4, 3, 3, 3, 3, rep(2, 8), rep(1, 16))

ggraph(g, layout = "manual", x = x_coords, y = y_coords) +
  annotate("rect", xmin = -0.25, xmax = 0.25, ymin = 0, ymax = 0.9, fill = "#5D4037") +
  
  geom_edge_diagonal(colour = "darkgreen", edge_width = 1.5) +
  
  geom_node_point(
    aes(colour = as.factor(sample(1:5, 31, replace = TRUE))), 
    size = 5, 
    show.legend = FALSE) +
  
  geom_node_text(data = function(node) node[node$name == "1", ], label = "★", 
                 color = "gold", size = 18, vjust = 0.4) +
  
  scale_color_manual(values = c("#E41A1C", "#377EB8", "#C0C0C0", "#FF7F00", "#FFFF00")) +
  theme_void() +
  labs(title = "Wesołych świąt!") +
  theme(plot.title = element_text(hjust = 0.5, color = "darkgreen", face = "bold", size = 18))
