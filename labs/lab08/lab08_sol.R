##########################################
###    TECHNIKI WIZUALIZACJI DANYCH    ###
###          LABORATORIUM  8           ###
##########################################


# plotly ------------------------------------------------------------------

## https://plotly.com/r
## https://github.com/plotly/plotly.R/issues
library(plotly)
library(dplyr)


x <- c("a", "b", "c")
y <- c(1, 3, 2)

# ~ matplotlib / ggplot2
fig <- plot_ly() %>% 
  add_lines(x = x, y = y) %>% 
  layout(
    title = "sample figure", 
    xaxis = list(title = 'x'), 
    yaxis = list(title = 'y'), 
    plot_bgcolor = "#c7daec"
  ) 

# obiekt jak w ggplot2
str(fig$x) 

fig

plot_ly(x = x, y = y) # No trace type specified

plot_ly(x = x, y = y, type = 'type')

plot_ly(x = x, y = y, type = 'bar')

plot_ly(x = x, y = y, type = 'scatter') # No scatter mode specified

## https://plotly.com/r/reference/#scatter-mode
plot_ly(x = x, y = y, type = 'scatter', mode = 'lines')

# wykres statyczny
fig <- plot_ly() %>%
  add_trace(x = x, y = y, type = "bar")
config(fig, staticPlot = TRUE)

?config

# wykres bez zoom i przycisków
fig %>% 
  layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE)) %>%
  config(displayModeBar = FALSE)



# ~ seaborn / ggplot2
df_raw <- read.csv("https://raw.githubusercontent.com/mini-pw/2021Z-DataVisualizationTechniques/master/labs/data/Pokemon.csv")[,-1]

df <- df_raw %>%
  filter(Type.1 %in% c("Fire", "Water", "Grass", "Poison", "Electric")) %>%
  mutate(Type.1 = factor(Type.1, levels = c("Fire", "Water", "Grass", "Poison",  "Electric")))

plot_ly(
  data = df, 
  x = ~Attack, 
  y = ~Defense, 
  color = ~Type.1,
  colors = "Set1"
)

## 3D
plot_ly(
  data = df, 
  x = ~Attack, 
  y = ~Defense, 
  z = ~HP,
  color = ~Type.1, 
  colors = "Set1",
  type = "scatter3d",
  mode = "markers"
)

plot_ly(
  data = df, 
  x = ~Attack, 
  y = ~Defense, 
  z = ~Speed,
  color = ~Type.1, 
  colors = "Set1",
  symbol = ~Type.1, 
  symbols = c('circle', 'cross', 'diamond', 'square', 'circle'),
  marker = list(size = 5, line = list(color = 'black', width = 1)),
  type = "scatter3d",
  mode = "markers"
)

## tooltip https://plotly.com/r/hover-text-and-formatting
## legend https://plotly.com/r/legend
plot_ly(
  data = df, 
  x = ~Attack, 
  y = ~Defense, 
  color = ~Legendary,
  colors = c("black", "red"),
  text = paste0("Name: ", df$Name, "<br>Stage: ", df$Stage),
  hoverinfo = 'x+y+text'
  # hovertemplate = paste('<b>%{text}</b><br><b>X</b>: %{x}<br><b>Y</b>: %{y} <extra>tooltip</extra>')
) %>% 
  layout(
    legend = list(
      x = 0.1, y = 0.9, 
      title = list(text = "Legendary"), 
      bgcolor = "#E2E2E2"
    )
  )


# Zadanie 1 ---------------------------------------------------------------
# Przygotuj rozkłady 2-3 atrybutów dla wybranych pokemonów. Zadbaj o czytelność
# wykresów. Typy wykresów dostępne tutaj: https://plotly.com/r/statistical-charts


# Rozkład HP dla kilku typów (boxplot)
plot_ly(
  data = df,
  x = ~Type.1,
  y = ~HP,
  type = "box"
) %>%
  layout(
    title = "Rozkład HP w zależności od typu pokemona",
    xaxis = list(title = "Typ", tickangle = -30),
    yaxis = list(title = "HP")
  )


## dropdown https://plotly.com/r/dropdowns
## buttons https://plotly.com/r/custom-buttons
plot_ly(
  data = df, 
  x = ~Type.1, 
  y = ~Attack,
  type = "box"
) %>% layout(
  title = "Attack distribution",
  xaxis = list(title = "TYPE"),
  yaxis = list(range = c(0, 140)),
  updatemenus = list(
    list(
      x = 1, y = 1,
      buttons = list(
        list(method = "restyle",
             args = list("type", "box"),
             label = "Boxplot"),
        list(method = "restyle",
             args = list("type", "violin"),
             label = "Violinplot")
      ))
  ))


## animation https://plotly.com/r/animations
plot_ly(x = ~rnorm(50), type = "histogram")

X <- data.frame()
for (m in seq(-5, 5, 1)) {
  new_X <- data.frame(
    value = rnorm(100, m), 
    mean = m
  )
  X <- rbind(X, new_X)
}

fig <- plot_ly(data = X, x = ~value, frame = ~mean, type = "histogram")
fig

fig %>% 
  animation_opts(10) %>%
  animation_button(x = 0.05, y = 0.05) %>%
  animation_slider(currentvalue = list(prefix = "MEAN: ", font = list(color="red")))



# Zadanie 2 ---------------------------------------------------------------
# Przygotuj animację dla wybranego wykresu z Zadania 1 po zmiennej Stage (lub Type/
# nowej stworzonej).

plot_ly(
  data = df,
  x = ~Type.1,
  y = ~HP,
  frame = ~Stage,
  type = "box"
) %>%
  layout(
    title = "Rozkład HP w zależności od typu pokemona",
    xaxis = list(title = "Typ", tickangle = -30),
    yaxis = list(title = "HP")
  ) %>% 
  animation_slider(currentvalue = list(prefix = "Stage: "))



## plotly + maps -----------------------------------------------------------
## https://plotly.com/r/maps/

# prosta mapa świata
df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv")

fig <- plot_ly(df, type='choropleth', 
               locations=df$CODE, 
               z=df$GDP..BILLIONS., 
               text=df$COUNTRY, 
               colorscale="Ice")

fig


# wykres z dostosowanymi parametrami + hover
df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv")
df$hover <- with(df, paste(state, '<br>', "Beef", beef, "Dairy", dairy, "<br>",
                           "Fruits", total.fruits, "Veggies", total.veggies,
                           "<br>", "Wheat", wheat, "Corn", corn))
# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

fig <- plot_geo(df, locationmode = 'USA-states')
fig <- fig %>% add_trace(
  z = ~total.exports, text = ~hover, locations = ~code,
  color = ~total.exports, colors = 'Purples', marker = list(line = l)
)
fig <- fig %>% colorbar(title = "Millions USD")
fig <- fig %>% layout(
  title = '2011 US Agriculture Exports by State<br>(Hover for breakdown)',
  geo = g
)

fig

# leaflet -----------------------------------------------------------------

## https://rstudio.github.io/leaflet/
## install.packages("leaflet")

library(leaflet)

# Obszar rysowania

leaflet()

# Mapa świata

leaflet() %>% 
  addTiles()

# Zaznaczony punkt
leaflet() %>%
  addTiles() %>% 
  addMarkers(lng = 21.007135613409062, lat = 52.22217811913538, popup = "Wydział MiNI")

# Punkty na mapie (Seattle)
df <- read.csv("https://raw.githubusercontent.com/MI2-Education/2023Z-DataVisualizationTechniques/main/homeworks/hw1/house_data.csv")
sam <- sample(1:nrow(df), 0.01 * nrow(df))
leaflet(df[sam,]) %>% 
  addTiles() %>% 
  addMarkers(lng = ~long, lat = ~lat)

# Połączenie leaflet i maps
library(maps)

mapStates = map("state", fill = TRUE, plot = FALSE)

leaflet(data = mapStates) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL))

leaflet(data = mapStates) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

# Punkty 

m = leaflet() %>% addTiles()
df = data.frame(
  lat = rnorm(100),
  lng = rnorm(100),
  size = runif(100, 5, 20),
  color = sample(colors(), 100)
)
m = leaflet(df) %>% addTiles()

m %>% addCircleMarkers(radius = ~size, color = ~color, fill = FALSE)

m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))

# Obszary

#install.packages("geojsonio")
library(geojsonio)
states <- geojsonio::geojson_read("https://rstudio.github.io/leaflet/json/us-states.geojson", what = "sp")
class(states)

m <- leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addTiles()
m

m %>% addPolygons()

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

m %>% addPolygons(
  fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7)

# Dodanie interakcji

m %>% addPolygons(
  fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7,
  highlightOptions = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE))

# Dodanie informacji, które będą się wyświetlać po najechaniu na stan.

labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

m <- m %>% addPolygons(
  fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7,
  highlightOptions = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto"))
m

# Dodanie legendy 

m %>% addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
                position = "bottomright")


# Zadanie 3 ----------------------------------
# Przygotuj mapę Polski, na której zaznaczysz wszystkie województwa jednolitym 
# kolorem wypełnienia. Następnie wyróżnij jedno wybrane województwo innym kolorem 
# oraz pogrubionym obrysem. Dodaj do tego województwa dymek.

polska <- geojsonio::geojson_read("https://raw.githubusercontent.com/ppatrzyk/polska-geojson/master/wojewodztwa/wojewodztwa-medium.geojson", what = "sp")


mazowieckie <- polska@data$nazwa=='mazowieckie'

fill_cols <- ifelse(polska@data$nazwa=='mazowieckie', "#ff4d4d", "#dddddd")
weights   <- ifelse(polska@data$nazwa=='mazowieckie', 3, 1)

popup_text <- ifelse(
  polska@data$nazwa=='mazowieckie',
  paste0("</strong>",polska@data$nazwa, "</strong><br/>To jest moje województwo."),
  NA
)

leaflet(polska) %>%
  addTiles() %>%
  addPolygons(
    fillColor = fill_cols,
    fillOpacity = 0.7,
    color = "white",
    weight = weights,
    popup = popup_text,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#666",
      fillOpacity = 0.8,
      bringToFront = TRUE
    )
  )


