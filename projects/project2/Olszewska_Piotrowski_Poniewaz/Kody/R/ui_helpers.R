`%||%` <- function(x, y) if (is.null(x)) y else x

avatar_box <- function(img, name, size = 120, y = "30%") {
  tags$div(
    style = "text-align:center; padding:10px;",
    tags$img(
      src = img,
      style = paste0(
        "width:", size, "px; height:", size, "px;",
        "border-radius:50%; object-fit:cover;",
        "object-position:center ", y, ";",
        "box-shadow:0 4px 10px rgba(0,0,0,0.2);"
      )
    ),
    tags$div(style = "margin-top:8px; font-weight:600;", name)
  )}

get_weekday_pl <- function(date) {
  WEEKDAYS_PL[lubridate::wday(date, week_start = 1)]
}

section_box <- function(title, icon, color, content) {
  tags$div(
    style = paste0(
      "background:", scales::alpha(color, 0.08), ";",
      "border:1px solid ", scales::alpha(color, 0.35), ";",
      "border-radius:14px;",
      "padding:14px;",
      "margin-bottom:10px;",
      "transition: all 0.2s ease;",
      "box-shadow:0 4px 10px rgba(0,0,0,0.04);"
    ),
    h5(
      tags$span(icon, style = "margin-right:6px;"),
      title,
      style = paste0(
        "margin-top:0;",
        "margin-bottom:8px;",
        "color:", color, ";",
        "font-weight:700;"
      )
    ),
    content
  )
}
