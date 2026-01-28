library(dplyr)
library(treemapify)
library(stringi)
library(RColorBrewer)
library(plotly)


make_treemap<-function(df){
  
  data<-df %>%
    group_by(cat, data.app) %>%
    summarise(
      duration_sum = sum(duration, na.rm = TRUE), .groups = "drop")
  
  cats<-data %>%
    group_by(cat) %>% 
    summarise(duration_sum=sum(duration_sum),.groups = "drop") %>% 
    mutate(
      labels=cat,
      parents=""
    )
  apps<-data %>%
    group_by(cat) %>%
    mutate(
      cat_sum = sum(duration_sum),
      share = duration_sum / cat_sum,
      labels = data.app,
      parents = cat
    ) %>%
    ungroup() %>%
    filter(share >= 0.1) %>%
    select(labels, parents, duration_sum)
  
  treemap_data<- bind_rows(
    cats %>% select(labels, parents, duration_sum),
    apps %>% select(labels, parents, duration_sum)
  )
  treemap_data <- treemap_data %>%
    mutate(duration_h = duration_sum / 3600)
  
  color_scale <- list(
    list(0.0, "#0d3b66"),
    list(0.25, "#1d70a2"),
    list(0.5, "#4ebce2"),
    list(0.75, "#8de4ff"),
    list(1.0, "#b3eeff")
  )
  
  
  p<-plot_ly(
    data=treemap_data,
    labels=~labels,
    parents=~parents,
    values=~duration_h,
    type="treemap",
    hovertemplate = paste(
      "<b>%{label}</b><br>",
      "czas: %{value:.2f} h<br>",
      "procent z kategorii: %{percentParent:.1%}",
      "<extra></extra>"),
    marker = list(
      colors = ~duration_h,
      colorscale=color_scale,
      showscale = TRUE,
      colorbar = list(
        title = list(
          text = "Czas (h):", 
          font = list(color = "white", size = 14)
        ),
        tickfont = list(color = "white"),
        thickness = 20,
        len = 0.8
      ))
  ) %>%
    layout(
      paper_bgcolor = "#121212",
      plot_bgcolor = "#121212",
      font = list(color = "white", size = 14),
      margin = list(t = 50, l = 25, r = 25, b = 25)
    )
  return(p)
}