


biblioteki <- c("dplyr","tidyr","ggplot2","sf","eurostat","giscoR","ggrepel","showtext")

wczytaj_pakiety<-function(biblioteki){
  for (pakiet in biblioteki){
if (!requireNamespace(pakiet, quietly = TRUE)){
  install.packages(pakiet)
}
  library(pakiet,character.only = TRUE)
  }}
wczytaj_pakiety(biblioteki)

font_add_google("Roboto Slab", "font")
showtext_auto()
?font_add_google
## Dane

dane <- pivot_wider(get_eurostat(
  id = "demo_r_pjangroup",
  time_format = "num",
  filters = list(
    age = c("TOTAL","Y_LT5","Y5-9","Y10-14","Y15-19"),
    sex = "T",
    time = 2024
  )
),values_from = values,names_from = age)

dane<-filter(dane,nchar(dane$geo)==4) %>% 
  filter(.$geo!="FRY3") %>% #Gujana Francuska :D
  transmute(geo,TOTAL,młodzi=Y_LT5+`Y5-9`+`Y10-14`+`Y15-19`) %>% 
  transmute(geo,val=młodzi/TOTAL)

przedzialy<- c(0, 0.1, 0.15, 0.175, 0.20, 0.225, 0.25, 0.3, 0.35, 0.40, 0.45 ,0.50)
przedzialy_etykiety <- c(
  "0-10 %",
  "10-15 %",
  "15-17.5 %",
  "17.5-20 %",
  "20-22.5 %",
  "22.5-25 %",
  "25-30 %",
  "30-35 %",
  "35-40 %",
  "40-45 %",
  "45-50 %"
)

dane <- dane %>%
  mutate(
    kategorie = cut(
      val,                  
      breaks = przedzialy,
      labels = przedzialy_etykiety,
      right = FALSE                 
    )
  )

## Granice

mapa_nuts2 <- get_eurostat_geospatial(
  output_class = "sf",
  resolution = "60",
  nuts_level = 2,
  year = 2024
)

dane2 <- left_join(
  mapa_nuts2,
  dane,
  by = "geo"
)

levels(dane2$kategorie) <- c(levels(dane2$kategorie), "Brak danych")
dane2$kategorie[is.na(dane2$kategorie)] <- "Brak danych"

## Mapa

mapa<-ggplot(data = st_transform(dane2, 3034),aes(fill=kategorie)) + 
  geom_sf()+coord_sf(
    xlim = c(-16, 59),
    ylim = c(34, 72),
    crs = st_crs(3034),
    default_crs = st_crs(4326),
    expand = FALSE)+
  scale_fill_manual(name="Przedziały",values =c("#666666","darkgrey","grey","lightgrey","#98FB98","lightgreen","#32CD32","#3CB371","#2e7d32","white") ,na.value = "white")+
  geom_label_repel(
    data = subset(dane2, kategorie %in% c("10-15 %","40-45 %")),
    aes(label = NUTS_NAME, geometry = geometry),
    stat = "sf_coordinates",
    # min.segment.length = 0,
    family = "font",
    size = 5,
    color = "black",
    fill = "white",
    segment.color = "red",    
    max.overlaps = Inf,
    show.legend=FALSE
  ) +
  labs(title = "Udział ludzi w wieku 0-19 lat w całej populacji",subtitle = "Dla większości krajów europejskich na podstawie danych z Eurostatu.
       \nPożądana wartość wskaźnika wynosi przynajmniej około 25 %.")+
  theme(legend.title = element_text(family="font",size=32),
        legend.text = element_text(family="font",size=25),
        plot.title = element_text(family="font",size=50),
        plot.subtitle = element_text(family="font",size=40,lineheight = 0.15),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.justification = c(1, 1),
        legend.position = c(0.98, 0.98),
        legend.key.size = unit(0.4, "cm"),
        legend.background = element_rect(fill = "white", color = "black", size = 0.2), # Ramka i tło pod legendą
        legend.margin = margin(5, 5, 5, 5))


# ?ggsave
ggsave("mapa.png",path="homeworks/hw3/JanusiakKamil",plot=mapa,dpi=300,width = 6,height = 6)
# ?colorRampPalette()

