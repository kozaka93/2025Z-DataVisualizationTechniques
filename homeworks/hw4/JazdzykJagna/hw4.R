library(plotly)
library(tidyverse)

# link do posta na portalu X:
# https://x.com/simisani10/status/1774780110538690799
# link do repozytorium z danymi:
# https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-26/public-picks

# orginalny kod:

# Read the dataset from the URL
data <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-26/public-picks.csv")

# Prepare data for plotting
data_long <- pivot_longer(data, -c(YEAR, TEAMNO, TEAM), names_to = "Round", values_to = "Percentage")
data_long$Percentage <- as.numeric(sub("%", "", data_long$Percentage))  # Convert percentage to numeric

# Create a sunburst chart
fig <- plot_ly(data_long, ids = ~paste(YEAR, TEAMNO, sep = "_"), 
               labels = ~TEAM, parents = ~YEAR, values = ~Percentage, type = 'sunburst',
               branchvalues = "total") %>% 
  layout(title = list(text = "<b>Progression of NCAA basketball teams across different rounds</b>", 
                      font = list(size = 18, color = "black", family = "Arial")))

caption <- "Source: 2024 Tidy Tuesday week 13 | Graphic: Simisani Ndaba"
fig <- fig %>%
  layout(annotations = list(text = caption, 
                            font = list(size = 14, family = "Arial"), 
                            x = 0.5, y = -0.1, 
                            showarrow = FALSE, xref = "paper", yref = "paper"))


# Show the plot
fig

ggsave("2024TidyTuesdayweek13.png", width = 10, height = 10)



#POPRAWA KODU

# Na wykresie nie widać dobrze jakie faktyczne szanse kolejne drużyny mają na przejście kolejnych rund 
# Są puste pola między drużynami różnych wielkosci, na plocie nie widać kto ma największe a kto najmniejsze szanse
# nawet nazwa wykresu się nie zgadza, nie pokazuje across different rounds tylko w rundzie R64
# brak legendy, nie widać drużyn które mają małe szanse 

data <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-26/public-picks.csv")

data_long$Round <- factor(
  data_long$Round,
  levels = c("R64","R32","S16","E8","F4","FINALS"),
  ordered = TRUE
)

data <- data[order(data$FINALS, decreasing = TRUE), ]

data_long <- pivot_longer(data, -c(YEAR, TEAMNO, TEAM), names_to = "Round", values_to = "Percentage")
data_long$Percentage <- as.numeric(sub("%", "", data_long$Percentage)) 

teams <- unique(data_long$TEAM)
length(teams)

fig <- plot_ly()

for(i in seq(1,length(teams), by = 1)){
  team_data <- subset(data_long, TEAM == teams[i])
  
  fig <- add_trace(
    fig,
    data = team_data,
    x = ~Round,
    y = ~Percentage,
    type = 'scatter',
    mode = 'lines+markers',
    name = teams[i],
    visible = ifelse(i==1, TRUE, "legendonly")  
  )
}

fig <- fig %>%
  layout(
    xaxis = list(
      title = "Round",
      categoryorder = "array",
      categoryarray = c("R64","R32","S16","E8","F4","FINALS"),
      fixedrange = TRUE
    ),
    yaxis = list(fixedrange = TRUE),
    annotations = list(
      list(
        x = 0.5,   
        y = 1.0,   
        xref = "paper",
        yref = "paper",
        text = "The probability  of progression of NCAA basketball teams across different rounds in 2024",
        xanchor = "center",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 15)
      )),
    legend = list(
      title = list(text = "Team:"))
  )  
  

fig

# ten wykres jest lepszy ponieważ możemy wybrać który team chcemy zobaczyć
# widzimy w każdej rundzie faktycznie jakie jest procentowe pradopodobienstwo że ta drużyna przjdzie w danej rundzie dalej- jest oś ox (podziałka na rudny) oraz oy (ilość procentowa)


