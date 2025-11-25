library(dplyr)
library(tidyr)
library(ggplot2)
library(crayon)
#dajemy dane
t2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2023_r._aneks_tabelaryczny.csv",fileEncoding="Windows-1250")
t2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2022_aneks_tabelaryczny.csv",fileEncoding="Windows-1250")
t2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2021_aneks_tabelaryczny.csv",fileEncoding="Windows-1250")
t2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2020_aneks_tabelaryczny.csv",fileEncoding="Windows-1250")
t2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2019_r._tablice_w_formacie_xls.csv",fileEncoding="Windows-1250")
t2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\aneks_tabelaryczny_2018.csv",fileEncoding="Windows-1250")
t2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\aneks_tabelaryczny_za_2017.csv",fileEncoding="Windows-1250")
t2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\km2\\zdrowie_i_ochrona_zdrowia_w_2016_roku_tablice.csv",fileEncoding="Windows-1250")
#czyścimy
t2023 <- t2023 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2023.R.,X.17,X.18,powrót.back,X.19,X.20))
t2023 <- t2023[-c(1,3,4,16,18,20,22,25,27,33:71), ]
t2022 <- t2022 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2022.R.,X.17,X.18,powrót.back,X.19,X.20))
t2022 <- t2022[-c(1,3,4,16,18,20,22,25,27,33:71), ]
t2021 <- t2021 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2021.R.,X.17,X.18,powrót.back,X.19,X.20))
t2021 <- t2021[-c(1,3,4,16,18,20,22,25,27,33:71), ]
#przekształcamy w normalną tabele bo excel jest do d.
df2023 <- as.data.frame(t2023)
df2023[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2023[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]
df2022 <- as.data.frame(t2022)
df2022[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2022[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]
df2021 <- as.data.frame(t2021)
df2021[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2021[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]
tibble2023 <- as_tibble(df2023)
tibble2022 <- as_tibble(df2022)
tibble2021 <- as_tibble(df2021)
#z tibbli próbujemy zrobić wykres
tibble2023 <- tibble2023 %>% 
  mutate(rok=2023)
tibble2022 <- tibble2022 %>% 
  mutate(rok=2022)
tibble2021 <- tibble2021 %>% 
  mutate(rok=2021)
tibble <- bind_rows(tibble2023,tibble2022,tibble2021)
#wait lemme thin
#thetibble <- tibble %>% 
#  pivot_longer(cols=-rok,names_to="zmienna",values_to="wartosc")
wykres <- tibble %>% 
  ggplot(aes(x = CHOROBY, y = "wartosc", fill = c("Dolno-śląskie","Kujawsko-pomorskie","Lubelskie","Lubuskie","Łódzkie","Mało-polskie","Mazo-wieckie","Opolskie","Podkar-packie","Podlaskie","Pomorskie","Śląskie","Święto-krzyskie","Warmiń-sko-mazur-skie","Wielko-polskie","Zacho-dniopo-morskie"))) +
  geom_line()

