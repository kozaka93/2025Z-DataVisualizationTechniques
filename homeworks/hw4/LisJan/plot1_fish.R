library(tidytuesdayR)
library(dplyr)
library(ggplot2)
library(forcats)

###
### Linki
###
# Oryginalny wykres: https://github.com/Alessine/TidyTuesday-Visualizations/blob/master/2021W24_Great_Lakes_fish/erie_fish_plot.png
# 
# Repozytorium autorki z całym wkładem w inicjatywę #TidyTueasday od R4DS online learning community
# Link: https://github.com/Alessine/TidyTuesday-Visualizations/tree/master
# Wykres poprawiany jest z tygodnia 24 pt. "Fish in the Great Lakes"
#
# Oryginalny kod: https://github.com/Alessine/TidyTuesday-Visualizations/blob/master/2021W24_Great_Lakes_fish/210608_tidytuesday_great_lakes_fish.Rmd
#
# Dane: https://github.com/rfordatascience/tidytuesday/blob/main/data/2021/2021-06-08/fishing.csv
#
###
### Problemy z oryginalnym wykresem
###
# 1. Wykres typu sunburst, nie jest dobrym wyborem do tego zestawu danych.
# Wszystkie lata w postaci koła sugerują, jakby było to jakieś 100%, ale przecież jezioro
# w kolejnym roku i zeszłym też będzie miało ryby. Do tego ciężko jest porównać łączną
# ilość ryb w danych latach (np. więcej jest w 2006 czy 2001?)
#
# 2. Na drugim pierścieniu jest duże zagęszczenie gatunków ryb, co powoduje, że są
# one nieczytelne (mała czcionka i zlewa się trochę z tłem).
#
# 3. Trudno jest porównać ilość ryb danego gatunku na przestrzeni lat, dla stosunkowo
# małych zmian watości (np. Yellow Perch dla lat 2008, 2009, 2010)
#


# Wczytanie danych
data <- tt_load('2021-06-08')


ryby <- data$fishing

# Obróbka
# Wybór jeziora

ryby <- ryby %>% filter(lake=="Erie") %>% filter(year>=2000 & year <=2010)

#Wybranie top 4 ryb względem ilości z każdego roku

top4 <- ryby %>% distinct(year,species, .keep_all = TRUE) %>% 
  group_by(year) %>% slice_max(order_by = grand_total,n=4) %>% 
  arrange(year, desc(grand_total))

gatunki <- sort(unique(top4[["species"]]))
gatunki <- c(gatunki, "Other")
# Najpopularniejsze gatunki, reszta ma kategorie other


#Ustawienie kategorii other i factorów
ryby <- ryby  %>% 
  mutate(species = case_when(
    species %in% gatunki ~ species,
    .default = "Other"
  )) %>% mutate(species=(fct_relevel(species,gatunki)))

#Kolory do wykresu
barwy=c("#FF595E","#FF924C","#FFCA3A","#8AC926","#1982C4","#6A4C93","#9b9b7a")



#Tworzenie wykresu
fish_plot <-ryby %>% ggplot(aes(x=as.factor(year),y=grand_total,fill=species))+geom_col() + 
  scale_fill_discrete(palette = barwy, name="Species") + 
  labs(x="Year",y="Total number",title = "Number of fish by spiecies in Lake Erie (2000 - 2010)") +
  theme(
    #plot.background = element_blank(),
    panel.background = element_blank(),
    plot.title.position = "plot",
    plot.title = element_text(hjust=0.5),
    axis.text.x= element_text(color = "black",vjust=1,margin=margin(t=-12),size=10),
    axis.text.y = element_text(color="black",size=12),
    axis.ticks.y = element_line(color="black"),
    panel.grid.major.y = element_line(color="black",linetype=1),
    panel.grid.minor.y = element_line(color="black"),
    axis.ticks.x = element_blank(),
    legend.text = element_text(color="black",size=12),
    legend.title = element_text(color="black",size=14),
    title = element_text(size=16),
    panel.grid.major.x = element_blank()
  ) + scale_x_discrete(breaks = seq(2000,2010,2))

fish_plot
ggsave("remaked_plot.png", fish_plot,width=7,height=6.5)

###
### Czemu stworzony wykres jest lepszy?
###
#
# 1. Dużo wyraźniej można porównać liczbę ryb w jeziorze względem lat
# 2. Można łatwo prześledzić fluktuacje liczbowe danego danego gatunku ryby
# 3. Wykres ma osie i tytuł
# 4. Dodatkowo jest zawarta informacja o ilości ryb w całym jeziorze
# 5. Kategria other nie traci danych, ponieważ każdy gatunek, który da się odczytać z 
# oryginalnego wyresu bez zbędnego przybliżenia jest zawarty na wykresie kolumnowym.
# 6. Kolorsytyka czcionki jest jednakowa na całym wykresie


