library(shiny)
library(plotly)
library(dplyr)

generate_scene_long <- function(seed = 123,
                                n_lights = 120,
                                n_baubles = 35,
                                n_snow = 140,
                                n_frames = 30) {
  set.seed(seed)
  
  y_outline <- seq(0.06, 1.05, length.out = 240)
  half_width <- (1.07 - y_outline) * 0.95
  wobble <- 0.06 * sin(10 * y_outline * pi) + 0.02 * sin(26 * y_outline * pi)
  
  x_left  <- -(half_width + wobble)
  x_right <-  (half_width + wobble)
  
  tree_outline <- tibble(
    x = c(x_left, rev(x_right)),
    y = c(y_outline, rev(y_outline))
  )
  
  trunk <- tibble(
    x = c(-0.12, 0.12, 0.12, -0.12),
    y = c(0.00, 0.00, 0.18, 0.18)
  )
  
  star <- tibble(x = 0, y = 1.10)
  
  sample_inside_tree <- function(n) {
    y <- runif(n, 0.07, 1.02)
    hw <- (1.07 - y) * 0.92
    x <- (runif(n, -1, 1) ^ 3) * hw
    tibble(x = x, y = y)
  }
  
  baubles <- sample_inside_tree(n_baubles) |>
    mutate(
      id = paste0("B", row_number()),
      color = sample(c("#C0392B", "#8E44AD", "#2980B9", "#16A085", "#F39C12"), n(), TRUE),
      size  = runif(n(), 12, 18),
      text  = paste0("Bombka ", id, "<br>x=", sprintf("%.2f", x), " y=", sprintf("%.2f", y))
    )
  
  lights_base <- sample_inside_tree(n_lights) |>
    mutate(
      id = paste0("L", row_number()),
      phase = runif(n(), 0, 2*pi),
      freq  = runif(n(), 0.7, 1.5),
      hue   = sample(c("gold", "deepskyblue", "hotpink", "limegreen", "orange"), n(), TRUE),
      size0 = runif(n(), 6, 10)
    )
  
  lights_long <- bind_rows(lapply(seq_len(n_frames), function(t) {
    br <- 0.2 + 0.8 * (sin(lights_base$freq * (t / n_frames) * 2*pi + lights_base$phase) * 0.5 + 0.5)
    tibble(
      t = t,
      x = lights_base$x,
      y = lights_base$y,
      color = lights_base$hue,
      size = lights_base$size0 * (0.75 + 0.55 * br),
      opacity = pmax(0.15, pmin(1, br)),
      text = paste0(lights_base$id, "<br>jasność=", sprintf("%.2f", br))
    )
  }))
  
  snow_base <- tibble(
    id = paste0("S", seq_len(n_snow)),
    x0 = runif(n_snow, -1.25, 1.25),
    y0 = runif(n_snow, 0.45, 1.30),
    vx = rnorm(n_snow, 0, 0.004),
    vy = runif(n_snow, 0.015, 0.05),
    size = runif(n_snow, 4, 8)
  )
  
  wrap_y <- function(y, ymin = -0.15, ymax = 1.25) {
    rng <- ymax - ymin
    ymin + ((y - ymin) %% rng)
  }
  
  snow_long <- bind_rows(lapply(seq_len(n_frames), function(t) {
    x <- snow_base$x0 + snow_base$vx * t
    y <- snow_base$y0 - snow_base$vy * t
    tibble(
      t = t,
      x = x,
      y = wrap_y(y, ymin = -0.15, ymax = 1.25),
      size = snow_base$size,
      text = paste0(snow_base$id, "<br>t=", t)
    )
  }))
  
  list(
    tree_outline = tree_outline,
    trunk = trunk,
    star = star,
    baubles = baubles,
    lights_long = lights_long,
    snow_long = snow_long,
    n_frames = n_frames
  )
}

build_plot <- function(scene, title = "Choinka TWD") {
  
  plot_ly() |>
    add_polygons(
      data = scene$tree_outline,
      x = ~x, y = ~y,
      fillcolor = "rgb(16, 92, 60)",
      line = list(color = "rgb(8, 60, 38)", width = 2),
      hoverinfo = "skip",
      name = "Gałęzie"
    ) |>
    add_polygons(
      data = scene$trunk,
      x = ~x, y = ~y,
      fillcolor = "rgb(105, 64, 40)",
      line = list(color = "rgb(70, 40, 20)", width = 2),
      hoverinfo = "skip",
      name = "Pień"
    ) |>
    add_markers(
      data = scene$star,
      x = ~x, y = ~y,
      marker = list(symbol = "star", size = 20, color = "gold",
                    line = list(color = "rgb(140,110,0)", width = 1)),
      hovertemplate = "Gwiazda<extra></extra>",
      name = "Gwiazda"
    ) |>
    add_markers(
      data = scene$baubles,
      x = ~x, y = ~y,
      marker = list(size = ~size, color = ~color,
                    line = list(color = "rgba(255,255,255,0.6)", width = 1)),
      hovertemplate = "%{text}<extra></extra>",
      text = ~text,
      name = "Bombki"
    ) |>
    add_markers(
      data = scene$lights_long,
      x = ~x, y = ~y,
      frame = ~t,
      marker = list(size = ~size, color = ~color),
      opacity = ~opacity,
      hovertemplate = "%{text}<extra></extra>",
      text = ~text,
      name = "Lampki"
    ) |>
    add_markers(
      data = scene$snow_long,
      x = ~x, y = ~y,
      frame = ~t,
      marker = list(size = ~size, color = "white"),
      opacity = 0.85,
      hovertemplate = "%{text}<extra></extra>",
      text = ~text,
      name = "Śnieg"
    ) |>
    layout(
      title = list(text = title),
      xaxis = list(range = c(-1.3, 1.3), visible = FALSE),
      yaxis = list(range = c(-0.15, 1.25), visible = FALSE),
      showlegend = TRUE,
      legend = list(orientation = "h", x = 0, y = -0.05),
      margin = list(l = 10, r = 10, t = 60, b = 30),
      updatemenus = list(
        list(
          type = "buttons",
          direction = "left",
          x = 0, y = 1.15,
          buttons = list(
            list(
              label = "Play",
              method = "animate",
              args = list(NULL, list(
                frame = list(duration = 120, redraw = FALSE),
                transition = list(duration = 0),
                fromcurrent = TRUE,
                mode = "immediate"
              ))
            ),
            list(
              label = "Pause",
              method = "animate",
              args = list(NULL, list(
                frame = list(duration = 0, redraw = FALSE),
                mode = "immediate"
              ))
            )
          )
        )
      )
    )
}

ui <- fluidPage(
  titlePanel("Generator Choinek"),
  sidebarLayout(
    sidebarPanel(
      numericInput("seed", "Seed:", value = 123, min = 1, step = 1),
      sliderInput("n_lights", "Lampki:", min = 30, max = 300, value = 120, step = 10),
      sliderInput("n_baubles", "Bombki:", min = 5, max = 80, value = 35, step = 5),
      sliderInput("n_snow", "Śnieg:", min = 0, max = 300, value = 140, step = 20),
      sliderInput("n_frames", "Klatki animacji:", min = 10, max = 80, value = 30, step = 5),
      textInput("title", "Tytuł:", value = "Tytuł choinki"),
      hr()
    ),
    mainPanel(
      plotlyOutput("tree_plot", height = "720px")
    )
  )
)

server <- function(input, output, session) {
  
  scene <- reactive({
    generate_scene_long(
      seed = input$seed,
      n_lights = input$n_lights,
      n_baubles = input$n_baubles,
      n_snow = input$n_snow,
      n_frames = input$n_frames
    )
  })
  
  output$tree_plot <- renderPlotly({
    build_plot(scene(), title = input$title)
  })
}

shinyApp(ui, server)
