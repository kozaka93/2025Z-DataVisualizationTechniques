library(plotly)
library(dplyr)

stozek <- function(h_start, h_wys, r_podst, r_gora, n = 1000) {
  alfa <- runif(n, min = 0, max = 2 * pi)
  v <- runif(n, min = 0, max = 1)
  r <- r_podst + v * (r_gora - r_podst)
  
  x <- r * cos(alfa)
  y <- r * sin(alfa)
  z <- h_start + v * h_wys 
  
  data.frame(x = x, y = y, z = z, c= z+1)
}

pkt1 <- stozek(0, 10, 12, 3, 2000) %>%
  mutate(layer_id = "Dół")

pkt2 <- stozek(7, 9, 9, 2, 1500) %>%
  mutate(layer_id = "Środek")

pkt3 <- stozek(13, 8, 6, 0, 1000) %>%
  mutate(layer_id = "Szczyt")

df_choinka <- bind_rows(pkt1, pkt2, pkt3)

df_gwiazda <- df_choinka %>% filter(z == max(z))

plot_ly() %>%
  add_trace(data = df_choinka, 
            x = ~x, y = ~y, z = ~z,
            type = "scatter3d",
            mode = "markers",
            color = ~c, 
            colors = c("#003300", "#67fc0a"), 
            marker = list(
              size = 1.5,       
              opacity = 0.8 ,
              colorbar = list(
                title = "Parametr c", 
                titleside = "top",  
                len = 0.6           
              )
            ),
            text = ~layer_id, 
            hoverinfo = "text+c") %>% 
  add_trace(
    data = df_gwiazda,
    x = df_gwiazda$x, 
    y = df_gwiazda$y, 
    z = df_gwiazda$z,
    type = "scatter3d",
    mode = "markers",
    marker = list(
      symbol = "diamond", 
      size = 10,          
      color = "gold",     
      line = list(color = "orange", width = 1),
      showscale=FALSE
    ),
    text = "Gwiazda", 
    hoverinfo = "text+z"
  ) %>% 
  layout(
    title = "Świąteczna choinka",
    showlegend = FALSE,
    scene = list(
      
      xaxis = list(visible = FALSE, title = ""),
      yaxis = list(visible = FALSE, title = ""),
      zaxis = list(visible = FALSE, title = ""),
      aspectmode = "data" 
    ),
    paper_bgcolor = "#ffffff" 
  )


