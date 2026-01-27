
granice_gminne <- gminy_z_zaborami %>%
  filter(!is.na(partition)) %>%
  group_by(partition) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")


granice_powiatowe <- powiaty_z_zaborami %>%
  filter(!is.na(partition)) %>%
  group_by(partition) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")


#Praca
ggplot() +
  geom_sf(data = praca_mapa, aes(fill = rolnictwo_2023), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
    breaks = seq(1, 100, by = 10)
  ) +
  geom_sf(data = granice_powiatowe, fill = NA, color = "black", size = 0.5) +
  labs(title = "Procent ludności pracującej w rolnictwie") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    panel.grid.major = element_blank(),    
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),    
    axis.title = element_blank(),          
    axis.text = element_blank(),           
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
  )


ggplot() +
  geom_sf(data = praca_mapa, aes(fill = przemysl_2023), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
    breaks = seq(1, 100, by = 10)
  ) +
  geom_sf(data = granice_powiatowe, fill = NA, color = "black", size = 0.5) +
  labs(title = "Procent ludności pracującej w przemyśle") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    panel.grid.major = element_blank(),    
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),    
    axis.title = element_blank(),          
    axis.text = element_blank(),           
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
  )

# Matury
matura_matma_mapa <- st_as_sf(matura_matma_mapa, sf_column_name = "geometry")
matura_polski_mapa <- st_as_sf(matura_polski_mapa, sf_column_name = "geometry")

ggplot() +
  geom_sf(data = matura_polski_mapa, aes(fill = wynik.średni....), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
  ) +
  geom_sf(data = granice_gminne, fill = NA, color = "black", size = 0.5) +
  labs(title = "Wyniki matur polski") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    legend.title = element_text(size=9),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
  )

#wybory



ggplot() +
  geom_sf(data = wybory_2005, aes(fill = X.3), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
    limits = c(1, 100)
  ) +
  geom_sf(data = granice_gminne, fill = NA, color = "black", size = 0.5) +
  labs(title = "Wynik wyborów prezydenckich 2005 dla zwycięzkiego kandydata") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
  )


ggplot() +
  geom_sf(data = wybory_2025_mapa, aes(fill = wynik_procent), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
    limits = c(1, 100)
  ) +
  geom_sf(data = granice_gminne, fill = NA, color = "black", size = 0.4) +
  labs(title = "Wynik wyborów prezydenckich 2025 dla zwycięzkiego kandydata") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
  )


#Chrześcijanie

chrzescijanie_mapa <- st_as_sf(chrzescijanie_mapa, sf_column_name = "geometry")
ggplot() +
  geom_sf(data = chrzescijanie_mapa, aes(fill = Procent.wierzących), color = "gray80", size = 0.02) +
  scale_fill_gradientn(
    colors = c("darkblue", "lightblue", "yellow"),
    name = "Procent [%]",
    na.value = "grey",
    limits = c(1, 100)
  ) +
  geom_sf(data = granice_gminne, fill = NA, color = "black", size = 0.5) +
  labs(title = "Procent ludności należących do kościoła łacińskiego ") +
  theme(
    legend.key.size = unit(0.4, "cm"),
    legend.position = "right",
    legend.direction = "vertical",
    legend.text = element_text(size = 7),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    legend.key.width  = unit(0.5, "cm"),
    legend.key.height = unit(1, "cm")
    
  )



