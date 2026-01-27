levels <- 15

triangle <- list()
triangle[[1]] <- c(1)

for (i in 2:levels) {
  prev <- triangle[[i - 1]]
  triangle[[i]] <- c(1, prev[-length(prev)] + prev[-1], 1)
}

# tutaj tworze liste postaci ((1),(1,2,1), (1,3,3,1)...) kolejnych wierszy trójkąta

pascal <- data.frame()
 
for (i in seq_along(triangle)) {
  row <- triangle[[i]]
  for (j in seq_along(row)) {
    pascal <- rbind(
      pascal,
      data.frame(
        row = i,
        col = j,
        value = row[j]
      )
    )
  }
}


pascal$x <- pascal$col - (pascal$row + 1) / 2
pascal$y <- -pascal$row
# tu przypisuje współrzędne, za pomocą mądrego wzoru można je ustawić symetrycznie, co sprawia że wykres wygląda jak choinka
write.csv(pascal, "pascal_data.csv", row.names = FALSE)

