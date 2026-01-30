library(plotly)
library(dplyr)
library(tidyr)

combined_plot <- function(df) {
  if(nrow(df) == 0) return(NULL)
  
  dens <- density(df$godzina, from = 0, to = 23, bw = 0.8)
  
  p_density <- plot_ly(x = dens$x, y = dens$y, type = 'scatter', mode = 'lines', hoverinfo = 'none', 
                       fill = 'tozeroy', fillcolor = 'rgba(78, 188, 226, 0.5)',
                       line = list(color = '#4ebce2'))
  
  plot_df <- df %>%
    group_by(dzien_tygodnia, godzina) %>%
    summarise(suma_min = sum(duration) / 60, .groups = 'drop') %>%
    complete(dzien_tygodnia, godzina = 0:23, fill = list(suma_min = 0)) %>%
    mutate(interval = as.numeric(cut(suma_min, breaks = c(-Inf, 0.01, 15, 30, 45, Inf), labels = FALSE)) - 1)
  
  m <- plot_df %>%
    select(dzien_tygodnia, godzina, interval) %>%
    pivot_wider(names_from = godzina, values_from = interval) %>%
    tibble::column_to_rownames("dzien_tygodnia") %>%
    as.matrix()
  
  m_text <- plot_df %>% 
    mutate(txt = paste0("Dzień: ", dzien_tygodnia, "<br>Godzina: ", godzina, ":00", "<br>Czas: ", round(suma_min, 1), " min")) %>% 
    select(dzien_tygodnia, godzina, txt) %>% 
    pivot_wider(names_from = godzina, values_from = txt) %>% 
    tibble::column_to_rownames("dzien_tygodnia") %>%
    as.matrix()
  
  color_scale <- list(
    list(0, "#1a1a1a"), list(0.2, "#1a1a1a"),
    list(0.2, "#0d3b66"), list(0.4, "#0d3b66"),
    list(0.4, "#1d70a2"), list(0.6, "#1d70a2"),
    list(0.6, "#4ebce2"), list(0.8, "#4ebce2"),
    list(0.8, "#8de4ff"), list(1, "#8de4ff")
  )
  
  p_heatmap <- plot_ly(x = 0:23, y = rownames(m), z = m, text = m_text, hoverinfo = "text",
                       type = "heatmap", colorscale = color_scale, showscale = TRUE,
                       colorbar = list(title = list(text = "Czas (min)", font = list(color = "white")),
                                       tickvals = c(0.4, 1.2, 2, 2.8, 3.6),
                                       ticktext = c("0", "0-15", "15-30", "30-45", "45-60"),
                                       tickfont = list(color = "white")))
  
  subplot(p_density, p_heatmap, nrows = 2, heights = c(0.2, 0.8), shareX = TRUE) %>%
    layout(
      paper_bgcolor = "#121212",
      plot_bgcolor = "#121212",
      showlegend = FALSE,
      
      xaxis = list(
        title = list(text = "Godzina", font = list(color = "white"), standoff = 20),
        dtick = 1,
        tickfont = list(color = "white"),
        tickangle = -90, 
        gridcolor = "#333",
        showticklabels = TRUE, 
        side = "bottom"      
      ),
      
      yaxis = list(
        title = list(text = "Gęstość", font = list(color = "white")),
        tickfont = list(color = "white"),
        gridcolor = "#333"
      ),
      
      yaxis2 = list(
        tickfont = list(color = "white"),
        gridcolor = "#333"
      ),
      margin = list(l = 100, r = 50, b = 100, t = 50)
    )
}