path <- "C:/Users/gabri/OneDrive/Pulpit/TechnikiWizualizacjiDanych/strzelecka_wroblewska_zaleska"

setwd(path)



##### WCZYTANIE DANYCH

# wszystkie dane sa za 2024 rok
stypendia <- read.csv("kody/dane/stypendia.csv", sep = ";")
przystanki <- read.csv("kody/dane/przystanki.csv", sep = ";")
linie <- read.csv("kody/dane/linieKomunikacji.csv", sep = ";")
wydarzenia <- read.csv("kody/dane/wydarzenia.csv", sep = ";")
biblioteki <- as.data.frame(read.csv("kody/dane/biblioteki.csv", sep = ";"))
akademiki <- read.csv("kody/dane/akademiki.csv", header = TRUE, sep = ";")

colnames(stypendia) <- c("kod", "terytorium", "ogolem", "socjalne", "rektora", "niepelnosprawnych", "udział_studentow")
colnames(przystanki) <- c("kod", "terytorium", "autobus_trolejbus_tramwaj_tramwajowoautobusowy", "autobus_trolejbus_tramwaj", "autobus_trolejbus", "tramwaj", "tramwajowoautobusowy")
colnames(linie) <- c("kod", "terytorium", "liczba_linii", "dlugosc_linii_na_1000_mieszkancow", "wiejskie", "autobusowe", "tramwajowe")



##### KOLORY I CZCIONKA PLAKATU

c1 <- '#FDC718FF'
c2 <- '#1D373AFF' #najciemniejszy
c3 <- '#3E938BFF'
c4 <- '#73D8FEFF' #najasniejszy
c5 <- '#1942CDFF'

#   importowanie czcionek:
# font_import() 
#   zaladuj czcionki dla Windows:
# loadfonts(device = "win")  
fnt <- "Bahnschrift"



##### PAKIETY

library(ggplot2)
library(tidyr)
library(dplyr)
library(extrafont)
library(sf)
library(ggplot2)
library(ggnewscale)
library(scatterpie)
library(fmsb)
library(readxl)
library(stringr)
library(wordcloud2)



##### WYKRES 1 - liczba stypendiow przyznanym studentom w danych wojewodztwach i ich struktura

# dane gml wspolrzednych wojewodztw
gml_path <- "kody/dane/granice.gml"  # <— TU WSTAW SWÓJ PLIK

woj <- st_read(gml_path, quiet = TRUE) %>%
  st_make_valid()  


woj <- woj %>% mutate(region = toupper(JPT_NAZWA_))

# transformacja do WGS84 (jeśli GML nie jest w 4326) (PRG bywa w EPSG:2180)
if (st_crs(woj)$epsg != 4326) {
  woj <- st_transform(woj, 4326)
}

# nie potrzebujemy danych dla Polski ogolnie
df2 <- stypendia %>%
  filter(kod != 0) %>%
  mutate(region = toupper(terytorium))

# laczymy dane o stypendiach z danymi wspolrzednych
mapdf <- woj %>% left_join(df2, by = "region")

mapdf <- st_transform(mapdf, 2180)

# punkty do kół
centroids <- st_point_on_surface(mapdf) 
cent_xy   <- st_coordinates(centroids) %>% as.data.frame()

centers <- centroids %>%
  st_drop_geometry() %>%
  transmute(
    region,
    socjalne = socjalne,
    rektora = rektora,
    niepelnosprawnych = niepelnosprawnych,
    ogolem = ogolem
  ) %>%
  bind_cols(cent_xy)  

# kola ustawienia
bbox <- st_bbox(mapdf)
pie_radius <- 0.02 * (bbox$xmax - bbox$xmin)

# wykres
ggplot() +
  geom_sf(data = mapdf, aes(fill = ogolem), color = "white", size = 0.25) +
  scale_fill_gradient(
    low = c3,  
    high = c2, 
    trans = "sqrt",   
    name = "Stypendia (ogółem)"
  ) +
  ggnewscale::new_scale_fill() +
  geom_scatterpie(
    data = centers,
    aes(x = X, y = Y),
    cols = c("socjalne", "rektora", "niepelnosprawnych"),
    color = NA,
    pie_scale = 2.4 
  ) +
  scale_fill_manual(
    values = c(
      socjalne = "black",  
      rektora = c1,   
      niepelnosprawnych = "white"  
    ),
    name = "Typ stypendium"
  ) +
  coord_sf() +
  labs(
    title = "Stypendia w województwach:\nliczba ogółem (mapa) i struktura (koła)",
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    plot.title = element_text(size = 20, vjust = 7, family = fnt),
    axis.title.x = element_text(size = 15, margin = margin(t = 10), family = fnt),
    axis.title.y = element_text(size = 15, margin = margin(r = 20), family = fnt),
    axis.text.x = element_text(vjust = 6, family = fnt),
    axis.text.y = element_text(hjust = 1, family = fnt),
    legend.title = element_text(family = fnt, size = 12),
    legend.text = element_text(family = fnt, size = 12)
    
  )



##### WYKRES 2 - wykres przedstawiajacy liczbe lini komunikacyjnych roznego typu w przeliczeniu na powierzchnie wojewodztwa

# wybieramy typy komunikacji, ktore beda nas interesowac
linie <- as.data.frame(linie[2:nrow(linie), c("terytorium", "wiejskie", "autobusowe", "tramwajowe")])

linie <- linie %>% mutate(wiejskie = as.numeric(gsub(",", ".", wiejskie)), autobusowe = as.numeric(gsub(",", ".", autobusowe)), tramwajowe = as.numeric(gsub(",", ".", tramwajowe)))

# dane o powierzchni takze pochodza z GUS dane lokalne, link na plakacie
linie$powierzchnia <- c(
  19946.6, 17973.3, 25123.0, 13997.5, 18218.0, 
  11934.5, 35654.2, 9802.5, 17846.0, 20159.0, 
  18623.0, 12333.7, 11631.3, 24173.0, 29829.1, 
  22292.0
)

# przeliczamy na powierzchnie
linie <- linie %>% mutate(wiejskie = wiejskie/powierzchnia, autobusowe = autobusowe/powierzchnia, tramwajowe = tramwajowe/powierzchnia)

dane_long <- linie %>% pivot_longer(cols = c("wiejskie", "autobusowe", "tramwajowe"), names_to = "linie", values_to = "liczba") %>% 
  mutate(liczba = as.numeric(gsub(",", ".", liczba)))

ggplot(dane_long, aes(x = terytorium, y = liczba, color = linie)) +
  geom_segment(aes(xend = terytorium, yend = 0), size = 1) +  # Linie lollipop
  geom_point(size = 4) +  # Punkty na końcu linii
  facet_grid(linie ~ ., scales = "free_y") +  # Tworzymy 3 panele, po jednym dla każdego typu linii
  labs(title = "Liczba linii transportowych danego typu na kilometr\nkwadratowy powierzchni danego województwa", 
       x = "Województwo", 
       y = "Liczba linii na kilometr kwadratowy", color = "Rodzaj linii") +
  scale_color_manual(values = c(c1,c2,c3)) +
  theme_minimal(base_family = fnt) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
  plot.title.position = "plot",
  plot.title = element_text(size = 20, margin = margin(b = 25), family = fnt),
  axis.title.x = element_text(size = 12, margin = margin(t = 20)),
  axis.title.y = element_text(size = 12, margin = margin(r = 20)),
  strip.text.y = element_blank(),
  legend.title = element_text(size = 12),
  legend.text = element_text(size = 12),
)



#### WYKRES 3 - wykres przedstawiajacy jak duzy odsetek w danym wojewodztwie korzysta z akademikow (co moze oznaczac ze 
# dostepnosc akademikow jest lepsza, standard wyzszy, sa fajniejsze)

# ładne nazywanie kolumn

akademiki <- rename(akademiki, domy_studenckie = domy.studenckie.2024..ob..)
akademiki <- rename(akademiki, miejsca_dostepne = miejsca.w.domach.studenckich.2024..msc..)
akademiki <- rename(akademiki, miejsca_zajete = studenci.korzystający.z.domów.studenckich.2024..osoba.)
akademiki <- rename(akademiki, ile_procent_studentow_korzysta = studenci.korzystający.z.domów.studenckich.w...ogółu.studentów.2024....)

# aby mogły być liczby w teh kolumnie to musi być '.' zamiast ','
akademiki$ile_procent_studentow_korzysta <- gsub(",", ".", akademiki$ile_procent_studentow_korzysta)
akademiki$ile_procent_studentow_korzysta <- as.numeric(akademiki$ile_procent_studentow_korzysta)

# będziemy robić wykres MAPA POLSKI

url <- "https://www.geoboundaries.org/data/geoBoundaries-3_0_0/POL/ADM1/geoBoundaries-3_0_0-POL-ADM1.geojson"

poland <- st_read(url)

akademiki <- rename(akademiki, shapeName = Nazwa)
akademiki <- akademiki[akademiki$shapeName != "POLSKA",]
akademiki$shapeName

poland$shapeName = c("PODKARPACKIE", "PODLASKIE", "ŁÓDZKIE", "DOLNOŚLĄSKIE", "OPOLSKIE", "ŚWIĘTOKRZYSKIE", 
                     "MAZOWIECKIE", "WIELKOPOLSKIE", "MAŁOPOLSKIE", "LUBUSKIE", "KUJAWSKO-POMORSKIE",
                     "POMORSKIE", "ZACHODNIOPOMORSKIE", "LUBELSKIE", "WARMIŃSKO-MAZURSKIE", "ŚLĄSKIE")

mapa <- poland %>%
  left_join(akademiki, by = "shapeName")

ggplot(mapa) +
  geom_sf(aes(fill = ile_procent_studentow_korzysta), color = "white") +
  scale_fill_gradient(
    low = "white",  # Jasnoniebieski (odcień dla mniejszych wartości)
    high = c1, # Ciemnoniebieski (odcień dla większych wartości)
    trans = "sqrt"
  ) +
  labs(title = "Jaki procent studentów w danym\nwojewództwie korzysta z akademików",
       fill = "Procent studentów") +
  theme_minimal(base_family = fnt) +
  theme(
    panel.grid = element_blank(),
    plot.title = element_text(size = 20, family = fnt),
    axis.title.x = element_text(size = 15, margin = margin(t = 10), family = fnt),
    axis.title.y = element_text(size = 15, margin = margin(r = 20), family = fnt),
    axis.text.x = element_text(vjust = 6, family = fnt),
    axis.text.y = element_text(hjust = 1, family = fnt),
    legend.title = element_text(family = fnt, size = 12),
    legend.text = element_text(family = fnt, size = 12)
    
  )



##### WYKRES 4 - wykres przedstawiajacy liczbe wydarzen potencjalnie interesujacych dla studentow w poszczegolnych miastach

colnames(wydarzenia)[1:9] <- c("kod", "miasto", "ogolem", "artystycznorozrywkowe", "koncerty", "przedstawieniaispektakle", "seansefilmowe", "festiwale", "kabarety")
wydarzenia[,2] <- c("Wrocław", "Lublin", "Kraków", "Warszawa", "Gdańsk", "Poznań")

wydarzenia_grouped <- wydarzenia %>% 
  select("miasto", "artystycznorozrywkowe", "koncerty", "przedstawieniaispektakle", "festiwale", "kabarety") %>% 
  pivot_longer(cols = c("artystycznorozrywkowe", "koncerty", "przedstawieniaispektakle", "festiwale", "kabarety"), names_to = "typwydarzenia", values_to = "liczbawydarzen")
 
# rozdzielamy na dwie podkategorie, poniewaz wydarzen artystycznorozrywkowych i koncertow jest znacznie weiecej niz
# pozostalych wydarzen, dlatego przedstawimy na osobnych skalach

wydarzenia_grouped1 <- wydarzenia_grouped %>% 
  filter(typwydarzenia %in% c("artystycznorozrywkowe", "koncerty"))
wydarzenia_grouped2 <- wydarzenia_grouped %>% 
  filter(typwydarzenia %in% c("przedstawieniaispektakle", "kabarety", "festiwale"))

# wykres dla 1 grupy
ggplot(wydarzenia_grouped1, aes(x=miasto, y=typwydarzenia, fill = liczbawydarzen) )+
  geom_tile(color="white") +
    labs(
      title = "Wydarzenia potencjalnie interesujące dla\nstudentów z podziałem na miasta",
      x = "Miasto", 
      y = "Typ wydarzenia", 
      fill = "Liczba wydarzeń"
    ) + 
    scale_fill_gradient2(low = "white", mid = c3, high = c2, midpoint = 100) +
    theme_minimal(base_family = fnt) + 
  scale_y_discrete(
    labels = c(przedstawieniaispektakle = "przedstawienia i spektakle", artystycznorozrywkowe = "artystyczno rozrywkowe")
  ) +
    theme(
      plot.title = element_text(size = 20, margin = margin(b = 25), hjust = 0.5),
      axis.title.x = element_text(size = 12, margin = margin(t = 15)),
      axis.title.y = element_text(size = 12, hjust = 0.55, margin = margin(r = 15)),
      axis.text.x = element_text(angle = 90, vjust = 0.3),
      axis.text.y = element_text(hjust = 1),
      plot.margin = unit(c(1, 1, 1, 1), "cm") )

# wykres dla 2 grupy
ggplot(wydarzenia_grouped2, aes(x=miasto, y=typwydarzenia, fill = liczbawydarzen) )+
  geom_tile(color="white") +
  labs(
    title = "Wydarzenia potencjalnie interesujące dla\nstudentów z podziałem na miasta",
    x = "Miasto", 
    y = "Typ wydarzenia", 
    fill = "Liczba wydarzeń"
  )  +
  scale_fill_gradient2(low = "white", mid = "#F8E0A4", high = c1, midpoint = 15) +
  theme_minimal(base_family = fnt) + 
  scale_y_discrete(
    labels = c(przedstawieniaispektakle = "przedstawienia i spektakle")
  ) +
  theme(
    plot.title = element_text(face = 'bold', size = 20, margin = margin(b = 25), hjust = 0.5),
    axis.title.x = element_text(size = 12, margin = margin(t = 15)),
    axis.title.y = element_text(size = 12, hjust = 0.55, margin = margin(r = 15)),
    axis.text.x = element_text(angle = 90, vjust = 0.3),
    axis.text.y = element_text(hjust = 1),
    plot.margin = unit(c(1, 1, 1, 1), "cm") )



##### WYKRES 5 - slowa przedstawiajace liczbe studentow w danym wojewodztwie (wieksze slowo wiecej studentow)

excel_sheets("kody/dane/szkolnictwo.xlsx")

dane <- read_excel(
  "kody/dane/szkolnictwo.xlsx",
  sheet = "Ogolem",
  skip = 5,
  col_names = FALSE
)

woj <- dane %>%
  filter(str_detect(...1, "kie$")) %>%
  select(wojewodztwo = ...1, liczba_studentow = ...9) %>%
  mutate(
    liczba_studentow = as.numeric(liczba_studentow)
  ) %>%
  distinct(wojewodztwo, .keep_all = TRUE)

woj2 <- dane %>%
  filter(str_detect(...1, "kie$")) %>%
  filter(!str_detect(...2, "Ogółem")) %>%
  select(
    wojewodztwo = ...1,
    uczelnia = ...2
  ) %>%
  group_by(wojewodztwo) %>%
  summarise(
    liczba_uczelni = n_distinct(uczelnia)
  )

max_stud <- max(woj$liczba_studentow)
max_uczelni <- max(woj2$liczba_uczelni)

liczba_studentow <- woj %>%
  select(wojewodztwo,liczba_studentow) %>%
  mutate(
    color = case_when(
      liczba_studentow > (max_stud/3*2) ~ c2,
      liczba_studentow > (max_stud/3) ~ c3,
      TRUE ~ c1
    )
  )
# wykres wieksze slowo - wiecej studentow
wordcloud2(data = liczba_studentow, size = 0.6, color = liczba_studentow$color)


##### WYKRESY NIEWYKORZYSTANE - informacje mniej ciekawe

# Wykres slowa, ale z liczba uczelni nie studentow
liczba_stud_sorted <- liczba_studentow %>%
  arrange(desc(liczba_studentow))

liczba_uczelni<- woj2 %>%
  select(wojewodztwo,liczba_uczelni) %>%
  mutate(
    color = case_when(
      liczba_uczelni > (max_uczelni/3*2) ~ c2,
      liczba_uczelni >  (max_uczelni/3)~ c3,
      TRUE ~ c1
    )
  )

wordcloud2(data = liczba_uczelni, size=0.4, color = liczba_uczelni$color)

# Wykres pokazujacy jak zmienial sie procent wykorzystanych miejsc w akademikach
akademiki_miejsca_polska <- read.csv("kody/dane/akademiki_miejsca_polska.csv", header = TRUE, sep = ";")

liczba_miejsc <- unlist(akademiki_miejsca_polska[,c(3:8)])

liczba_studentow <- unlist(akademiki_miejsca_polska[,c(9:14)])

dane = data.frame(
  rok = c(2019:2024),
  liczba_miejsc_dostepnych = liczba_miejsc,
  liczba_miejsc_wykorzystanych = liczba_studentow,
  procent_miejsc_wykorzystanych = (liczba_studentow / liczba_miejsc) * 100
)

dane %>% 
  ggplot(aes(x = rok, y = procent_miejsc_wykorzystanych)) + 
  geom_line(size = 1.2, color = c3) +
  labs(title = "Jak się zmieniał procent wykorzystanych miejsc w akademikach\nw latach 2019 - 2024",
       y = "procent wykorzystanych miejsc", x = "rok") + 
  scale_y_continuous(limits = c(35, 75)) +
  theme_minimal(base_family = fnt) +
  theme(
    panel.grid = element_blank(),
    plot.title = element_text(size = 20, family = fnt),
    axis.title.x = element_text(size = 15, margin = margin(t = 10), family = fnt),
    axis.title.y = element_text(size = 15, margin = margin(r = 20), family = fnt),
    axis.text.x = element_text(vjust = 6, family = fnt),
    axis.text.y = element_text(hjust = 1, family = fnt),
    legend.title = element_text(family = fnt, size = 12),
    legend.text = element_text(family = fnt, size = 12)
    
  )

# Wykres pokazujacy liczbe przystankow w danych miastach
przystanki[1, 2] <- "Wrocław"
przystanki[2, 2] <- "Lublin"
przystanki[3, 2] <- "Kraków"
przystanki[4, 2] <- "Warszawa"
przystanki[5, 2] <- "Gdańsk"
przystanki[6, 2] <- "Poznań"

df_long <- przystanki %>%
  select(terytorium, autobus_trolejbus, tramwaj, tramwajowoautobusowy) %>%
  pivot_longer(cols = c(autobus_trolejbus, tramwaj, tramwajowoautobusowy),
               names_to = "typ_transportu",
               values_to = "liczba")

ggplot(df_long, aes(x = terytorium, y = liczba, fill = typ_transportu)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("autobus_trolejbus" = c4,
                               "tramwaj" = c3,
                               "tramwajowoautobusowy" = c2),
                    labels = c("autobus_trolejbus" = "autobusowo-trolejbusowe",
                               "tramwaj" = "tramwajowe",
                               "tramwajowoautobusowy" = "tramwajowo-autobusowe")) +
  labs(
    title = "Liczba przystanków różnego typu w poszczególnych miastach",
    x = "miasto",
    y = "liczba przystanków",
    fill = "Typ przystanku"
  ) +
  theme_minimal() +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(size = 20, margin = margin(b = 10), family = fnt),
    axis.title.x = element_text(size = 15, margin = margin(t = 10), family = fnt),
    axis.title.y = element_text(size = 15, margin = margin(r = 20), family = fnt),
    axis.text.x = element_text(vjust = 6, family = fnt, colour = c1),
    legend.title = element_text(family = fnt, size = 15),
    legend.text = element_text(family = fnt, size = 12)
  )



# Wykres przedstawiajacy dostepnosc komputerow, komputerow z internetem i internetu bezprzewodowego w bibliotekach w danych miastach
colnames(biblioteki) <- c("kod", "nazwa", "K_uzytkowane", "K_uzytkowane_dost_dla_czyt", "K_podlaczone_do_internetu_dost_dla_czyt", "internet_bezprzewodowy", "a", "b", "c")
biblioteki[,2] <- c("Wrocław", "Lublin", "Kraków", "Warszawa", "Gdańsk", "Poznań")

a <- biblioteki %>%
  select(nazwa, K_uzytkowane_dost_dla_czyt, K_podlaczone_do_internetu_dost_dla_czyt, internet_bezprzewodowy ) %>% 
  pivot_longer(cols = c("K_uzytkowane_dost_dla_czyt", "K_podlaczone_do_internetu_dost_dla_czyt", "internet_bezprzewodowy" ),
               names_to = "komputery",
               values_to = "liczba")

ggplot(a, aes(x = nazwa, y = liczba, fill = komputery)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = liczba),
            position = position_dodge(width = 0.8),
            vjust = -0.2, size = 3) +
  scale_fill_manual(
    values = c(c1, c2, c3),
    name = "Dostępne dla czytelników",
    labels = c("internet bezprzewodowy",
               "komputery podłączone do internetu",
               "komputery")
  ) +
  labs(
    title = "Liczba udogonień dostępnych dla czytelników bibliotek w poszczególnych miastach",
    x = "Miasto",
    y = "Liczba"
  ) +
  theme_minimal(base_family = fnt) +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(size = 20, margin = margin(b = 10)),
    axis.title.x = element_text(size = 12, margin = margin(t = 10)),
    axis.title.y = element_text(size = 12, margin = margin(r = 20)),
    axis.text.x = element_text(vjust = 6),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12),
  )




