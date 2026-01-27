library(ggplot2)
library(maps)
library(mapdata)
library(dplyr)
library(plotly)


# Link do oryginalnego wykresu :
#https://x.com/AdityaDahiyaIAS/status/1967783951587742072/photo/1

# Link do repozytorium z danymi:
#https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-09-09/country_lists.csv



#Dlaczego oryginalny wykres jest zły :
# 1 Próba przedstawienia wszystkich państw za pomocą tektsu na jednym wykresie powoduje
# , że są one strasznie małe i nie możliwe jest rozczytanie ich
#
# 2 przedstawienie wszystkich państw do których można przyjechać bez wizy
# za pomocą bardzo małych flag, również powoduje brak czytelności wykresu 
#
# 3 Nie da się jednoznacznie stwierdzić które flagi odpowiadają któremu państwu


extract_countries <- function(text) {
  pattern <- '"name":"([^"]+)"'
  
  matches <- gregexpr(pattern, text)
  items <- regmatches(text, matches)[[1]]
  
  if (length(items) == 0) return(character(0))
  

  countries <- sub('"name":"', '', items)
  countries <- sub('"$', '', countries)
  
  return(countries)
}

dane <- read.csv("twd_hw4_dane.csv", stringsAsFactors = FALSE)
dane$visa_free <- lapply(dane$visa_free_access, extract_countries)
dane$ile <- sapply(dane$visa_free, length)

dane$visa_free_text <- sapply(dane$visa_free, function(kraje){
  if (length(kraje) == 0) return("Brak danych")
  

  segments <- split(kraje, ceiling(seq_along(kraje) / 10))
  paste(sapply(segments, paste, collapse = ", "), collapse = "<br>")
})

dane$tooltip_text <- paste0(
  "Kraj: ", dane$country, "<br>",
  "Liczba: ", dane$ile, " krajów(destynacji) bezwizowych<br>",
  "Lista:<br>", dane$visa_free_text
)
w <- map_data("world")

dane$country[dane$country == "United States"] <- "USA"
dane$country[dane$country == "United Kingdom"] <- "UK"
dane$country[dane$country == "Türkiye"] <- "Turkey"
dane$country[dane$country == "United Republic of Tanzania"] <- "Tanzania"
dane$country[dane$country == "Taiwan (Chinese Taipei)"] <- "Taiwan"
dane$country[dane$country == "Syrian Arab Republic"] <- "Syria"
dane$country[dane$country == "eSwatini"] <- "Swaziland"
dane$country[dane$country == "Republic of Korea"] <- "South Korea"
dane$country[dane$country == "Democratic People's Republic of Korea"] <- "North Korea"
dane$country[dane$country == "Republic of Moldova"] <- "Moldova"
dane$country[dane$country == "Lao People's Democratic Republic"] <- "Laos"
dane$country[dane$country == "Iran (Islamic Republic of)"] <- "Iran"
dane$country[dane$country == "The Gambia"] <- "Gambia"
dane$country[dane$country == "Czechia"] <- "Czech Republic"
dane$country[dane$country == "Cote d'Ivoire"] <- "Ivory Coast"
dane$country[dane$country == "Comoro Islands"] <- "Comoros"
dane$country[dane$country == "Cape Verde Islands"] <- "Cape Verde"
dane$country[dane$country == "Brunei Darussalam"] <- "Brunei"
dane$country[dane$country == "Palestinian Territory"] <- "Palestine"
dane$country[dane$country == "Vatican City"] <- "Vatican"
dane$country[dane$country == "Palau Islands"] <- "Palau"
dane$country[dane$country == "Russian Federation"] <- "Russia"
dane$country[dane$country == "Congo (Dem. Rep.)"] <- "Democratic Republic of the Congo"
dane$country[dane$country == "Congo (Rep.)"] <- "Republic of Congo"

dane$country[dane$country == "Antigua and Barbuda"] <- "Antigua" 


dane$country[dane$country == "St. Vincent and the Grenadines"] <- "Saint Vincent" 
dane$country[dane$country == "St. Lucia"] <- "Saint Lucia"
dane$country[dane$country == "St. Kitts and Nevis"] <- "Saint Kitts"


dane <- left_join(dane, w, by = c("country" = "region"))
 
mapa_ggplot <- ggplot(data = dane, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = ile, text = tooltip_text), color = "black") +
  coord_fixed(1.3) +
  scale_fill_gradient(
    low = "#FFFFB2",   
    high = "#E31A1C"   
  ) +
  theme_void() +
  labs(title = "Gdzie można Podróżować bez wizy – dostępność według obywatelstwa",fill="liczba państw")+
  theme(
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold",
                              margin = margin(b = 20, unit = "pt")),
    plot.margin = unit(c(0.2, 0.2, 0.2, 0.2), "cm")
  )

ggplotly(
  mapa_ggplot,
  tooltip = "text"
)

#Dla czytelności wykresu należy go otworzyć w pełnej wielkośći 

#Dlaczego wykres jest lepszy:
# 1. Użycie mapy jest znacznie lepsza opcją dla przedstawienia wszystkich państw , ponieważ jest ona czytelna
# i wiadomo które państwo jest które. nie ma problemu z mikrospoijna wielkością napisów
#
# 2. Dzięki użyciu plotly możemy w czytelny sposób przypisac każdemu pańswtu, państwa do których można 
# wjechać bez wizy. W jednym momencie pokazuja nam się dane tylko o jednym państwie, więc nie ma problemu 
# z mała trzcionka , która byłaby nie czytelna. A zachowane są przy tym wszystkie informacje dostępne 
# na oryginalnym wykresie 


