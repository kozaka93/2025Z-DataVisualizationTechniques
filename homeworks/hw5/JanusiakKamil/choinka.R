#Biblioteki
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!requireNamespace("ggraph", quietly = TRUE)) {
  install.packages("ggraph")
}
library(ggraph)

if (!requireNamespace("tidygraph", quietly = TRUE)) {
  install.packages("tidygraph")
}
library(tidygraph)


#Dane
set.seed(123) #Dla innego łańcuchy się rozjadą
n_half <- 30
losowe <- rnorm(n_half)
data <- data.frame(val1 = c(losowe, -losowe))
n_points <- nrow(data)

#Przygotowanie
hc <- hclust(dist(data), method = "ward.D2")

#Dendrogram
graph <- as_tbl_graph(hc) %>%
  activate(nodes) %>%
  mutate(

    czy_bombka = (!node_is_root() & !leaf) | (leaf & (runif(n()) < 0.5)),
    #Losowy kolor
    kolor_bombki = sample(c("red", "gold", "#C0C0C0", "#00BFFF", "magenta"), n(), replace = TRUE)
  )

#Obliczenia wymiarów
srodek_x <- n_points / 2 + 0.5 
max_height <- max(hc$height)
wysokosc_pnia <- max_height * 0.15 

#Rysowanie
ggraph(graph, layout = 'dendrogram') + 
  theme_void() +
  theme(plot.background = element_rect(fill = "darkblue", color = NA)) +
  
  #Pieniek
  annotate("segment", x = srodek_x, xend = srodek_x, 
           y = 0, yend = -wysokosc_pnia, 
           color = "#8B4513", size = 25, lineend = "butt") +
  
  #Choinka
  geom_edge_diagonal(color = "forestgreen", width = 1.2) +
  
  #Łańcuchy
  
  annotate("curve", x = 0, xend = n_points - 2, 
           y = max_height * 0.2, yend = max_height * 0.2, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  annotate("curve", x = 0.5, xend = 57.5, 
           y = max_height * 0.32, yend = max_height * 0.32, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  annotate("curve", x = 1.5, xend = 56, 
           y = max_height * 0.5, yend = max_height * 0.5, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  annotate("curve", x = 3.5, xend = 52, 
           y = max_height * 0.65, yend = max_height * 0.65, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  annotate("curve", x = 7, xend = 47, 
           y = max_height * 0.76, yend = max_height * 0.76, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  annotate("curve", x = 15, xend = 38, 
           y = max_height * 0.92, yend = max_height * 0.92, 
           color = "gold", size = 1.2, alpha = 0.7, curvature = 0.3) +
  
  #Bombki
  geom_node_point(aes(filter = czy_bombka, color = kolor_bombki), size = 4) +
  
  #Gwiazda
  geom_node_text(aes(filter = node_is_root()), 
                 label = "★", color = "gold", size = 22, vjust = 0.35) +
  

  scale_color_identity() +
  
  coord_fixed(ratio = 6) +
  
  scale_y_continuous(expand = expansion(add = c(wysokosc_pnia, max_height * 0.15)))
  

