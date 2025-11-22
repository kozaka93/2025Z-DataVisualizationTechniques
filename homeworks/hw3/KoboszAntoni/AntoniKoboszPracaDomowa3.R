library(dplyr)
library(tidyverse)
library(readr)
library(ggplot2)
library(maps)
library(mapdata)

df <- read.csv('Average_commute_times.csv')
df <- df %>% pivot_wider( names_from = year,values_from = avg_commute_time) 

world_map = map_data('world')

nazwy_w_worldmap <- world_map$region %>% unique()
nazwy_w_danych <- df$geo
nazwy_w_danych[! nazwy_w_danych %in% nazwy_w_worldmap] # czechy i wielka brytania maja inne nazwy

df <- df %>% mutate(geo = case_when( # zmieniam nazwy, na takie co w world_map
  geo == 'Czechia' ~ 'Czech Republic',
  geo == 'United Kingdom' ~ 'UK',
  .default = geo
))

world_map <-  world_map %>% left_join(df,by=c('region'='geo'))

min_val <- min(df$`2015`)
max_val <- max(df$`2015`)

Skrajne <- world_map %>% # znajduje kraje o min/max czasie dojazdu i licze ich wspolrzedne
  filter(`2015` %in% c(min_val,max_val)) %>% 
  group_by(region) %>% 
  summarise(lat = mean(lat),long = mean(long),Czas=first(`2015`))


mapka <- world_map %>% 
  filter(-35 <= long,long <= 65) %>% 
  filter(2 <= lat,lat <= 72) %>% 
  ggplot(aes(long,lat))+
  geom_polygon(aes(fill=`2015`,group = group), color = "black")+
  geom_label(data=Skrajne, 
    aes(x=long+2,y=lat+2,label=paste0(region," ",round(Czas),"min")))+
  coord_map("mercator",xlim = c(-25, 40),  ylim = c(30, 70))+
  scale_fill_gradient(na.value = 'grey',low = 'moccasin',high='sienna',
                      breaks = seq(20, 50, by = 5),
                      labels = paste0(seq(20, 50, by = 5), " min"),
                      guide = guide_colorbar(barwidth=1.5,barheight=9))+
  labs(x="",y="",fill="czas dojazdu\n(szary = brak danych)",
       title = 'Średni czas dojazdu miedzy pracą a domem w roku 2015.') + 
  theme_bw() +
  theme(axis.ticks = element_blank(),
        axis.text=element_blank(),
        legend.position = 'right',
        plot.title = element_text(face = "bold",size = 13),
        legend.title = element_text(face = "bold",size = 9)) 
mapka  

ggsave("CzasyDojazdow.pdf",plot=mapka,width=7,height=7,units = 'in')




