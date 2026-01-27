library(plotly)

set.seed(123)

levels <- 11
z <- seq(2, levels^2, length.out = levels)
zt <- z[2:levels]*(1+(1/levels))
r <- seq(levels/2, 0.2, length.out = levels)
cols <- rgb(colorRamp(c("#2f2", "#020"))(seq(0, 1, length.out=levels)), maxColorValue=255)
decoration.cols <- c("#f00", "#00f", "#ff0", "#0ff", "#f0f")

fig <- plot_ly()

decoration.rate <- 0.02

for (i in 1:(levels-1)) {
  points <- 1000*(levels-i)
  phi <- runif(points, 0, 2*pi)
  zp <- runif(points, z[i], zt[i])
  rp <- r[i] * (1 - (zp - z[i]) / (zt[i] - z[i]))
  cls <- sample(c(cols[i], decoration.cols), points, prob = c(1-decoration.rate, rep(decoration.rate/length(decoration.cols), length(decoration.cols))), replace=TRUE)
  which.pts <- (cls == cols[i])
  
  fig <- fig %>%
    add_markers(
      x = rp[which.pts]*cos(phi[which.pts]),
      y = rp[which.pts]*sin(phi[which.pts]),
      z = zp[which.pts],
      type = "scatter3d",
      mode = "markers",
      marker = list(size=7, color=cols[i], opacity=0.15),
      hoverinfo = "none"
    ) %>%
    add_markers(
      x = rp[!which.pts]*cos(phi[!which.pts]),
      y = rp[!which.pts]*sin(phi[!which.pts]),
      z = zp[!which.pts],
      type = "scatter3d",
      mode = "markers",
      marker = list(size=3.77, color=cls[!which.pts], opacity=1),
      hoverinfo = "none"
    )
}

points2 <- 1000
points3 <- 3000
phi2 <- runif(points2, 0, 2*pi)
zp2 <- runif(points2, -0.15*max(z), 0.01*max(z))
rp2 <- 0.25*max(r)

fig <- fig %>%
  add_markers(
    x = rp2*cos(phi2),
    y = rp2*sin(phi2),
    z = zp2,
    type = "scatter3d",
    mode = "markers",
    marker = list(size=7, color="#642", opacity=0.8),
    hoverinfo = "none"
  ) %>%
  add_markers(
    x = runif(points3, -max(r), max(r)),
    y = runif(points3, -max(r), max(r)),
    z = min(zp2),
    type = "scatter3d",
    mode = "markers",
    marker = list(size=6, color="#fff", opacity=0.80),
    hoverinfo = "none"
  )


fig <- fig %>% 
  layout(
    showlegend = FALSE,
    margin = list(l=0, r=0, t=0, b=0),
    paper_bgcolor = '#228',
    plot_bgcolor = '#228',
    scene = list(
      xaxis = list(
        visible = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE,
        zeroline = FALSE
      ),
      yaxis = list(
        visible = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE,
        zeroline = FALSE
      ),
      zaxis = list(
        visible = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE,
        zeroline = FALSE
      ),
      camera = list(
        eye = list(x = 1.5, y = 1.5, z = -0.33)
      )
    )
  )

fig