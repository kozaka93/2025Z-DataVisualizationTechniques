library(plotly)
library(lubridate)

screentime_barplot <- function(user, date, limit, device){
  
  if (user == "Nina"){
    screentime <- read.csv("data/barplot/screentime/screentime_nina.csv")
  }else if (user == "Ania"){
    screentime <- read.csv("data/barplot/screentime/screentime_ania.csv")
  } else {
    screentime <- read.csv("data/barplot/screentime/screentime_karolina.csv")
  }

  # Zmiana typu danych --------------------------------------------------------
  screentime$date <- as.Date(screentime$date)
  
  # Ograniczenie ramki danych do określonej daty ------------------------------
  selected_screentime <- screentime[screentime$date >= date[[1]] & screentime$date <= date[[2]],]
  
  shiny::validate(need(nrow(selected_screentime) > 0, "Brak danych w wybranym zakresie."))
  
  # Wektor o większym zakresie do rysowania lini ------------------------------
  screentime_line <- c(min(selected_screentime$date)-1, selected_screentime$date, max(selected_screentime$date)+1)
  
  # Wykres --------------------------------------------------------------------
  screentime_plot <- plot_ly(
    selected_screentime, 
    x = ~date, 
    y = ~.data[[device]]/3600,
    type = 'bar', 
    marker = list(color = 'rgba(78, 188, 226, 0.5)', line = list(color = '#4ebce2', width = 1)),
    textposition = 'none',
    text = ~as.character(paste0('Ilość screentime: ',
                   hour(seconds_to_period(.data[[device]])), ' h ',
                   minute(seconds_to_period(.data[[device]])), ' min')),
    hovertemplate = 'Data: %{x|%d %b %Y}<br>%{text}<extra></extra>') %>% 
    layout(
      paper_bgcolor = "#121212",
      plot_bgcolor = "#121212",
      xaxis = list(title = 'Data', 
                   range = c(min(screentime_line), max(screentime_line))),
      yaxis = list(title = 'Screentime [h]', 
                   range = c(0,24),
                   tickmode = 'linear',
                   tick0 = 0,
                   dtick = 4,
                   zerolinecolor = "#333",
                   gridcolor = "#333"), 
      showlegend = FALSE,
      font = list(color = 'white'))
  
  if (limit == TRUE){
    if (device == "phone_duration"){
      screentime_plot <- screentime_plot %>% 
        add_trace(
          x = screentime_line, 
          y = rep(2, length(screentime_line)), 
          type = 'scatter', 
          mode = 'lines',
          line = list(color = 'rgb(217, 3, 104)'),
          inherit = FALSE,
          hovertemplate = 'Cel: %{y} godziny<extra></extra>')
    } else if (device == "laptop_duration") {
      screentime_plot <- screentime_plot %>% 
        add_trace(
          x = screentime_line, 
          y = rep(4, length(screentime_line)), 
          type = 'scatter', 
          mode = 'lines',
          line = list(color = 'rgb(217, 3, 104)'),
          inherit = FALSE,
          hovertemplate = 'Cel: %{y} godziny<extra></extra>')
    } else {
      screentime_plot <- screentime_plot %>% 
        add_trace(
          x = screentime_line, 
          y = rep(6, length(screentime_line)), 
          type = 'scatter', 
          mode = 'lines',
          line = list(color = 'rgb(217, 3, 104)'),
          inherit = FALSE,
          hovertemplate = 'Cel: %{y} godzin<extra></extra>')
    }
  }
  
  screentime_plot
}
