library(ggplot2)
library(beeswarm)
library(dplyr)
#losowe tworzenie choinki
set.seed(2026)
df <- rnorm(250)
punkty <- beeswarm(df, method="center" ,do.plot = FALSE)
#przygotowanie do poprawek
punkty <- punkty %>% 
  arrange(y) %>% 
  mutate(roznica=c(round(diff(y),5),0))
m<-min(punkty$roznica[punkty$roznica != 0])
#dol
l<-0
for (i in 1:124)
{
  if(punkty$roznica[125-i]>m)
  {
    l=l+(punkty$roznica[125-i]-m)
  }
  punkty$y[125-i]<-punkty$y[125-i]+l
}
#gora
l<-0
for (i in 125:250)
{
  punkty$y[i]<-punkty$y[i]-l
  if(punkty$roznica[i]>m)
  {
    l=l+(punkty$roznica[i]-m)
  }
}
#przygotowanie do kolorowania
ile <- table(punkty$y)
wynik <- ile[as.character(punkty$y)]
punkty <- punkty %>% 
  mutate(szerokosc=as.vector(wynik))
punkty$col[1]="brown"
punkty$pch[1]=0
pien<-punkty$szerokosc[1]
j<-2
while(punkty$szerokosc[j]<=pien)
{
  punkty$col[j]="brown"
  punkty$pch[j]=0
  j=j+1
}
for (i in j:250)
{
  punkty$col[i]="green"
}
if(punkty$szerokosc[250]==1)
{
  punkty$col[250]="gold"
  punkty$pch[250]=8
}
#losowanie bombek
ilosc<-sum(punkty$col=="green")
if (ilosc%%2==1)
{
  ilosc=ilosc-1
}
n<-sample(1:(ilosc/2), 1)
kolorki<-c("red","blue","orange")
while(n>0)
{
  j<-sample(1:250,1)
  if(punkty$col[j]=="green")
  {
    punkty$col[j]=kolorki[(n%%3)+1]
  }
  n=n-1
}
#wykres
plot(x=punkty$x,y=punkty$y,col=punkty$col,pch=punkty$pch,axes = FALSE,xlab="",ylab="") 

