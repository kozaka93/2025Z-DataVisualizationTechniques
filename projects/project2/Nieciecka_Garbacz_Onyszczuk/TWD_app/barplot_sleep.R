sleep_barplot <- function(user, date, recomm){
  
  # Wczytanie ramek danych ----------------------------------------------------
  if (user == "Nina"){
    sleep <- read.csv("data/barplot/sleep/sleep_nina.csv")
  } else if (user == "Ania") {
    sleep <- read.csv("data/barplot/sleep/sleep_ania.csv")
  } else {
    sleep <- read.csv("data/barplot/sleep/sleep_karolina.csv")
  }
  
  # Zmiana typu danych --------------------------------------------------------
  sleep$date <- as.Date(sleep$date)
  
  # Ograniczenie ramki danych do określonej daty ------------------------------
  selected_sleep <- sleep[sleep$date >= date[[1]] & sleep$date <= date[[2]],]
  
  shiny::validate(need(nrow(selected_sleep) > 0, "Brak danych w wybranym zakresie."))
  
  # Wektor o większym zakresie do rysowania lini ------------------------------
  sleep_line <- c(min(selected_sleep$date)-1, selected_sleep$date, max(selected_sleep$date)+1)
  
  # Wykres --------------------------------------------------------------------
  sleep_plot <- plot_ly(
    selected_sleep, 
    x = ~date, 
    y = ~sleep_time/3600, 
    text = ~paste0('Ilość snu: ',
                   hour(seconds_to_period(selected_sleep$sleep_time)), ' h ',
                   minute(seconds_to_period(selected_sleep$sleep_time)), ' min'),
    type = 'bar',
    marker = list(color = 'rgba(78, 188, 226, 0.5)', line = list(color = '#4ebce2', width = 1)),
    textposition = 'none',
    hovertemplate = 'Data: %{x}<br>%{text}<extra></extra>') %>% 
    layout(
      paper_bgcolor = "#121212",
      plot_bgcolor = "#121212",
      xaxis = list(title = 'Data', 
                   range = c(min(sleep_line), max(sleep_line))),
      yaxis = list(title = 'Ilość snu [h]',
                   range = c(0,24),
                   tickmode = 'linear',
                   tick0 = 0,
                   dtick = 4,
                   zerolinecolor = "#333",
                   gridcolor = "#333"), 
      showlegend = FALSE,
      font = list(color = 'white'))
  
  if (recomm == TRUE){
    sleep_plot <- sleep_plot %>% 
      add_trace(
        x = sleep_line, 
        y = rep(9, length(sleep_line)), 
        type = 'scatter', 
        mode = 'lines',
        line = list(color = 'rgb(217, 3, 104)'),
        inherit = FALSE,
        hovertemplate = 'Górna granica dziennego zapotrzebowania snu: %{y} godzin<extra></extra>') %>% 
      add_trace(
        x = sleep_line, 
        y = rep(7, length(sleep_line)), 
        type = 'scatter', 
        mode = 'lines',
        line = list(color = 'rgb(217, 3, 104)'),
        fill = 'tonexty', 
        fillcolor = 'rgba(217, 3, 104, 0.5)',
        inherit = FALSE,
        hovertemplate = 'Dolna granica dziennego zapotrzebowania snu: %{y} godzin<extra></extra>')
  }
  sleep_plot
  
}