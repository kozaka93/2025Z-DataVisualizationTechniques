library(ggplot2)
library(dplyr)
library(gganimate)
library(gifski)

set.seed(123)

n <- 19; cx <- 10
T_reveal <- 55; T_total <- 65
y1 <- 3; h1 <- 7
y2 <- 6; h2 <- 9
tx <- 9:11; ty <- 15:17

COL_BG <- "#2B2B2B"; COL_TREE <- "#2E8B57"

####
nb8 <- function(x,y,n){
  xs <- pmax(1,x-1):pmin(n,x+1); ys <- pmax(1,y-1):pmin(n,y+1)
  z <- expand.grid(x=xs,y=ys); z[z$x!=x | z$y!=y,]
}

tri_out <- function(cx,y0,h) do.call(rbind,lapply(0:(h-1), \(i){
  y<-y0+i
  if(i<h-1) rbind(cbind(x=cx-i,y=y), cbind(x=cx+i,y=y))
  else cbind(x=(cx-i):(cx+i), y=y)
}))
tri_in <- function(cx,y0,h){
  pts <- do.call(rbind,lapply(1:(h-2), \(i){
    y<-y0+i; L<-(cx-i)+1; R<-(cx+i)-1
    if(L<=R) cbind(x=L:R, y=y) else NULL
  }))
  if(is.null(pts)) data.frame(x=integer(),y=integer()) else as.data.frame(pts)
}

out <- unique(rbind(tri_out(cx,y1,h1), tri_out(cx,y2,h2)))
out <- out[out[,"x"]>=1 & out[,"x"]<=n & out[,"y"]>=1 & out[,"y"]<=n,,drop=FALSE]

trunk <- as.matrix(expand.grid(x=tx,y=ty))

inside <- bind_rows(tri_in(cx,y1,h1), tri_in(cx,y2,h2)) |> distinct()
kout <- paste(out[,1],out[,2],sep="_")
inside$key <- paste(inside$x,inside$y,sep="_")
inside <- inside[!(inside$key %in% kout),c("x","y"),drop=FALSE]
#BOMBY
bombs <- bind_rows(
  tibble(x=out[,1], y=out[,2], kind="tree", size=2.2, col=COL_TREE),
  tibble(x=trunk[,1], y=trunk[,2], kind="trunk", size=2.6, col="#8B5A2B"),
  tibble(x=orns$x, y=orns$y, kind="orns", size=sample(c(2,2.6,3.2,3.8,4.4), m, TRUE),
         col=sample(c("#FFD166","#EF476F","#118AB2","#06D6A0","#F4A261","#A8DADC"), m, TRUE))
) |> distinct(x,y,.keep_all=TRUE)

bmat <- matrix(FALSE,n,n); for(i in 1:nrow(bombs)) bmat[bombs$y[i], bombs$x[i]] <- TRUE
adj <- matrix(0L,n,n)
for(y in 1:n) for(x in 1:n){ z<-nb8(x,y,n); adj[y,x] <- sum(bmat[cbind(z$y,z$x)]) }

reveal_click <- function(R,x0,y0){
  if(bmat[y0,x0] || R[y0,x0]) return(R)
  qx <- x0
  qy <- y0
  while(length(qx)) {
    x<-qx[1]; y<-qy[1]; qx<-qx[-1]; qy <- qy[-1]
    if(R[y,x] || bmat[y,x]) next
    R[y,x] <- TRUE
    
    if(adj[y,x]==0L) {
      z<-nb8(x,y,n)
      for(k in 1:nrow(z)){
        nx<-z$x[k]; ny<-z$y[k]
        if(!R[ny,nx] && !bmat[ny,nx]){ qx <- c(qx,nx); qy <- c(qy,ny) }
      }
    }
    
  }
  R
}

# KLIKANIE 
safe <- which(!bmat, arr.ind=TRUE); zeros <- safe[adj[safe]==0L,,drop=FALSE]
start <- zeros[sample(nrow(zeros),1),,drop=FALSE]

R <- matrix(FALSE,n,n); Rlist <- vector("list", T_reveal)
for(t in 1:T_reveal){
  if(t==1) R <- reveal_click(R, start[1,"col"], start[1,"row"])
  else{
    cand <- which(!R & !bmat, arr.ind=TRUE)
    if(nrow(cand)){
      zcand <- cand[adj[cand]==0L,,drop=FALSE]
      pick_from <- if(nrow(zcand) && runif(1)<0.75) zcand else cand
      p <- pick_from[sample(nrow(pick_from),1),,drop=FALSE]
      R <- reveal_click(R, p[1,"col"], p[1,"row"])
    }
  }
  Rlist[[t]] <- R
}
Rlist[[T_reveal]] <- !bmat

grid <- expand.grid(x=1:n,y=1:n) |> as_tibble()

frames <- bind_rows(lapply(1:T_total, function(fid){
  Rm <- if(fid<=T_reveal) Rlist[[fid]] else Rlist[[T_reveal]]
  show_bombs <- fid > T_reveal
  grid |>
    mutate(frame_id=fid,
           rev = Rm[cbind(y,x)],
           adj_n = adj[cbind(y,x)],
           label = ifelse(rev & adj_n>0 & !bmat[cbind(y,x)], as.character(adj_n), ""),
           tile = ifelse(rev, "#E6E6E6", "#9A9A9A"),
           show_bombs = show_bombs)
}))
#WYK
p <- ggplot(frames, aes(x,y)) +
  geom_tile(aes(fill=tile), color=NA) +
  geom_text(data=frames |> filter(label!=""), aes(label=label), size=3.2, fontface="bold") +
  geom_point(
    data = frames |> filter(show_bombs) |> left_join(bombs, by=c("x","y")) |> filter(!is.na(kind)),
    aes(color=col, size=size),
    shape=16
  ) +
  scale_y_reverse() + coord_fixed() +
  scale_fill_identity() + scale_size_identity() + scale_color_identity() +
  theme_void() +
  theme(panel.background=element_rect(fill=COL_BG, color=NA),
        plot.background =element_rect(fill=COL_BG, color=NA),
        plot.margin=margin(0,0,0,0)) +
  transition_time(frame_id)

out_dir <- file.path(Sys.getenv("LOCALAPPDATA"), "R_mines_choinka")
dir.create(out_dir)
gif_file <- file.path(out_dir, "minesweeper_choinka.gif")

animate(p, nframes=T_total, fps=5, width=500, height=500, renderer=gifski_renderer(gif_file))