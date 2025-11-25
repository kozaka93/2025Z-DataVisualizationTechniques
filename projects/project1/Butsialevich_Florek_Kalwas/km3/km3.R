library(dplyr)
library(tidyr)
library(ggplot2)
library(crayon)
#dajemy dane
t2023 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2023\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2022 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2022\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2021 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2021\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2020 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2020\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2019 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2019\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2018 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2018\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2017 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2017\\tab01.csv",sep=",",fileEncoding="UTF-8")

t2016 <- read.csv2("C:\\Users\\wojte\\OneDrive\\Desktop\\projekty\\semestr3\\TWD\\Projekt1\\dane\\2016\\tab01.csv",sep=",",fileEncoding="UTF-8")
#czyścimy
t2023 <- t2023 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2023.R.,Unnamed..19,Unnamed..20,powrót.back))
t2023 <- t2023[-c(1,3,4,16,18,20,22,25,27,33:71), ]

t2022 <- t2022 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2022.R.,Unnamed..19,Unnamed..20,powrót.back))
t2022 <- t2022[-c(1,3,4,16,18,20,22,25,27,33:71), ]

t2021 <- t2021 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.WEDŁUG.WOJEWÓDZTW.W.2021.R.,Unnamed..19,Unnamed..20,powrót.back))
t2021 <- t2021[-c(1,3,4,16,18,20,22,25,27,33:71), ]

t2020 <- t2020 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2020.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t2020 <- t2020[-c(1,3,4,16,18,21,23,29:63), ]

t2019 <- t2019 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2019.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t2019 <- t2019[-c(1,3,4,16,18,21,23,29:63), ]

t2018 <- t2018 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2018.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t2018 <- t2018[-c(1,3,4,16,18,21,23,29:63), ]

t2017 <- t2017 %>% 
  select(-c(ZACHOROWANIA.NA.NIEKTÓRE.CHOROBY.ZAKAŹNE.W.2017.R..WEDŁUG.WOJEWÓDZTW,Unnamed..19,Unnamed..20,powrót.back))
t2017 <- t2017[-c(1,3,4,16,18,21,23,29:63), ]

t2016 <- t2016[-c(1,3,4,9,11,13,17,19,20,22,23,25,27,28,30,31,33,35,40:85), ]
#przekształcamy w df bo excel jest do d.
df2023 <- as.data.frame(t2023)
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
df2023[1,18] <- "Zachodnio-pomorskie"
colnames(df2023) <- c(df2023[1, ])
df2023 <- df2023[-1, ]

df2022 <- as.data.frame(t2022)
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
df2022[1,18] <- "Zachodnio-pomorskie"
colnames(df2022) <- c(df2022[1, ])
df2022 <- df2022[-1, ]

df2021 <- as.data.frame(t2021)
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
df2021[1,18] <- "Zachodnio-pomorskie"
colnames(df2021) <- c(df2021[1, ])
df2021 <- df2021[-1, ]

df2020 <- as.data.frame(t2020)
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
df2020[1,18] <- "Zachodnio-pomorskie"
colnames(df2020) <- c(df2020[1, ])
df2020 <- df2020[-1, ]

df2019 <- as.data.frame(t2019)
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
df2019[1,18] <- "Zachodnio-pomorskie"
colnames(df2019) <- c(df2019[1, ])
df2019 <- df2019[-1, ]

df2018 <- as.data.frame(t2018)
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
df2018[1,18] <- "Zachodnio-pomorskie"
colnames(df2018) <- c(df2018[1, ])
df2018 <- df2018[-1, ]

df2017 <- as.data.frame(t2017)
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
df2017[1,18] <- "Zachodnio-pomorskie"
colnames(df2017) <- c(df2017[1, ])
df2017 <- df2017[-1, ]

df2016 <- as.data.frame(t2016)
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
df2016[1,18] <- "Zachodnio-pomorskie"
colnames(df2016) <- c(df2016[1, ])
df2016 <- df2016[-1, ]
#przekształcamy w tibble
tibble2023 <- as_tibble(df2023)

tibble2022 <- as_tibble(df2022)

tibble2021 <- as_tibble(df2021)

tibble2020 <- as_tibble(df2020)

tibble2019 <- as_tibble(df2019)

tibble2018 <- as_tibble(df2018)

tibble2017 <- as_tibble(df2017)

tibble2016 <- as_tibble(df2016)
#łączymy tibble
tibble2023 <- tibble2023 %>% 
  mutate(rok=2023)

tibble2022 <- tibble2022 %>% 
  mutate(rok=2022)

tibble2021 <- tibble2021 %>% 
  mutate(rok=2021)

tibble2020 <- tibble2020 %>% 
  mutate(rok=2020)

tibble2019 <- tibble2019 %>% 
  mutate(rok=2019)

tibble2018 <- tibble2018 %>% 
  mutate(rok=2018)

tibble2017 <- tibble2017 %>% 
  mutate(rok=2017)

tibble2016 <- tibble2016 %>% 
  mutate(rok=2016)

tibble <- bind_rows(tibble2023,tibble2022,tibble2021)
tibble <- bind_rows(tibble2020,tibble2019,tibble2018,tibble2017,tibble2016)
#teams patrz
df <- tibble %>% pivot_longer(`Dolnośląskie`:`Zachodnio-pomorskie`,names_to = "wojewodztwa", values_to = "count")

df$count <- ifelse(df$count == "-", 0, df$count)
df$count <- as.numeric(as.character(df$count))

options(scipen = 10)
#z grypą
ggplot(df, aes(y = CHOROBY, x = wojewodztwa, fill = count)) +
  geom_tile() + 
  facet_wrap(rok~.) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  labs(x = "Województwa", y = "Choroby",
       title = "Występowanie chorób",
       fill = "Liczba pacjentów") + 
  scale_fill_gradientn(colors=c("#f7fcf5","#e5f5e0","#c7e9c0","#a1d99b","#74c476","#41ab5d","#238b45","#006d2c","#00441b"))
#bez grypy
ggplot(df[df$CHOROBY != 'Grypa ',], aes(y = CHOROBY, x = wojewodztwa, fill = count)) +
  geom_tile() + 
  facet_wrap(rok~.) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  labs(x = "Województwa", y = "Choroby",
       title = "Występowanie chorób",
       fill = "Liczba pacjentów") + 
  scale_fill_gradientn(colors=c("#f7fcf5","#e5f5e0","#c7e9c0","#a1d99b","#74c476","#41ab5d","#238b45","#006d2c","#00441b"))

