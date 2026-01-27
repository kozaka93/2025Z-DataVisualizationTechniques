library(ggplot2)
library(gganimate)

Sys.setlocale("LC_TIME", "C")

data <- data.frame(
  Date = as.Date(c("2025-12-10", "2025-12-11", "2025-12-12", "2025-12-13", 
                   "2025-12-14", "2025-12-15", "2025-12-16", "2025-12-17", 
                   "2025-12-18", "2025-12-19", "2025-12-20", "2025-12-21", 
                   "2025-12-22", "2025-12-23", "2025-12-24", "2025-12-25", 
                   "2025-12-26", "2025-12-27", "2025-12-28", "2025-12-29", 
                   "2025-12-30", "2025-12-31", "2026-01-01", "2026-01-02", 
                   "2026-01-03", "2026-01-04", "2026-01-05", "2026-01-06", 
                   "2026-01-07", "2026-01-08")),
  Open = c(100, 103, 105, 107, 110, 112, 114, 117, 118, 120, 
           122, 124, 127, 129, 131, 133, 130, 127, 126, 124, 
           122, 119, 118, 115, 112, 111, 109, 107, 104, 102),
  High = c(105, 107, 108, 111, 114, 116, 118, 119, 122, 125, 
           126, 128, 130, 133, 135, 134, 132, 129, 127, 126, 
           123, 120, 118, 115, 113, 112, 110, 108, 105, 103),
  Low = c(98, 101, 102, 104, 106, 108, 112, 114, 115, 116, 
          118, 119, 122, 125, 127, 128, 125, 124, 121, 120, 
          117, 115, 112, 110, 109, 107, 104, 102, 100, 97),
  Close = c(103, 105, 107, 110, 112, 114, 117, 118, 120, 122, 
            124, 127, 129, 131, 133, 130, 127, 126, 124, 122, 
            119, 118, 115, 112, 111, 109, 107, 104, 102, 100)
)

star_data <- data.frame(
  Date = as.Date("2025-12-24"),
  y = 135
)

p <- ggplot(data, aes(x = Date)) +
  geom_linerange(
    aes(ymin = Low, ymax = High),
    linewidth = 0.6
  ) +
  
  geom_rect(
    aes(
      xmin = Date - 0.4,
      xmax = Date + 0.4,
      ymin = pmin(Open, Close),
      ymax = pmax(Open, Close),
      fill = Close > Open
    ),
    color = "black"
  ) +
  
  geom_text(
    data = star_data,
    aes(x = Date, y = y),
    label = "★",
    color = "gold",
    size = 16
  ) +
  
  scale_fill_manual(values = c("TRUE" = "#32CD32", "FALSE" = "red")) +
  labs(
    title = "Christmas Tree Stock Chart"
  ) +
  scale_x_date(
    breaks = as.Date(c(
    "2025-12-12",
    "2025-12-18",
    "2025-12-24",
    "2025-12-30",
    "2026-01-05"
  )),
  date_labels = "%d %b"
  ) +
  
  theme(
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.x = element_blank(),
    
    legend.position = "none",
    
    panel.background = element_rect(fill = "#1b3a57", color = NA),
    plot.background  = element_rect(fill = "#1b3a57", color = NA),
    
    axis.text.x = element_text(color = "white"),
    
    panel.grid.major = element_line(color = scales::alpha("white", 0.7), linewidth = 0.05),
    panel.grid.minor = element_line(color = scales::alpha("white", 0.7), linewidth = 0.05),
    
    plot.title = element_text(color = "white", hjust = 0.5, face="bold", size = 20)
  ) +
  
  transition_states(
    Date,
    transition_length = 0,
    state_length = 0.5
  ) +
  shadow_mark()

animation <- animate(p, fps = 20, width = 400, height = 500)

anim_save("christmas_tree.gif", animation = animation)
