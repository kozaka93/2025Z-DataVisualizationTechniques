library(ggplot2)
library(tidyverse)
devtools::install_github("wilkox/treemapify")
devtools::install_github("karthik/wesanderson")
library(wesanderson)
library(treemapify)
library(fishualize)
library(extrafontdb)
library(extrafont)
library(showtextdb)
library(showtext)
library(sysfonts)

font_add(family = "college", "CollegeBlock20-K5ql.ttf")
showtext_auto()

week10 <- readr::read_csv("https://raw.githubusercontent.com/ajstarks/dubois-data-portraits/master/challenge/2024/challenge10/data.csv")

#to add an explosion effect
week10 <- mutate(week10, group = c("high", "low", "low", "low", "low","medium"))


pal <- wes_palette("Zissou1", 100, type = "continuous")

ggplot(week10, aes(area = Percentage, fill = Percentage,
                   label = paste(Occupation, Percentage, sep = "\n"), subgroup = group)) +
  geom_treemap() +
  geom_treemap_subgroup_border(colour = "white", size = 6) +
  geom_treemap_text(colour = "white", place = "center",
                    size = 10, grow = TRUE)+
  scale_fill_gradient(low = "blue", high = "red")+
  labs(title = "Plot recreation of Du Bois Plate-37 from the 1900 Paris Exposition.\n",
       subtitle = "At the time of 1900, since its establishment in 1867,\nAtlanta University had graduated 330 black people among whom were:\n",
       caption = "Source:Plate 37   DuBois 1900 Paris Exposition | Graphic:Simisani Ndaba ")+
  theme(legend.position = "none",
        plot.title = element_text(size = 29,hjust = 0.5, family = "college", face = "bold"),
        plot.subtitle = element_text(size = 26, hjust = 0.5,family = "college"),
        plot.caption = element_text(size = 20, family = "college"))

ggsave("2024TidyTuesdayweek14.png", width =4, height =5 )  
