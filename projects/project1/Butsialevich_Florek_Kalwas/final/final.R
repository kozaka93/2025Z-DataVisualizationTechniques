library(dplyr)
library(tidyr)
library(ggplot2)
library(crayon)
#dajemy dane
t_1_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab01.csv",sep=",",fileEncoding="UTF-8")
t_1_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab01.csv",sep=",",fileEncoding="UTF-8")

t_2_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab02_.csv",sep=",",fileEncoding="UTF-8")
t_2_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab02_.csv",sep=",",fileEncoding="UTF-8")

t_3_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab03_.csv",sep=",",fileEncoding="UTF-8")
t_3_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab03_.csv",sep=",",fileEncoding="UTF-8")

t_4_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab04_.csv",sep=",",fileEncoding="UTF-8")
t_4_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab04_.csv",sep=",",fileEncoding="UTF-8")

t_5_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab05_.csv",sep=",",fileEncoding="UTF-8")
t_5_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab05_.csv",sep=",",fileEncoding="UTF-8")
#czyścimy
t_1_2023 <- t_1_2023 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2023.R.,Unnamed..19,Unnamed..20,powrót.back))
t_1_2023 <- t_1_2023[-c(1,3,4,16,18,20,22,25,27,33:71), ]
t_1_2022 <- t_1_2022 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2022.R.,Unnamed..19,Unnamed..20,powrót.back))
t_1_2022 <- t_1_2022[-c(1,3,4,16,18,20,22,25,27,33:71), ]
t_1_2021 <- t_1_2021 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2021.R.,Unnamed..19,Unnamed..20,powrót.back))
t_1_2021 <- t_1_2021[-c(1,3,4,16,18,20,22,25,27,33:71), ]
t_1_2020 <- t_1_2020 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2020.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t_1_2020 <- t_1_2020[-c(1,3,4,16,18,21,23,29:63), ]
t_1_2019 <- t_1_2019 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2019.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t_1_2019 <- t_1_2019[-c(1,3,4,16,18,21,23,29:63), ]
t_1_2018 <- t_1_2018 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2018.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t_1_2018 <- t_1_2018[-c(1,3,4,16,18,21,23,29:63), ]
t_1_2017 <- t_1_2017 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2017.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t_1_2017 <- t_1_2017[-c(1,3,4,16,18,21,23,29:63), ]
t_1_2016 <- t_1_2016[-c(1,3,4,9,11,13,17,19,20,22,23,25,27,28,30,31,33,35,40:85), ]

t_2_2023 <- t_2_2023 %>%
  select(-c(ZACHOROWANIA.NA.GRUŹLICĘa..WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2023 <- t_2_2023[-c(1,2,4,5,23:27), ]
t_2_2022 <- t_2_2022 %>% 
  select(-c(ZACHOROWANIA.NA.GRUŹLICĘa..WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2022 <- t_2_2022[-c(1,2,4,5,23:27), ]
t_2_2021 <- t_2_2021 %>% 
  select(-c(NOWE.PRZYPADKI.ZACHOROWANIA.NA.GRUŹLICĘ.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2021 <- t_2_2021[-c(1,2,4,5,23:25), ]
t_2_2020 <- t_2_2020 %>% 
  select(-c(NOWE.PRZYPADKI.ZACHOROWANIA.NA.GRUŹLICĘ.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2020 <- t_2_2020[-c(1,2,4,5,23:25), ]
t_2_2019 <- t_2_2019 %>% 
  select(-c(NOWE.PRZYPADKI.ZACHOROWANIA.NA.GRUŹLICĘ.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2019 <- t_2_2019[-c(1,2,4,5,23:25), ]
t_2_2018 <- t_2_2018 %>% 
  select(-c(NOWE.PRZYPADKI.ZACHOROWANIA.NA.GRUŹLICĘ.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2018 <- t_2_2018[-c(1:3,5:8,26:28), ]
t_2_2017 <- t_2_2017 %>% 
  select(-c(NOWE.PRZYPADKI.ZACHOROWANIA.NA.GRUŹLICĘ.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_2_2017 <- t_2_2017[-c(1:3,5:8,26:28), ]
t_2_2016 <- t_2_2016 %>% 
  select(-c(Unnamed..1,Unnamed..4,Unnamed..5,Unnamed..6))
t_2_2016 <- t_2_2016[-c(1:3,5:9,27:29), ]

t_3_2023 <- t_3_2023 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNEa..WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2023 <- t_3_2023[-c(1,2,4,5,23:27), ]
t_3_2022 <- t_3_2022 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNEa..WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2022 <- t_3_2022[-c(1,2,4,5,23:27), ]
t_3_2021 <- t_3_2021 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2021 <- t_3_2021[-c(1,2,4,5,23:25), ]
t_3_2020 <- t_3_2020 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2020 <- t_3_2020[-c(1,2,4,5,23:25), ]
t_3_2019 <- t_3_2019 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2019 <- t_3_2019[-c(1,2,4,5,23:25), ]
t_3_2018 <- t_3_2018 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2018 <- t_3_2018[-c(1:3,5:9,27:29), ]
t_3_2017 <- t_3_2017 %>% 
  select(-c(ZACHOROWANIA.NA.CHOROBY.WENERYCZNE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..6,Unnamed..7,Unnamed..8,Unnamed..9,powrót.back))
t_3_2017 <- t_3_2017[-c(1:3,5:9,27:29), ]
t_3_2016 <- t_3_2016 %>% 
  select(-c(Unnamed..1,Unnamed..4,Unnamed..5,Unnamed..6))
t_3_2016 <- t_3_2016[-c(1:3,5:10,28:30), ]

t_4_2023 <- t_4_2023 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..21,Unnamed..20,powrót.back))
t_4_2023 <- t_4_2023[-c(1,3:7,19:43), ]
t_4_2022 <- t_4_2022 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..21,Unnamed..20,powrót.back))
t_4_2022 <- t_4_2022[-c(1,3:7,19:43), ]
t_4_2021 <- t_4_2021 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..15,powrót.back))
t_4_2021 <- t_4_2021[-c(1,2,4:8,25:55), ]
t_4_2020 <- t_4_2020 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..15,powrót.back))
t_4_2020 <- t_4_2020[-c(1,2,4:8,25:55), ]
t_4_2019 <- t_4_2019 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..15,powrót.back))
t_4_2019 <- t_4_2019[-c(1,2,4:8,25:55), ]
t_4_2018 <- t_4_2018 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..15,powrót.back))
t_4_2018 <- t_4_2018[-c(1,2,4:8,25:55), ]
t_4_2017 <- t_4_2017 %>% 
  select(-c(ZACHOROWANIA.NA.NOWOTWORY.ZŁOŚLIWE.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..3,Unnamed..15,powrót.back))
t_4_2017 <- t_4_2017[-c(1,2,4:8,25:55), ]
t_4_2016 <- t_4_2016 %>% 
  select(-c(Unnamed..1))
t_4_2016 <- t_4_2016[-c(1,2,4:9,26:54), ]

t_5_2023 <- t_5_2023 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,powrót.back))
t_5_2023 <- t_5_2023[-c(1,3:6,17,19,24,28:63), ]
t_5_2022 <- t_5_2022 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,powrót.back))
t_5_2022 <- t_5_2022[-c(1,3:6,17,19,24,28:63), ]
t_5_2021 <- t_5_2021 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,powrót.back))
t_5_2021 <- t_5_2021[-c(1,3:6,17,19,24,28:63), ]
t_5_2020 <- t_5_2020 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,powrót.back))
t_5_2020 <- t_5_2020[-c(1,3:6,17,19,24,28:63), ]
t_5_2019 <- t_5_2019 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,Unnamed..22,powrót.back))
t_5_2019 <- t_5_2019[-c(1,3:6,17,19,24,28:63), ]
t_5_2018 <- t_5_2018 %>% 
  select(-c(OSOBY.LECZONE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,Unnamed..22,powrót.back))
t_5_2018 <- t_5_2018[-c(1,3:6,17,19,24,28:63), ]
t_5_2017 <- t_5_2017 %>% 
  select(-c(OSOBY.ZAREJESTROWANE.W.PORADNIACH.DLA.OSÓB.Z.ZABURZENIAMI.PSYCHICZNYMI..UZALEŻNIONYCH.OD.ALKOHOLU.I.INNYCH.SUBSTANCJI.WEDŁUG.WOJEWÓDZTW,Unnamed..2,Unnamed..20,Unnamed..21,Unnamed..22,powrót.back))
t_5_2017 <- t_5_2017[-c(1,3:6,17,19,24,28:63), ]
t_5_2016 <- t_5_2016 %>% 
  select(-c(Unnamed..18,Unnamed..19))
t_5_2016 <- t_5_2016[-c(1,3:7,18,20,25,29:62), ]
#przekształcamy w df _1_
df2023 <- as.data.frame(t_1_2023)
df2023[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2023[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
df2023[1,2] <- "POLSKA"
df2023[1,3] <- "Dolnośląskie"
df2023[1,4] <- "Kujawsko-pomorskie"
df2023[1,5] <- "Lubelskie"
df2023[1,6] <- "Lubuskie"
df2023[1,7] <- "Łódzkie"
df2023[1,8] <- "Małopolskie"
df2023[1,9] <- "Mazowieckie"
df2023[1,10] <- "Opolskie"
df2023[1,11] <- "Podkarpackie"
df2023[1,12] <- "Podlaskie"
df2023[1,13] <- "Pomorskie"
df2023[1,14] <- "Śląskie"
df2023[1,15] <- "Świętokrzyskie"
df2023[1,16] <- "Warmińsko-mazurskie"
df2023[1,17] <- "Wielkopolskie"
df2023[1,18] <- "Zachodniopomorskie"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t_1_2022)
df2022[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2022[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
df2022[1,2] <- "POLSKA"
df2022[1,3] <- "Dolnośląskie"
df2022[1,4] <- "Kujawsko-pomorskie"
df2022[1,5] <- "Lubelskie"
df2022[1,6] <- "Lubuskie"
df2022[1,7] <- "Łódzkie"
df2022[1,8] <- "Małopolskie"
df2022[1,9] <- "Mazowieckie"
df2022[1,10] <- "Opolskie"
df2022[1,11] <- "Podkarpackie"
df2022[1,12] <- "Podlaskie"
df2022[1,13] <- "Pomorskie"
df2022[1,14] <- "Śląskie"
df2022[1,15] <- "Świętokrzyskie"
df2022[1,16] <- "Warmińsko-mazurskie"
df2022[1,17] <- "Wielkopolskie"
df2022[1,18] <- "Zachodniopomorskie"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t_1_2021)
df2021[13,1] <- "Zapalenie jelit wywołane przez rotawirusy"
df2021[14,1] <- "Zapalenie jelit wywołane przez clostridium difficile"
df2021[1,2] <- "POLSKA"
df2021[1,3] <- "Dolnośląskie"
df2021[1,4] <- "Kujawsko-pomorskie"
df2021[1,5] <- "Lubelskie"
df2021[1,6] <- "Lubuskie"
df2021[1,7] <- "Łódzkie"
df2021[1,8] <- "Małopolskie"
df2021[1,9] <- "Mazowieckie"
df2021[1,10] <- "Opolskie"
df2021[1,11] <- "Podkarpackie"
df2021[1,12] <- "Podlaskie"
df2021[1,13] <- "Pomorskie"
df2021[1,14] <- "Śląskie"
df2021[1,15] <- "Świętokrzyskie"
df2021[1,16] <- "Warmińsko-mazurskie"
df2021[1,17] <- "Wielkopolskie"
df2021[1,18] <- "Zachodniopomorskie"
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t_1_2020)
df2020[12,1] <- "Inne bakteryjne zatrucia pokarmowe"
df2020[15,1] <- "	Bakteryjne zapalenie opon mózgowych i/lub mózgu"
df2020[16,1] <- "	Wirusowe zapalenie opon mózgowych"
df2020[1,2] <- "POLSKA"
df2020[1,3] <- "Dolnośląskie"
df2020[1,4] <- "Kujawsko-pomorskie"
df2020[1,5] <- "Lubelskie"
df2020[1,6] <- "Lubuskie"
df2020[1,7] <- "Łódzkie"
df2020[1,8] <- "Małopolskie"
df2020[1,9] <- "Mazowieckie"
df2020[1,10] <- "Opolskie"
df2020[1,11] <- "Podkarpackie"
df2020[1,12] <- "Podlaskie"
df2020[1,13] <- "Pomorskie"
df2020[1,14] <- "Śląskie"
df2020[1,15] <- "Świętokrzyskie"
df2020[1,16] <- "Warmińsko-mazurskie"
df2020[1,17] <- "Wielkopolskie"
df2020[1,18] <- "Zachodniopomorskie"
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t_1_2019)
df2019[12,1] <- "Inne bakteryjne zatrucia pokarmowe"
df2019[15,1] <- "	Bakteryjne zapalenie opon mózgowych i/lub mózgu"
df2019[16,1] <- "	Wirusowe zapalenie opon mózgowych"
df2019[1,2] <- "POLSKA"
df2019[1,3] <- "Dolnośląskie"
df2019[1,4] <- "Kujawsko-pomorskie"
df2019[1,5] <- "Lubelskie"
df2019[1,6] <- "Lubuskie"
df2019[1,7] <- "Łódzkie"
df2019[1,8] <- "Małopolskie"
df2019[1,9] <- "Mazowieckie"
df2019[1,10] <- "Opolskie"
df2019[1,11] <- "Podkarpackie"
df2019[1,12] <- "Podlaskie"
df2019[1,13] <- "Pomorskie"
df2019[1,14] <- "Śląskie"
df2019[1,15] <- "Świętokrzyskie"
df2019[1,16] <- "Warmińsko-mazurskie"
df2019[1,17] <- "Wielkopolskie"
df2019[1,18] <- "Zachodniopomorskie"
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t_1_2018)
df2018[12,1] <- "Inne bakteryjne zatrucia pokarmowe"
df2018[15,1] <- "	Bakteryjne zapalenie opon mózgowych i/lub mózgu"
df2018[16,1] <- "	Wirusowe zapalenie opon mózgowych"
df2018[1,2] <- "POLSKA"
df2018[1,3] <- "Dolnośląskie"
df2018[1,4] <- "Kujawsko-pomorskie"
df2018[1,5] <- "Lubelskie"
df2018[1,6] <- "Lubuskie"
df2018[1,7] <- "Łódzkie"
df2018[1,8] <- "Małopolskie"
df2018[1,9] <- "Mazowieckie"
df2018[1,10] <- "Opolskie"
df2018[1,11] <- "Podkarpackie"
df2018[1,12] <- "Podlaskie"
df2018[1,13] <- "Pomorskie"
df2018[1,14] <- "Śląskie"
df2018[1,15] <- "Świętokrzyskie"
df2018[1,16] <- "Warmińsko-mazurskie"
df2018[1,17] <- "Wielkopolskie"
df2018[1,18] <- "Zachodniopomorskie"
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t_1_2017)
df2017[12,1] <- "Inne bakteryjne zatrucia pokarmowe"
df2017[15,1] <- "	Bakteryjne zapalenie opon mózgowych i/lub mózgu"
df2017[16,1] <- "	Wirusowe zapalenie opon mózgowych"
df2017[1,2] <- "POLSKA"
df2017[1,3] <- "Dolnośląskie"
df2017[1,4] <- "Kujawsko-pomorskie"
df2017[1,5] <- "Lubelskie"
df2017[1,6] <- "Lubuskie"
df2017[1,7] <- "Łódzkie"
df2017[1,8] <- "Małopolskie"
df2017[1,9] <- "Mazowieckie"
df2017[1,10] <- "Opolskie"
df2017[1,11] <- "Podkarpackie"
df2017[1,12] <- "Podlaskie"
df2017[1,13] <- "Pomorskie"
df2017[1,14] <- "Śląskie"
df2017[1,15] <- "Świętokrzyskie"
df2017[1,16] <- "Warmińsko-mazurskie"
df2017[1,17] <- "Wielkopolskie"
df2017[1,18] <- "Zachodniopomorskie"
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t_1_2016)
df2016[1,1] <- "CHOROBY"
df2016[2,1] <- "Tężec "
df2016[3,1] <- "Krztusiec "
df2016[4,1] <- "Odra "
df2016[8,1] <- "Różyczka "
df2016[12,1] <- "Inne bakteryjne zatrucia pokarmowe"
df2016[15,1] <- "\tBakteryjne zapalenie opon mózgowych i/lub mózgu"
df2016[16,1] <- "\tWirusowe zapalenie opon mózgowych"
df2016[17,1] <- "Wirusowe zapalenie mózgu "
df2016[18,1] <- "Świnka "
df2016[19,1] <- "Włośnica "
df2016[20,1] <- "Grypa "
df2016[21,1] <- "Szczepieni przeciw wściekliźnie "
df2016[1,2] <- "POLSKA"
df2016[1,3] <- "Dolnośląskie"
df2016[1,4] <- "Kujawsko-pomorskie"
df2016[1,5] <- "Lubelskie"
df2016[1,6] <- "Lubuskie"
df2016[1,7] <- "Łódzkie"
df2016[1,8] <- "Małopolskie"
df2016[1,9] <- "Mazowieckie"
df2016[1,10] <- "Opolskie"
df2016[1,11] <- "Podkarpackie"
df2016[1,12] <- "Podlaskie"
df2016[1,13] <- "Pomorskie"
df2016[1,14] <- "Śląskie"
df2016[1,15] <- "Świętokrzyskie"
df2016[1,16] <- "Warmińsko-mazurskie"
df2016[1,17] <- "Wielkopolskie"
df2016[1,18] <- "Zachodniopomorskie"
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#przekształcamy w tibble _1_
t_1_2023 <- as_tibble(df2023)
t_1_2022 <- as_tibble(df2022)
t_1_2021 <- as_tibble(df2021)
t_1_2020 <- as_tibble(df2020)
t_1_2019 <- as_tibble(df2019)
t_1_2018 <- as_tibble(df2018)
t_1_2017 <- as_tibble(df2017)
t_1_2016 <- as_tibble(df2016)
#kolejne df _2_
df2023 <- as.data.frame(t_2_2023)
df2023[1,1] <- "CHOROBY"
df2023[1,2] <- "Gruźlica płucna"
df2023[1,3] <- "Gruźlica pozapłucna"
df2023[2,1] <- "POLSKA"
df2023[3,1] <- "Dolnośląskie"
df2023[4,1] <- "Kujawsko-pomorskie"
df2023[5,1] <- "Lubelskie"
df2023[6,1] <- "Lubuskie"
df2023[7,1] <- "Łódzkie"
df2023[8,1] <- "Małopolskie"
df2023[9,1] <- "Mazowieckie"
df2023[10,1] <- "Opolskie"
df2023[11,1] <- "Podkarpackie"
df2023[12,1] <- "Podlaskie"
df2023[13,1] <- "Pomorskie"
df2023[14,1] <- "Śląskie"
df2023[15,1] <- "Świętokrzyskie"
df2023[16,1] <- "Warmińsko-mazurskie"
df2023[17,1] <- "Wielkopolskie"
df2023[18,1] <- "Zachodniopomorskie"
df2023 <- t(df2023)
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t_2_2022)
df2022[1,1] <- "CHOROBY"
df2022[1,2] <- "Gruźlica płucna"
df2022[1,3] <- "Gruźlica pozapłucna"
df2022[2,1] <- "POLSKA"
df2022[3,1] <- "Dolnośląskie"
df2022[4,1] <- "Kujawsko-pomorskie"
df2022[5,1] <- "Lubelskie"
df2022[6,1] <- "Lubuskie"
df2022[7,1] <- "Łódzkie"
df2022[8,1] <- "Małopolskie"
df2022[9,1] <- "Mazowieckie"
df2022[10,1] <- "Opolskie"
df2022[11,1] <- "Podkarpackie"
df2022[12,1] <- "Podlaskie"
df2022[13,1] <- "Pomorskie"
df2022[14,1] <- "Śląskie"
df2022[15,1] <- "Świętokrzyskie"
df2022[16,1] <- "Warmińsko-mazurskie"
df2022[17,1] <- "Wielkopolskie"
df2022[18,1] <- "Zachodniopomorskie"
df2022 <- t(df2022)
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t_2_2021)
df2021[1,1] <- "CHOROBY"
df2021[1,2] <- "Gruźlica płucna"
df2021[1,3] <- "Gruźlica pozapłucna"
df2021[2,1] <- "POLSKA"
df2021[3,1] <- "Dolnośląskie"
df2021[4,1] <- "Kujawsko-pomorskie"
df2021[5,1] <- "Lubelskie"
df2021[6,1] <- "Lubuskie"
df2021[7,1] <- "Łódzkie"
df2021[8,1] <- "Małopolskie"
df2021[9,1] <- "Mazowieckie"
df2021[10,1] <- "Opolskie"
df2021[11,1] <- "Podkarpackie"
df2021[12,1] <- "Podlaskie"
df2021[13,1] <- "Pomorskie"
df2021[14,1] <- "Śląskie"
df2021[15,1] <- "Świętokrzyskie"
df2021[16,1] <- "Warmińsko-mazurskie"
df2021[17,1] <- "Wielkopolskie"
df2021[18,1] <- "Zachodniopomorskie"
df2021 <- t(df2021)
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t_2_2020)
df2020[1,1] <- "CHOROBY"
df2020[1,2] <- "Gruźlica płucna"
df2020[1,3] <- "Gruźlica pozapłucna"
df2020[2,1] <- "POLSKA"
df2020[3,1] <- "Dolnośląskie"
df2020[4,1] <- "Kujawsko-pomorskie"
df2020[5,1] <- "Lubelskie"
df2020[6,1] <- "Lubuskie"
df2020[7,1] <- "Łódzkie"
df2020[8,1] <- "Małopolskie"
df2020[9,1] <- "Mazowieckie"
df2020[10,1] <- "Opolskie"
df2020[11,1] <- "Podkarpackie"
df2020[12,1] <- "Podlaskie"
df2020[13,1] <- "Pomorskie"
df2020[14,1] <- "Śląskie"
df2020[15,1] <- "Świętokrzyskie"
df2020[16,1] <- "Warmińsko-mazurskie"
df2020[17,1] <- "Wielkopolskie"
df2020[18,1] <- "Zachodniopomorskie"
df2020 <- t(df2020)
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t_2_2019)
df2019[1,1] <- "CHOROBY"
df2019[1,2] <- "Gruźlica płucna"
df2019[1,3] <- "Gruźlica pozapłucna"
df2019[2,1] <- "POLSKA"
df2019[3,1] <- "Dolnośląskie"
df2019[4,1] <- "Kujawsko-pomorskie"
df2019[5,1] <- "Lubelskie"
df2019[6,1] <- "Lubuskie"
df2019[7,1] <- "Łódzkie"
df2019[8,1] <- "Małopolskie"
df2019[9,1] <- "Mazowieckie"
df2019[10,1] <- "Opolskie"
df2019[11,1] <- "Podkarpackie"
df2019[12,1] <- "Podlaskie"
df2019[13,1] <- "Pomorskie"
df2019[14,1] <- "Śląskie"
df2019[15,1] <- "Świętokrzyskie"
df2019[16,1] <- "Warmińsko-mazurskie"
df2019[17,1] <- "Wielkopolskie"
df2019[18,1] <- "Zachodniopomorskie"
df2019 <- t(df2019)
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t_2_2018)
df2018[1,1] <- "CHOROBY"
df2018[1,2] <- "Gruźlica płucna"
df2018[1,3] <- "Gruźlica pozapłucna"
df2018[2,1] <- "POLSKA"
df2018[3,1] <- "Dolnośląskie"
df2018[4,1] <- "Kujawsko-pomorskie"
df2018[5,1] <- "Lubelskie"
df2018[6,1] <- "Lubuskie"
df2018[7,1] <- "Łódzkie"
df2018[8,1] <- "Małopolskie"
df2018[9,1] <- "Mazowieckie"
df2018[10,1] <- "Opolskie"
df2018[11,1] <- "Podkarpackie"
df2018[12,1] <- "Podlaskie"
df2018[13,1] <- "Pomorskie"
df2018[14,1] <- "Śląskie"
df2018[15,1] <- "Świętokrzyskie"
df2018[16,1] <- "Warmińsko-mazurskie"
df2018[17,1] <- "Wielkopolskie"
df2018[18,1] <- "Zachodniopomorskie"
df2018 <- t(df2018)
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t_2_2017)
df2017[1,1] <- "CHOROBY"
df2017[1,2] <- "Gruźlica płucna"
df2017[1,3] <- "Gruźlica pozapłucna"
df2017[2,1] <- "POLSKA"
df2017[3,1] <- "Dolnośląskie"
df2017[4,1] <- "Kujawsko-pomorskie"
df2017[5,1] <- "Lubelskie"
df2017[6,1] <- "Lubuskie"
df2017[7,1] <- "Łódzkie"
df2017[8,1] <- "Małopolskie"
df2017[9,1] <- "Mazowieckie"
df2017[10,1] <- "Opolskie"
df2017[11,1] <- "Podkarpackie"
df2017[12,1] <- "Podlaskie"
df2017[13,1] <- "Pomorskie"
df2017[14,1] <- "Śląskie"
df2017[15,1] <- "Świętokrzyskie"
df2017[16,1] <- "Warmińsko-mazurskie"
df2017[17,1] <- "Wielkopolskie"
df2017[18,1] <- "Zachodniopomorskie"
df2017 <- t(df2017)
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t_2_2016)
df2016[1,1] <- "CHOROBY"
df2016[2,1] <- "POLAND"
df2016[1,2] <- "Gruźlica płucna"
df2016[1,3] <- "Gruźlica pozapłucna"
df2016[2,1] <- "POLSKA"
df2016[3,1] <- "Dolnośląskie"
df2016[4,1] <- "Kujawsko-pomorskie"
df2016[5,1] <- "Lubelskie"
df2016[6,1] <- "Lubuskie"
df2016[7,1] <- "Łódzkie"
df2016[8,1] <- "Małopolskie"
df2016[9,1] <- "Mazowieckie"
df2016[10,1] <- "Opolskie"
df2016[11,1] <- "Podkarpackie"
df2016[12,1] <- "Podlaskie"
df2016[13,1] <- "Pomorskie"
df2016[14,1] <- "Śląskie"
df2016[15,1] <- "Świętokrzyskie"
df2016[16,1] <- "Warmińsko-mazurskie"
df2016[17,1] <- "Wielkopolskie"
df2016[18,1] <- "Zachodniopomorskie"
df2016 <- t(df2016)
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#kolejne tibble _2_
t_2_2023 <- as_tibble(df2023)
t_2_2022 <- as_tibble(df2022)
t_2_2021 <- as_tibble(df2021)
t_2_2020 <- as_tibble(df2020)
t_2_2019 <- as_tibble(df2019)
t_2_2018 <- as_tibble(df2018)
t_2_2017 <- as_tibble(df2017)
t_2_2016 <- as_tibble(df2016)
#następne df _3_
df2023 <- as.data.frame(t_3_2023)
df2023[1,1] <- "CHOROBY"
df2023[1,2] <- "kiła"
df2023[1,3] <- "rzężączka"
df2023[2,1] <- "POLSKA"
df2023[3,1] <- "Dolnośląskie"
df2023[4,1] <- "Kujawsko-pomorskie"
df2023[5,1] <- "Lubelskie"
df2023[6,1] <- "Lubuskie"
df2023[7,1] <- "Łódzkie"
df2023[8,1] <- "Małopolskie"
df2023[9,1] <- "Mazowieckie"
df2023[10,1] <- "Opolskie"
df2023[11,1] <- "Podkarpackie"
df2023[12,1] <- "Podlaskie"
df2023[13,1] <- "Pomorskie"
df2023[14,1] <- "Śląskie"
df2023[15,1] <- "Świętokrzyskie"
df2023[16,1] <- "Warmińsko-mazurskie"
df2023[17,1] <- "Wielkopolskie"
df2023[18,1] <- "Zachodniopomorskie"
df2023 <- t(df2023)
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t_3_2022)
df2022[1,1] <- "CHOROBY"
df2022[1,2] <- "kiła"
df2022[1,3] <- "rzężączka"
df2022[2,1] <- "POLSKA"
df2022[3,1] <- "Dolnośląskie"
df2022[4,1] <- "Kujawsko-pomorskie"
df2022[5,1] <- "Lubelskie"
df2022[6,1] <- "Lubuskie"
df2022[7,1] <- "Łódzkie"
df2022[8,1] <- "Małopolskie"
df2022[9,1] <- "Mazowieckie"
df2022[10,1] <- "Opolskie"
df2022[11,1] <- "Podkarpackie"
df2022[12,1] <- "Podlaskie"
df2022[13,1] <- "Pomorskie"
df2022[14,1] <- "Śląskie"
df2022[15,1] <- "Świętokrzyskie"
df2022[16,1] <- "Warmińsko-mazurskie"
df2022[17,1] <- "Wielkopolskie"
df2022[18,1] <- "Zachodniopomorskie"
df2022 <- t(df2022)
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t_3_2021)
df2021[1,1] <- "CHOROBY"
df2021[1,2] <- "kiła"
df2021[1,3] <- "rzężączka"
df2021[2,1] <- "POLSKA"
df2021[3,1] <- "Dolnośląskie"
df2021[4,1] <- "Kujawsko-pomorskie"
df2021[5,1] <- "Lubelskie"
df2021[6,1] <- "Lubuskie"
df2021[7,1] <- "Łódzkie"
df2021[8,1] <- "Małopolskie"
df2021[9,1] <- "Mazowieckie"
df2021[10,1] <- "Opolskie"
df2021[11,1] <- "Podkarpackie"
df2021[12,1] <- "Podlaskie"
df2021[13,1] <- "Pomorskie"
df2021[14,1] <- "Śląskie"
df2021[15,1] <- "Świętokrzyskie"
df2021[16,1] <- "Warmińsko-mazurskie"
df2021[17,1] <- "Wielkopolskie"
df2021[18,1] <- "Zachodniopomorskie"
df2021 <- t(df2021)
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t_3_2020)
df2020[1,1] <- "CHOROBY"
df2020[1,2] <- "kiła"
df2020[1,3] <- "rzężączka"
df2020[2,1] <- "POLSKA"
df2020[3,1] <- "Dolnośląskie"
df2020[4,1] <- "Kujawsko-pomorskie"
df2020[5,1] <- "Lubelskie"
df2020[6,1] <- "Lubuskie"
df2020[7,1] <- "Łódzkie"
df2020[8,1] <- "Małopolskie"
df2020[9,1] <- "Mazowieckie"
df2020[10,1] <- "Opolskie"
df2020[11,1] <- "Podkarpackie"
df2020[12,1] <- "Podlaskie"
df2020[13,1] <- "Pomorskie"
df2020[14,1] <- "Śląskie"
df2020[15,1] <- "Świętokrzyskie"
df2020[16,1] <- "Warmińsko-mazurskie"
df2020[17,1] <- "Wielkopolskie"
df2020[18,1] <- "Zachodniopomorskie"
df2020 <- t(df2020)
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t_3_2019)
df2019[1,1] <- "CHOROBY"
df2019[1,2] <- "kiła"
df2019[1,3] <- "rzężączka"
df2019[2,1] <- "POLSKA"
df2019[3,1] <- "Dolnośląskie"
df2019[4,1] <- "Kujawsko-pomorskie"
df2019[5,1] <- "Lubelskie"
df2019[6,1] <- "Lubuskie"
df2019[7,1] <- "Łódzkie"
df2019[8,1] <- "Małopolskie"
df2019[9,1] <- "Mazowieckie"
df2019[10,1] <- "Opolskie"
df2019[11,1] <- "Podkarpackie"
df2019[12,1] <- "Podlaskie"
df2019[13,1] <- "Pomorskie"
df2019[14,1] <- "Śląskie"
df2019[15,1] <- "Świętokrzyskie"
df2019[16,1] <- "Warmińsko-mazurskie"
df2019[17,1] <- "Wielkopolskie"
df2019[18,1] <- "Zachodniopomorskie"
df2019 <- t(df2019)
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t_3_2018)
df2018[1,1] <- "CHOROBY"
df2018[1,2] <- "kiła"
df2018[1,3] <- "rzężączka"
df2018[2,1] <- "POLSKA"
df2018[3,1] <- "Dolnośląskie"
df2018[4,1] <- "Kujawsko-pomorskie"
df2018[5,1] <- "Lubelskie"
df2018[6,1] <- "Lubuskie"
df2018[7,1] <- "Łódzkie"
df2018[8,1] <- "Małopolskie"
df2018[9,1] <- "Mazowieckie"
df2018[10,1] <- "Opolskie"
df2018[11,1] <- "Podkarpackie"
df2018[12,1] <- "Podlaskie"
df2018[13,1] <- "Pomorskie"
df2018[14,1] <- "Śląskie"
df2018[15,1] <- "Świętokrzyskie"
df2018[16,1] <- "Warmińsko-mazurskie"
df2018[17,1] <- "Wielkopolskie"
df2018[18,1] <- "Zachodniopomorskie"
df2018 <- t(df2018)
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t_3_2017)
df2017[1,1] <- "CHOROBY"
df2017[1,2] <- "kiła"
df2017[1,3] <- "rzężączka"
df2017[2,1] <- "POLSKA"
df2017[3,1] <- "Dolnośląskie"
df2017[4,1] <- "Kujawsko-pomorskie"
df2017[5,1] <- "Lubelskie"
df2017[6,1] <- "Lubuskie"
df2017[7,1] <- "Łódzkie"
df2017[8,1] <- "Małopolskie"
df2017[9,1] <- "Mazowieckie"
df2017[10,1] <- "Opolskie"
df2017[11,1] <- "Podkarpackie"
df2017[12,1] <- "Podlaskie"
df2017[13,1] <- "Pomorskie"
df2017[14,1] <- "Śląskie"
df2017[15,1] <- "Świętokrzyskie"
df2017[16,1] <- "Warmińsko-mazurskie"
df2017[17,1] <- "Wielkopolskie"
df2017[18,1] <- "Zachodniopomorskie"
df2017 <- t(df2017)
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t_3_2016)
df2016[1,1] <- "CHOROBY"
df2016[2,1] <- "POLAND"
df2016[1,2] <- "kiła"
df2016[1,3] <- "rzężączka"
df2016[2,1] <- "POLSKA"
df2016[3,1] <- "Dolnośląskie"
df2016[4,1] <- "Kujawsko-pomorskie"
df2016[5,1] <- "Lubelskie"
df2016[6,1] <- "Lubuskie"
df2016[7,1] <- "Łódzkie"
df2016[8,1] <- "Małopolskie"
df2016[9,1] <- "Mazowieckie"
df2016[10,1] <- "Opolskie"
df2016[11,1] <- "Podkarpackie"
df2016[12,1] <- "Podlaskie"
df2016[13,1] <- "Pomorskie"
df2016[14,1] <- "Śląskie"
df2016[15,1] <- "Świętokrzyskie"
df2016[16,1] <- "Warmińsko-mazurskie"
df2016[17,1] <- "Wielkopolskie"
df2016[18,1] <- "Zachodniopomorskie"
df2016 <- t(df2016)
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#następne tibble _3_
t_3_2023 <- as_tibble(df2023)
t_3_2022 <- as_tibble(df2022)
t_3_2021 <- as_tibble(df2021)
t_3_2020 <- as_tibble(df2020)
t_3_2019 <- as_tibble(df2019)
t_3_2018 <- as_tibble(df2018)
t_3_2017 <- as_tibble(df2017)
t_3_2016 <- as_tibble(df2016)
#końcowe df _4_
df2023 <- as.data.frame(t_4_2023)
df2023[1,1] <- "CHOROBY"
df2023[2,1] <- "nowotwory warg, jamy ustnej i gardła"
df2023[3,1] <- "nowotwory narządów trawiennych"
df2023[4,1] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2023[5,1] <- "czerniak i inne nowotwory złośliwe skóry"
df2023[6,1] <- "nowotwory sutka"
df2023[7,1] <- "nowotwory narządów płciowych"
df2023[8,1] <- "nowotwory narządów układu moczowego"
df2023[9,1] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2023[10,1] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2023[11,1] <- "reszta  nowotworów"
df2023[12,1] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2023[1,2] <- "Dolnośląskie"
df2023[1,3] <- "Kujawsko-pomorskie"
df2023[1,4] <- "Lubelskie"
df2023[1,5] <- "Lubuskie"
df2023[1,6] <- "Łódzkie"
df2023[1,7] <- "Małopolskie"
df2023[1,8] <- "Mazowieckie"
df2023[1,9] <- "Opolskie"
df2023[1,10] <- "Podkarpackie"
df2023[1,11] <- "Podlaskie"
df2023[1,12] <- "Pomorskie"
df2023[1,13] <- "Śląskie"
df2023[1,14] <- "Świętokrzyskie"
df2023[1,15] <- "Warmińsko-mazurskie"
df2023[1,16] <- "Wielkopolskie"
df2023[1,17] <- "Zachodniopomorskie"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t_4_2022)
df2022[1,1] <- "CHOROBY"
df2022[2,1] <- "nowotwory warg, jamy ustnej i gardła"
df2022[3,1] <- "nowotwory narządów trawiennych"
df2022[4,1] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2022[5,1] <- "czerniak i inne nowotwory złośliwe skóry"
df2022[6,1] <- "nowotwory sutka"
df2022[7,1] <- "nowotwory narządów płciowych"
df2022[8,1] <- "nowotwory narządów układu moczowego"
df2022[9,1] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2022[10,1] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2022[11,1] <- "reszta  nowotworów"
df2022[12,1] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2022[1,2] <- "Dolnośląskie"
df2022[1,3] <- "Kujawsko-pomorskie"
df2022[1,4] <- "Lubelskie"
df2022[1,5] <- "Lubuskie"
df2022[1,6] <- "Łódzkie"
df2022[1,7] <- "Małopolskie"
df2022[1,8] <- "Mazowieckie"
df2022[1,9] <- "Opolskie"
df2022[1,10] <- "Podkarpackie"
df2022[1,11] <- "Podlaskie"
df2022[1,12] <- "Pomorskie"
df2022[1,13] <- "Śląskie"
df2022[1,14] <- "Świętokrzyskie"
df2022[1,15] <- "Warmińsko-mazurskie"
df2022[1,16] <- "Wielkopolskie"
df2022[1,17] <- "Zachodniopomorskie"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t_4_2021)
df2021[1,1] <- "CHOROBY"
df2021[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2021[1,3] <- "nowotwory narządów trawiennych"
df2021[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2021[1,6] <- "nowotwory sutka"
df2021[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2021[1,7] <- "nowotwory narządów płciowych"
df2021[1,8] <- "nowotwory narządów układu moczowego"
df2021[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2021[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2021[1,11] <- "reszta  nowotworów"
df2021[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2021[2,1] <- "Dolnośląskie"
df2021[3,1] <- "Kujawsko-pomorskie"
df2021[4,1] <- "Lubelskie"
df2021[5,1] <- "Lubuskie"
df2021[6,1] <- "Łódzkie"
df2021[7,1] <- "Małopolskie"
df2021[8,1] <- "Mazowieckie"
df2021[9,1] <- "Opolskie"
df2021[10,1] <- "Podkarpackie"
df2021[11,1] <- "Podlaskie"
df2021[12,1] <- "Pomorskie"
df2021[13,1] <- "Śląskie"
df2021[14,1] <- "Świętokrzyskie"
df2021[15,1] <- "Warmińsko-mazurskie"
df2021[16,1] <- "Wielkopolskie"
df2021[17,1] <- "Zachodniopomorskie"
df2021 <- t(df2021)
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t_4_2020)
df2020[1,1] <- "CHOROBY"
df2020[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2020[1,3] <- "nowotwory narządów trawiennych"
df2020[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2020[1,6] <- "nowotwory sutka"
df2020[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2020[1,7] <- "nowotwory narządów płciowych"
df2020[1,8] <- "nowotwory narządów układu moczowego"
df2020[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2020[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2020[1,11] <- "reszta  nowotworów"
df2020[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2020[2,1] <- "Dolnośląskie"
df2020[3,1] <- "Kujawsko-pomorskie"
df2020[4,1] <- "Lubelskie"
df2020[5,1] <- "Lubuskie"
df2020[6,1] <- "Łódzkie"
df2020[7,1] <- "Małopolskie"
df2020[8,1] <- "Mazowieckie"
df2020[9,1] <- "Opolskie"
df2020[10,1] <- "Podkarpackie"
df2020[11,1] <- "Podlaskie"
df2020[12,1] <- "Pomorskie"
df2020[13,1] <- "Śląskie"
df2020[14,1] <- "Świętokrzyskie"
df2020[15,1] <- "Warmińsko-mazurskie"
df2020[16,1] <- "Wielkopolskie"
df2020[17,1] <- "Zachodniopomorskie"
df2020 <- t(df2020)
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t_4_2019)
df2019[1,1] <- "CHOROBY"
df2019[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2019[1,3] <- "nowotwory narządów trawiennych"
df2019[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2019[1,6] <- "nowotwory sutka"
df2019[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2019[1,7] <- "nowotwory narządów płciowych"
df2019[1,8] <- "nowotwory narządów układu moczowego"
df2019[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2019[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2019[1,11] <- "reszta  nowotworów"
df2019[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2019[2,1] <- "Dolnośląskie"
df2019[3,1] <- "Kujawsko-pomorskie"
df2019[4,1] <- "Lubelskie"
df2019[5,1] <- "Lubuskie"
df2019[6,1] <- "Łódzkie"
df2019[7,1] <- "Małopolskie"
df2019[8,1] <- "Mazowieckie"
df2019[9,1] <- "Opolskie"
df2019[10,1] <- "Podkarpackie"
df2019[11,1] <- "Podlaskie"
df2019[12,1] <- "Pomorskie"
df2019[13,1] <- "Śląskie"
df2019[14,1] <- "Świętokrzyskie"
df2019[15,1] <- "Warmińsko-mazurskie"
df2019[16,1] <- "Wielkopolskie"
df2019[17,1] <- "Zachodniopomorskie"
df2019 <- t(df2019)
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t_4_2018)
df2018[1,1] <- "CHOROBY"
df2018[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2018[1,3] <- "nowotwory narządów trawiennych"
df2018[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2018[1,6] <- "nowotwory sutka"
df2018[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2018[1,7] <- "nowotwory narządów płciowych"
df2018[1,8] <- "nowotwory narządów układu moczowego"
df2018[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2018[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2018[1,11] <- "reszta  nowotworów"
df2018[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2018[2,1] <- "Dolnośląskie"
df2018[3,1] <- "Kujawsko-pomorskie"
df2018[4,1] <- "Lubelskie"
df2018[5,1] <- "Lubuskie"
df2018[6,1] <- "Łódzkie"
df2018[7,1] <- "Małopolskie"
df2018[8,1] <- "Mazowieckie"
df2018[9,1] <- "Opolskie"
df2018[10,1] <- "Podkarpackie"
df2018[11,1] <- "Podlaskie"
df2018[12,1] <- "Pomorskie"
df2018[13,1] <- "Śląskie"
df2018[14,1] <- "Świętokrzyskie"
df2018[15,1] <- "Warmińsko-mazurskie"
df2018[16,1] <- "Wielkopolskie"
df2018[17,1] <- "Zachodniopomorskie"
df2018 <- t(df2018)
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t_4_2017)
df2017[1,1] <- "CHOROBY"
df2017[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2017[1,3] <- "nowotwory narządów trawiennych"
df2017[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2017[1,6] <- "nowotwory sutka"
df2017[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2017[1,7] <- "nowotwory narządów płciowych"
df2017[1,8] <- "nowotwory narządów układu moczowego"
df2017[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2017[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2017[1,11] <- "reszta  nowotworów"
df2017[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2017[2,1] <- "Dolnośląskie"
df2017[3,1] <- "Kujawsko-pomorskie"
df2017[4,1] <- "Lubelskie"
df2017[5,1] <- "Lubuskie"
df2017[6,1] <- "Łódzkie"
df2017[7,1] <- "Małopolskie"
df2017[8,1] <- "Mazowieckie"
df2017[9,1] <- "Opolskie"
df2017[10,1] <- "Podkarpackie"
df2017[11,1] <- "Podlaskie"
df2017[12,1] <- "Pomorskie"
df2017[13,1] <- "Śląskie"
df2017[14,1] <- "Świętokrzyskie"
df2017[15,1] <- "Warmińsko-mazurskie"
df2017[16,1] <- "Wielkopolskie"
df2017[17,1] <- "Zachodniopomorskie"
df2017 <- t(df2017)
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t_4_2016)
df2016[1,1] <- "CHOROBY"
df2016[1,2] <- "nowotwory warg, jamy ustnej i gardła"
df2016[1,3] <- "nowotwory narządów trawiennych"
df2016[1,4] <- "nowotwory narządów oddechowych i klatki piersiowej"
df2016[1,6] <- "nowotwory sutka"
df2016[1,5] <- "czerniak i inne nowotwory złośliwe skóry"
df2016[1,7] <- "nowotwory narządów płciowych"
df2016[1,8] <- "nowotwory narządów układu moczowego"
df2016[1,9] <- "nowotwory oka, mózga i innych części centralnego układu nerwowego"
df2016[1,10] <- "nowotwory tarczycy i innych gruczołów wydzielania wewnętrznego"
df2016[1,11] <- "reszta  nowotworów"
df2016[1,12] <- "nowotwory tkanki limfatycznej, krwiotwórczej i tkanki pokrewnej"
df2016[2,1] <- "Dolnośląskie"
df2016[3,1] <- "Kujawsko-pomorskie"
df2016[4,1] <- "Lubelskie"
df2016[5,1] <- "Lubuskie"
df2016[6,1] <- "Łódzkie"
df2016[7,1] <- "Małopolskie"
df2016[8,1] <- "Mazowieckie"
df2016[9,1] <- "Opolskie"
df2016[10,1] <- "Podkarpackie"
df2016[11,1] <- "Podlaskie"
df2016[12,1] <- "Pomorskie"
df2016[13,1] <- "Śląskie"
df2016[14,1] <- "Świętokrzyskie"
df2016[15,1] <- "Warmińsko-mazurskie"
df2016[16,1] <- "Wielkopolskie"
df2016[17,1] <- "Zachodniopomorskie"
df2016 <- t(df2016)
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#końcowe tibble _4_
t_4_2023 <- as_tibble(df2023)
t_4_2022 <- as_tibble(df2022)
t_4_2021 <- as_tibble(df2021)
t_4_2020 <- as_tibble(df2020)
t_4_2019 <- as_tibble(df2019)
t_4_2018 <- as_tibble(df2018)
t_4_2017 <- as_tibble(df2017)
t_4_2016 <- as_tibble(df2016)
#ostatnie df _5_
df2023 <- as.data.frame(t_5_2023)
df2023[1,1] <- "CHOROBY"
df2023[1,2] <- "POLSKA"
df2023[1,4] <- "Kujawsko-pomorskie"
df2023[1,15] <- "Świętokrzyskie"
df2023[1,16] <- "Warmińsko-mazurskie"
df2023[1,18] <- "Zachodniopomorskie"
df2023[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2023[3,1] <- "organiczne zaburzenia psychiczne"
df2023[4,1] <- "schizofrenia"
df2023[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2023[6,1] <- "zaburzenia nastroju"
df2023[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2023[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2023[9,1] <- "upośledzenie umysłowe"
df2023[10,1] <- "zaburzenia rozwojowe"
df2023[11,1] <- "inne zaburzenia"
df2023[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2023[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2023[14,1] <- "zespół uzależnienia alkoholowego"
df2023[15,1] <- "Używanie tytoniu"
df2023[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2023[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2023[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2023[19,1] <- "Obserwacje"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t_5_2022)
df2022[1,1] <- "CHOROBY"
df2022[1,2] <- "POLSKA"
df2022[1,4] <- "Kujawsko-pomorskie"
df2022[1,15] <- "Świętokrzyskie"
df2022[1,16] <- "Warmińsko-mazurskie"
df2022[1,18] <- "Zachodniopomorskie"
df2022[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2022[3,1] <- "organiczne zaburzenia psychiczne"
df2022[4,1] <- "schizofrenia"
df2022[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2022[6,1] <- "zaburzenia nastroju"
df2022[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2022[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2022[9,1] <- "upośledzenie umysłowe"
df2022[10,1] <- "zaburzenia rozwojowe"
df2022[11,1] <- "inne zaburzenia"
df2022[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2022[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2022[14,1] <- "zespół uzależnienia alkoholowego"
df2022[15,1] <- "Używanie tytoniu"
df2022[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2022[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2022[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2022[19,1] <- "Obserwacje"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t_5_2021)
df2021[1,1] <- "CHOROBY"
df2021[1,2] <- "POLSKA"
df2021[1,4] <- "Kujawsko-pomorskie"
df2021[1,15] <- "Świętokrzyskie"
df2021[1,16] <- "Warmińsko-mazurskie"
df2021[1,18] <- "Zachodniopomorskie"
df2021[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2021[3,1] <- "organiczne zaburzenia psychiczne"
df2021[4,1] <- "schizofrenia"
df2021[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2021[6,1] <- "zaburzenia nastroju"
df2021[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2021[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2021[9,1] <- "upośledzenie umysłowe"
df2021[10,1] <- "zaburzenia rozwojowe"
df2021[11,1] <- "inne zaburzenia"
df2021[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2021[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2021[14,1] <- "zespół uzależnienia alkoholowego"
df2021[15,1] <- "Używanie tytoniu"
df2021[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2021[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2021[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2021[19,1] <- "Obserwacje"
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t_5_2020)
df2020[1,1] <- "CHOROBY"
df2020[1,2] <- "POLSKA"
df2020[1,4] <- "Kujawsko-pomorskie"
df2020[1,15] <- "Świętokrzyskie"
df2020[1,16] <- "Warmińsko-mazurskie"
df2020[1,18] <- "Zachodniopomorskie"
df2020[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2020[3,1] <- "organiczne zaburzenia psychiczne"
df2020[4,1] <- "schizofrenia"
df2020[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2020[6,1] <- "zaburzenia nastroju"
df2020[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2020[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2020[9,1] <- "upośledzenie umysłowe"
df2020[10,1] <- "zaburzenia rozwojowe"
df2020[11,1] <- "inne zaburzenia"
df2020[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2020[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2020[14,1] <- "zespół uzależnienia alkoholowego"
df2020[15,1] <- "Używanie tytoniu"
df2020[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2020[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2020[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2020[19,1] <- "Obserwacje"
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t_5_2019)
df2019[1,1] <- "CHOROBY"
df2019[1,2] <- "POLSKA"
df2019[1,4] <- "Kujawsko-pomorskie"
df2019[1,15] <- "Świętokrzyskie"
df2019[1,16] <- "Warmińsko-mazurskie"
df2019[1,18] <- "Zachodniopomorskie"
df2019[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2019[3,1] <- "organiczne zaburzenia psychiczne"
df2019[4,1] <- "schizofrenia"
df2019[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2019[6,1] <- "zaburzenia nastroju"
df2019[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2019[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2019[9,1] <- "upośledzenie umysłowe"
df2019[10,1] <- "zaburzenia rozwojowe"
df2019[11,1] <- "inne zaburzenia"
df2019[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2019[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2019[14,1] <- "zespół uzależnienia alkoholowego"
df2019[15,1] <- "Używanie tytoniu"
df2019[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2019[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2019[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2019[19,1] <- "Obserwacje"
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t_5_2018)
df2018[1,1] <- "CHOROBY"
df2018[1,2] <- "POLSKA"
df2018[1,4] <- "Kujawsko-pomorskie"
df2018[1,15] <- "Świętokrzyskie"
df2018[1,16] <- "Warmińsko-mazurskie"
df2018[1,18] <- "Zachodniopomorskie"
df2018[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2018[3,1] <- "organiczne zaburzenia psychiczne"
df2018[4,1] <- "schizofrenia"
df2018[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2018[6,1] <- "zaburzenia nastroju"
df2018[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2018[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2018[9,1] <- "upośledzenie umysłowe"
df2018[10,1] <- "zaburzenia rozwojowe"
df2018[11,1] <- "inne zaburzenia"
df2018[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2018[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2018[14,1] <- "zespół uzależnienia alkoholowego"
df2018[15,1] <- "Używanie tytoniu"
df2018[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2018[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2018[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2018[19,1] <- "Obserwacje"
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t_5_2017)
df2017[1,1] <- "CHOROBY"
df2017[1,2] <- "POLSKA"
df2017[1,4] <- "Kujawsko-pomorskie"
df2017[1,15] <- "Świętokrzyskie"
df2017[1,16] <- "Warmińsko-mazurskie"
df2017[1,18] <- "Zachodniopomorskie"
df2017[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2017[3,1] <- "organiczne zaburzenia psychiczne"
df2017[4,1] <- "schizofrenia"
df2017[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2017[6,1] <- "zaburzenia nastroju"
df2017[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2017[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2017[9,1] <- "upośledzenie umysłowe"
df2017[10,1] <- "zaburzenia rozwojowe"
df2017[11,1] <- "inne zaburzenia"
df2017[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2017[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2017[14,1] <- "zespół uzależnienia alkoholowego"
df2017[15,1] <- "Używanie tytoniu"
df2017[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2017[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2017[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2017[19,1] <- "Obserwacje"
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t_5_2016)
df2016[1,1] <- "CHOROBY"
df2016[1,2] <- "POLSKA"
df2016[1,4] <- "Kujawsko-pomorskie"
df2016[1,15] <- "Świętokrzyskie"
df2016[1,16] <- "Warmińsko-mazurskie"
df2016[1,18] <- "Zachodniopomorskie"
df2016[2,1] <- "Zaburzenia psychiczne i zaburzenia zachowania (bez uzależnień)"
df2016[3,1] <- "organiczne zaburzenia psychiczne"
df2016[4,1] <- "schizofrenia"
df2016[5,1] <- "inne zaburzenia psychotyczne (nieschizofreniczne)"
df2016[6,1] <- "zaburzenia nastroju"
df2016[7,1] <- "zaburzenia nerwicowe, odżywiania i zespoły behawioralne"
df2016[8,1] <- "zaburzenia osobowości i zachowania dorosłych"
df2016[9,1] <- "upośledzenie umysłowe"
df2016[10,1] <- "zaburzenia rozwojowe"
df2016[11,1] <- "inne zaburzenia"
df2016[12,1] <- "Zaburzenia spowodowane używaniem alkoholu"
df2016[13,1] <- "ostre zatrucia i używanie szkodliwe alkoholu"
df2016[14,1] <- "zespół uzależnienia alkoholowego"
df2016[15,1] <- "Używanie tytoniu"
df2016[16,1] <- "Zaburzenia psychiczne spowodowane używaniem środków psychoaktywnych"
df2016[17,1] <- "ostre zatrucia i używanie szkodliwe narkotyków"
df2016[18,1] <- "zespół uzależnienia i zespół abstynencyjny narkotyków"
df2016[19,1] <- "Obserwacje"
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#ostatnie tibble _5_
t_5_2023 <- as_tibble(df2023)
t_5_2022 <- as_tibble(df2022)
t_5_2021 <- as_tibble(df2021)
t_5_2020 <- as_tibble(df2020)
t_5_2019 <- as_tibble(df2019)
t_5_2018 <- as_tibble(df2018)
t_5_2017 <- as_tibble(df2017)
t_5_2016 <- as_tibble(df2016)
#łączymy tibble
t_1_2023 <- t_1_2023 %>% 
  mutate(rok=2023)
t_1_2022 <- t_1_2022 %>% 
  mutate(rok=2022)
t_1_2021 <- t_1_2021 %>% 
  mutate(rok=2021)
t_1_2020 <- t_1_2020 %>% 
  mutate(rok=2020)
t_1_2019 <- t_1_2019 %>% 
  mutate(rok=2019)
t_1_2018 <- t_1_2018 %>% 
  mutate(rok=2018)
t_1_2017 <- t_1_2017 %>% 
  mutate(rok=2017)
t_1_2016 <- t_1_2016 %>% 
  mutate(rok=2016)

t_2_2023 <- t_2_2023 %>% 
  mutate(rok=2023)
t_2_2022 <- t_2_2022 %>% 
  mutate(rok=2022)
t_2_2021 <- t_2_2021 %>% 
  mutate(rok=2021)
t_2_2020 <- t_2_2020 %>% 
  mutate(rok=2020)
t_2_2019 <- t_2_2019 %>% 
  mutate(rok=2019)
t_2_2018 <- t_2_2018 %>% 
  mutate(rok=2018)
t_2_2017 <- t_2_2017 %>% 
  mutate(rok=2017)
t_2_2016 <- t_2_2016 %>% 
  mutate(rok=2016)

t_3_2023 <- t_3_2023 %>% 
  mutate(rok=2023)
t_3_2022 <- t_3_2022 %>% 
  mutate(rok=2022)
t_3_2021 <- t_3_2021 %>% 
  mutate(rok=2021)
t_3_2020 <- t_3_2020 %>% 
  mutate(rok=2020)
t_3_2019 <- t_3_2019 %>% 
  mutate(rok=2019)
t_3_2018 <- t_3_2018 %>% 
  mutate(rok=2018)
t_3_2017 <- t_3_2017 %>% 
  mutate(rok=2017)
t_3_2016 <- t_3_2016 %>% 
  mutate(rok=2016)

t_4_2023 <- t_4_2023 %>% 
  mutate(rok=2023)
t_4_2022 <- t_4_2022 %>% 
  mutate(rok=2022)
t_4_2021 <- t_4_2021 %>% 
  mutate(rok=2021)
t_4_2020 <- t_4_2020 %>% 
  mutate(rok=2020)
t_4_2019 <- t_4_2019 %>% 
  mutate(rok=2019)
t_4_2018 <- t_4_2018 %>% 
  mutate(rok=2018)
t_4_2017 <- t_4_2017 %>% 
  mutate(rok=2017)
t_4_2016 <- t_4_2016 %>% 
  mutate(rok=2016)

t_5_2023 <- t_5_2023 %>% 
  mutate(rok=2023)
t_5_2022 <- t_5_2022 %>% 
  mutate(rok=2022)
t_5_2021 <- t_5_2021 %>% 
  mutate(rok=2021)
t_5_2020 <- t_5_2020 %>% 
  mutate(rok=2020)
t_5_2019 <- t_5_2019 %>% 
  mutate(rok=2019)
t_5_2018 <- t_5_2018 %>% 
  mutate(rok=2018)
t_5_2017 <- t_5_2017 %>% 
  mutate(rok=2017)
t_5_2016 <- t_5_2016 %>% 
  mutate(rok=2016)
#przekształcamy do wykresu
tibble <- bind_rows(t_1_2023,t_1_2022,t_1_2021,t_1_2020,t_1_2019,t_1_2018,t_1_2017,t_1_2016,
                    t_2_2023,t_2_2022,t_2_2021,t_2_2020,t_2_2019,t_2_2018,t_2_2017,t_2_2016,
                    t_3_2023,t_3_2022,t_3_2021,t_3_2020,t_3_2019,t_3_2018,t_3_2017,t_3_2016,
                    t_4_2023,t_4_2022,t_4_2021,t_4_2020,t_4_2019,t_4_2018,t_4_2017,t_4_2016,
                    t_5_2023,t_5_2022,t_5_2021,t_5_2020,t_5_2019,t_5_2018,t_5_2017,t_5_2016,
                    )
#i te wszystkie linie 6:1396 były potrzebne do stworzenia tego tibbla bez żadnych błędów
#nigdy nie zrozumiem jak można było zatwierdzić nazwy województw w "t_1_20**"

#wykres z pomocą prof. Anny Kozak
df <- tibble %>% pivot_longer("Dolnośląskie":"Zachodniopomorskie",names_to = "wojewodztwa", values_to = "count")

df$count <- ifelse(df$count == "-", 0, df$count)
df$count <- as.numeric(as.character(df$count))

#tworzymy tibble_num by móc liczyć na tabeli bez zmian w oryginale (patrz linia 1713)
tibble_num <- tibble

tibble_num <- tibble_num %>%
  pivot_longer(cols = -c(CHOROBY, rok), names_to = "Województwa", values_to = "Liczba")

tibble_num <- tibble_num %>% 
  mutate(Liczba = ifelse(Liczba == "-", "0", Liczba)) %>% 
  mutate(Liczba = as.numeric(as.character(Liczba)))

#testowo wyznaczam sumę przypadków wystąpienia danych chorób
tibble_test <- tibble_num %>%
  pivot_wider(names_from = "Województwa", values_from = "Liczba")

tibble_test <- tibble_test %>% 
  mutate(suma=rowSums(tibble_test[ , 4:19], na.rm = TRUE)) %>% 
  select(c(CHOROBY,suma))

tibble_test <- tibble_test %>%
  group_by(CHOROBY) %>%
  summarise(across(everything(), sum, na.rm = TRUE)) %>%
  arrange(-suma)

tibble_num <- tibble_num %>%
  group_by(Województwa, rok) %>%
  summarise(SumaChorob = sum(Liczba), .groups = "drop") %>%
  filter(Województwa != "POLSKA")

#próba zmniejszenia ogromnego wykresu 
df_wynik <- anti_join(df,tibble_test[26:59, ], by = "CHOROBY") 

#były próby zmniejszenia ogromnego wykresu ale jak na złość to zajmowalo tylko więcej miejsca a czytelność nie była większa
df_wynik1 <- df_wynik %>% 
  filter(rok==c("2023") | rok==c("2022") | rok==c("2021") | rok==c("2020"))
df_wynik2 <- df_wynik %>% 
  filter(rok==c("2019") | rok==c("2018") | rok==c("2017") | rok==c("2016"))

options(scipen = 10)
#z grypą
ggplot(df_wynik, aes(y = CHOROBY, x = wojewodztwa, fill = count)) +
  geom_tile() + 
  facet_wrap(rok~.,ncol=8) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=5)) + 
  labs(x = "Województwa", y = "Choroby",
       title = "Występowanie chorób",
       fill = "Liczba pacjentów") + 
  scale_fill_gradientn(colors=c("#f7fcf5","#e5f5e0","#c7e9c0","#a1d99b","#74c476","#41ab5d","#238b45","#006d2c","#00441b"))
#bez grypy
ggplot(df_wynik[df_wynik$CHOROBY != 'Grypa ',], aes(y = CHOROBY, x = wojewodztwa, fill = count)) +#i df_wynik2
  geom_tile() + 
  facet_wrap(rok~.,ncol=8) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=5),
        ) + 
  labs(x = "Województwa", y = "Choroby",
       title = "Występowanie chorób",
       fill = "Liczba pacjentów") + 
  scale_fill_gradientn(colors=c("#f7fcf5","#e5f5e0","#c7e9c0","#a1d99b","#74c476","#41ab5d","#238b45","#006d2c","#00441b"))

#ilość lekarzy
l_2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab07.csv",sep=",",fileEncoding="UTF-8")
l_2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab07.csv",sep=",",fileEncoding="UTF-8")
#czyszczenie
l_2023 <- l_2023 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2023 <- l_2023[-c(1,2,4:11,29:35), ]
l_2022 <- l_2022 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2022 <- l_2022[-c(1,2,4:11,29:35), ]
l_2021 <- l_2021 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2021 <- l_2021[-c(1,2,4:11,29:35), ]
l_2020 <- l_2020 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2020 <- l_2020[-c(1,2,4:11,29:35), ]
l_2019 <- l_2019 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2019 <- l_2019[-c(1,2,4:11,29:35), ]
l_2018 <- l_2018 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2018 <- l_2018[-c(1,2,4:11,29:35), ]
l_2017 <- l_2017 %>% 
  select(c(TABL..7.,Unnamed..3))
l_2017 <- l_2017[-c(1,2,4:11,29:35), ]
l_2016 <- l_2016 %>% 
  select(c(TABL..7...PRACOWNICY.MEDYCZNI.WEDŁUG.WOJEWÓDZTW.W.2016.r.,Unnamed..2))
l_2016 <- l_2016[-c(1,2,4:12,14,31:37), ]
#df
df2023 <- as.data.frame(l_2023)
df2023[1,1] <- "Województwa"
df2023[1,2] <- "Lekarze"
df2023[2,1] <- "POLSKA"
df2023[3,1] <- "Dolnośląskie"
df2023[4,1] <- "Kujawsko-pomorskie"
df2023[5,1] <- "Lubelskie"
df2023[6,1] <- "Lubuskie"
df2023[7,1] <- "Łódzkie"
df2023[8,1] <- "Małopolskie"
df2023[9,1] <- "Mazowieckie"
df2023[10,1] <- "Opolskie"
df2023[11,1] <- "Podkarpackie"
df2023[12,1] <- "Podlaskie"
df2023[13,1] <- "Pomorskie"
df2023[14,1] <- "Śląskie"
df2023[15,1] <- "Świętokrzyskie"
df2023[16,1] <- "Warmińsko-mazurskie"
df2023[17,1] <- "Wielkopolskie"
df2023[18,1] <- "Zachodniopomorskie"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(l_2022)
df2022[1,1] <- "Województwa"
df2022[1,2] <- "Lekarze"
df2022[2,1] <- "POLSKA"
df2022[3,1] <- "Dolnośląskie"
df2022[4,1] <- "Kujawsko-pomorskie"
df2022[5,1] <- "Lubelskie"
df2022[6,1] <- "Lubuskie"
df2022[7,1] <- "Łódzkie"
df2022[8,1] <- "Małopolskie"
df2022[9,1] <- "Mazowieckie"
df2022[10,1] <- "Opolskie"
df2022[11,1] <- "Podkarpackie"
df2022[12,1] <- "Podlaskie"
df2022[13,1] <- "Pomorskie"
df2022[14,1] <- "Śląskie"
df2022[15,1] <- "Świętokrzyskie"
df2022[16,1] <- "Warmińsko-mazurskie"
df2022[17,1] <- "Wielkopolskie"
df2022[18,1] <- "Zachodniopomorskie"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(l_2021)
df2021[1,1] <- "Województwa"
df2021[1,2] <- "Lekarze"
df2021[2,1] <- "POLSKA"
df2021[3,1] <- "Dolnośląskie"
df2021[4,1] <- "Kujawsko-pomorskie"
df2021[5,1] <- "Lubelskie"
df2021[6,1] <- "Lubuskie"
df2021[7,1] <- "Łódzkie"
df2021[8,1] <- "Małopolskie"
df2021[9,1] <- "Mazowieckie"
df2021[10,1] <- "Opolskie"
df2021[11,1] <- "Podkarpackie"
df2021[12,1] <- "Podlaskie"
df2021[13,1] <- "Pomorskie"
df2021[14,1] <- "Śląskie"
df2021[15,1] <- "Świętokrzyskie"
df2021[16,1] <- "Warmińsko-mazurskie"
df2021[17,1] <- "Wielkopolskie"
df2021[18,1] <- "Zachodniopomorskie"
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(l_2020)
df2020[1,1] <- "Województwa"
df2020[1,2] <- "Lekarze"
df2020[2,1] <- "POLSKA"
df2020[3,1] <- "Dolnośląskie"
df2020[4,1] <- "Kujawsko-pomorskie"
df2020[5,1] <- "Lubelskie"
df2020[6,1] <- "Lubuskie"
df2020[7,1] <- "Łódzkie"
df2020[8,1] <- "Małopolskie"
df2020[9,1] <- "Mazowieckie"
df2020[10,1] <- "Opolskie"
df2020[11,1] <- "Podkarpackie"
df2020[12,1] <- "Podlaskie"
df2020[13,1] <- "Pomorskie"
df2020[14,1] <- "Śląskie"
df2020[15,1] <- "Świętokrzyskie"
df2020[16,1] <- "Warmińsko-mazurskie"
df2020[17,1] <- "Wielkopolskie"
df2020[18,1] <- "Zachodniopomorskie"
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(l_2019)
df2019[1,1] <- "Województwa"
df2019[1,2] <- "Lekarze"
df2019[2,1] <- "POLSKA"
df2019[3,1] <- "Dolnośląskie"
df2019[4,1] <- "Kujawsko-pomorskie"
df2019[5,1] <- "Lubelskie"
df2019[6,1] <- "Lubuskie"
df2019[7,1] <- "Łódzkie"
df2019[8,1] <- "Małopolskie"
df2019[9,1] <- "Mazowieckie"
df2019[10,1] <- "Opolskie"
df2019[11,1] <- "Podkarpackie"
df2019[12,1] <- "Podlaskie"
df2019[13,1] <- "Pomorskie"
df2019[14,1] <- "Śląskie"
df2019[15,1] <- "Świętokrzyskie"
df2019[16,1] <- "Warmińsko-mazurskie"
df2019[17,1] <- "Wielkopolskie"
df2019[18,1] <- "Zachodniopomorskie"
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(l_2018)
df2018[1,1] <- "Województwa"
df2018[1,2] <- "Lekarze"
df2018[2,1] <- "POLSKA"
df2018[3,1] <- "Dolnośląskie"
df2018[4,1] <- "Kujawsko-pomorskie"
df2018[5,1] <- "Lubelskie"
df2018[6,1] <- "Lubuskie"
df2018[7,1] <- "Łódzkie"
df2018[8,1] <- "Małopolskie"
df2018[9,1] <- "Mazowieckie"
df2018[10,1] <- "Opolskie"
df2018[11,1] <- "Podkarpackie"
df2018[12,1] <- "Podlaskie"
df2018[13,1] <- "Pomorskie"
df2018[14,1] <- "Śląskie"
df2018[15,1] <- "Świętokrzyskie"
df2018[16,1] <- "Warmińsko-mazurskie"
df2018[17,1] <- "Wielkopolskie"
df2018[18,1] <- "Zachodniopomorskie"
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(l_2017)
df2017[1,1] <- "Województwa"
df2017[1,2] <- "Lekarze"
df2017[2,1] <- "POLSKA"
df2017[3,1] <- "Dolnośląskie"
df2017[4,1] <- "Kujawsko-pomorskie"
df2017[5,1] <- "Lubelskie"
df2017[6,1] <- "Lubuskie"
df2017[7,1] <- "Łódzkie"
df2017[8,1] <- "Małopolskie"
df2017[9,1] <- "Mazowieckie"
df2017[10,1] <- "Opolskie"
df2017[11,1] <- "Podkarpackie"
df2017[12,1] <- "Podlaskie"
df2017[13,1] <- "Pomorskie"
df2017[14,1] <- "Śląskie"
df2017[15,1] <- "Świętokrzyskie"
df2017[16,1] <- "Warmińsko-mazurskie"
df2017[17,1] <- "Wielkopolskie"
df2017[18,1] <- "Zachodniopomorskie"
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(l_2016)
df2016[1,1] <- "Województwa"
df2016[1,2] <- "Lekarze"
df2016[2,1] <- "POLSKA"
df2016[3,1] <- "Dolnośląskie"
df2016[4,1] <- "Kujawsko-pomorskie"
df2016[5,1] <- "Lubelskie"
df2016[6,1] <- "Lubuskie"
df2016[7,1] <- "Łódzkie"
df2016[8,1] <- "Małopolskie"
df2016[9,1] <- "Mazowieckie"
df2016[10,1] <- "Opolskie"
df2016[11,1] <- "Podkarpackie"
df2016[12,1] <- "Podlaskie"
df2016[13,1] <- "Pomorskie"
df2016[14,1] <- "Śląskie"
df2016[15,1] <- "Świętokrzyskie"
df2016[16,1] <- "Warmińsko-mazurskie"
df2016[17,1] <- "Wielkopolskie"
df2016[18,1] <- "Zachodniopomorskie"
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#tibble
l_2023 <- as_tibble(df2023)
l_2022 <- as_tibble(df2022)
l_2021 <- as_tibble(df2021)
l_2020 <- as_tibble(df2020)
l_2019 <- as_tibble(df2019)
l_2018 <- as_tibble(df2018)
l_2017 <- as_tibble(df2017)
l_2016 <- as_tibble(df2016)
#dodajemy lata
l_2023 <- l_2023 %>% 
  mutate(rok=2023)
l_2022 <- l_2022 %>% 
  mutate(rok=2022)
l_2021 <- l_2021 %>% 
  mutate(rok=2021)
l_2020 <- l_2020 %>% 
  mutate(rok=2020)
l_2019 <- l_2019 %>% 
  mutate(rok=2019)
l_2018 <- l_2018 %>% 
  mutate(rok=2018)
l_2017 <- l_2017 %>% 
  mutate(rok=2017)
l_2016 <- l_2016 %>% 
  mutate(rok=2016)
#łączymy tibble
l_tibble <- bind_rows(l_2023,l_2022,l_2021,l_2020,l_2019,l_2018,l_2017,l_2016) %>% 
  filter(Województwa != "POLSKA") %>% 
  mutate(Lekarze = as.numeric(Lekarze))

#i tu wykorzystuje policzone tibble_num
tibble_stosunek <- tibble_num %>%
  inner_join(l_tibble, by = c("Województwa","rok")) %>% 
  mutate(Iloraz = SumaChorob / Lekarze)

#2 wykres który niestety nie objawił się na plakacie szkoda :(
tibble_stosunek %>% 
  ggplot(aes(x=rok,y=Iloraz,color=Województwa,group=Województwa))+
  geom_point()+
  geom_line()+
  labs(title="Stosunek ilości chorych a ilością lekarzy", subtitle = "Z podziałem na województwa",y="Stosunek",color="Województwa")+
  scale_x_discrete(name="Rok",labels=c("2016","2017","2018","2019","2020","2021","2022","2023"))+
  theme(axis.text = element_text(face = "bold"),
        legend.text = element_text(face="bold"),
        axis.title = element_text(face = "bold"))
