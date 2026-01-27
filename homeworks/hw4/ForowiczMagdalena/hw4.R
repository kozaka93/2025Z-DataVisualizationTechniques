# link do posta z wykresem: https://x.com/drob/status/1133456322182225920

# link do danych: https://github.com/rfordatascience/tidytuesday/blob/main/data/2019/2019-05-21/per-capita-plastic-waste-vs-gdp-per-capita.csv
# Poprawiam tylko prawy wykres, ponieważ tylko on wykorzystuje dane dostępne w repozytorium TidyTuesday.

# Co jest nie tak z wykresem:
#
# 1. Na podstawie wykresu autor wyciąga wnioski dotyczące korelacji
# pomiędzy odpadami a pkb. Wykres jest jednak bardzo chaotyczny i nie wiadomo
# na co faktycznie zwrócić uwagę.
# 2. Wizualizacja ta jest również średnio przyjemna dla oka, chociażby bardzo dużo nakladających się na siebie nazw krajów.
# Niektóre z tych nazw są także ucięte. 
# 3. Na osi Y zaś mamy także zly dobór jednostek, które są bardzo nieintuicyjne.

library(dplyr)
library(readr)
library(ggrepel) 

mismanaged_vs_gdp <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-05-21/per-capita-mismanaged-plastic-waste-vs-gdp-per-capita.csv")


df <- mismanaged_vs_gdp %>%
  rename(mismanaged = `Per capita mismanaged plastic waste (kilograms per person per day)`,
         gdp = `GDP per capita, PPP (constant 2011 international $) (Rate)`,
         population = `Total population (Gapminder)`) %>%
  filter(Year == 2010)

countries <- df %>%
  arrange(desc(population)) %>%
  head(10) %>% pull(Entity)

ggplot(df, aes(x = gdp, y = mismanaged * 1000)) +
  geom_point(aes(size = population), alpha = 0.6, color = "#2c3e50") +
  geom_smooth(color = "blue", size = 1.2) +
  geom_text_repel(aes(label = Entity),
                  data = filter(df, Entity %in% c(countries, "Poland")),
                  size = 4,
                  force = 10,
                  min.segment.length = 0,
                  box.padding = 0.5,
                  color = "black") +
  scale_x_log10(labels = scales::comma,
                breaks = c(1000, 10000, 100000)) +
  scale_y_log10(breaks = c(1, 10, 100)) +
  scale_size_continuous(range = c(2, 14), guide = "none") +
  labs(title = "Mismanaged plastic waste vs. GDP per capita",
       y = "Mismanaged waste [grams per person per day]",
       x = "GDP per capita [$]",
       caption = "Source: TidyTuesday Data (2019)") +
  theme_light() +
  theme(plot.title = element_text(face = "bold", size = 16))

# Co zostalo poprawione:
#
# 1. Przede wszystkim na nowym wykresie jest linia trendu, która od razu zwraca
# uwagę odbiorcy i pomaga wyciągnąć odpowiednie wnioski.
# 2. Usunięta zostala także część etykiet, pozostalo parę najbardziej zaludnionych krajów oraz Polska.
# 3. Na osi Y mamy teraz gramy zamiast nienaturalnych wartości typu 0.001kg
