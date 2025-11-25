library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(forcats)
library(patchwork)


wypisaniZmarli2016 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2016.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2016= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))



wypisaniZmarli2017 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2017.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2017= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))


wypisaniZmarli2018 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2018.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2018= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))

wypisaniZmarli2019 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2019.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2019= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))

wypisaniZmarli2020 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2020.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2020= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))
wypisaniZmarli2021 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2021.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2021= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))
wypisaniZmarli2022 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2022.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2022= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))
wypisaniZmarli2023 <- read.csv2("C:/TWD/Projekt1/WypisaniZmarliDane/wypisaniZmarli2023.csv", sep=";",fileEncoding = "Windows-1250") %>% 
  slice(6:21) %>% 
  select(TABL..14.,X.1,X.3) %>% 
  rename(Discharged=X.1, Deceased=X.3) %>% 
  mutate(Discharged=as.numeric(Discharged),Deceased=as.numeric(Deceased) , Ratio2023= Deceased/Discharged,TABL..14.=as.factor(TABL..14.))
  
wypisaniZmarliJoined <- wypisaniZmarli2016 %>%
  full_join(wypisaniZmarli2017, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2018, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2019, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2020, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2021, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2022, by="TABL..14.") %>% 
  full_join(wypisaniZmarli2023, by="TABL..14.") %>% 
  select(TABL..14.,matches("^Ratio")) %>% 
  pivot_longer(cols= c(Ratio2016,Ratio2017,Ratio2018,Ratio2019,Ratio2020,Ratio2021,Ratio2022,Ratio2023),names_to = "Year",values_to = "Ratio")






p1 <- wypisaniZmarliJoined %>% 
  ggplot(aes(x=Year,y=Ratio,color=TABL..14.,group=TABL..14.))+
  geom_rect(aes(xmin=4,xmax=6,ymin=-Inf,ymax=Inf),fill="lightblue",alpha=0.02,color=NA)+
  annotate("text",x=5,y=0.023,label="Pandemia Covid-19",size=3,color="blue",fontface="bold")+
  geom_point()+
  geom_line()+
  labs(title="Stosunek zmarłych i wypisanych pacjentów", subtitle = "Z podziałem na województwa",y="Stosunek",color="Województwa")+
  scale_x_discrete(name="Rok",labels=c("2016","2017","2018","2019","2020","2021","2022","2023"))+
  theme(axis.text = element_text(face = "bold"),
        legend.text = element_text(face="bold"),
        axis.title = element_text(face = "bold"),
        panel.background = element_rect(fill='transparent'),
        plot.background = element_rect(fill='transparent', color=NA))
  
  

p2 <- wypisaniZmarliJoined %>% 
  group_by(TABL..14.) %>% 
  summarise(avg_ratio=mean(Ratio)) %>% 
  ggplot(aes(x=avg_ratio,y=fct_reorder(TABL..14.,avg_ratio)))+
  geom_col()+
  labs(title="Średni stosunek zmarłych do wypisanych pacjentów",x="Średni stosunek",y="Województwa")+
  theme(axis.text = element_text(face = "bold"),axis.title = element_text(face = "bold"),
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA))

p1+p2+ plot_layout(widths = c(2.5, 1))














