#link do posta: https://x.com/efranke7282/status/1666091756834934789/photo/1
#link do github: https://github.com/efranke22/tidytuesday/blob/main/2023/tidyEnergy.Rmd

# Choć wykres zawiera wszystkie dane numeryczne niewiele różni się on od zwykłej tabelki,
# koła choć zmieniają rozmiar trudno ze sobą porównać by dały one jakąś wartość dodaną do wykresu.
# Ponadto z jakiegoś powodu kraje są posortowane po procencie energii z węgla, oraz są zaznaczone
# liczby nawet gdy wynoszą zero.

#Wykres jest lepszy od oryginału, ponieważ na pierwszy rzut oka widać co jaką jest częśią zużycia 
#energii w danym państwie, nie ma zaznaczonych wartości gdy są zbyt małe by mieć znaczenie oraz
#posortowano państwa po populacji, dzięki czemu można wyciągnąć wnioski jak zaludnienie wpływa na
#udziały rodzai energii w ogólnym rozrachunku.

library(tidyverse)
library(showtext)
library(countrycode)
library(ggimage)
library(scales)
library(ggthemes)

owid_energy <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-06-06/owid-energy.csv",
  show_col_types = FALSE
)

font_add_google("Comic Neue", "hooray")
showtext_auto()

top10 <- c(
  "China", "India", "United States", "Indonesia", "Brazil",
  "Pakistan", "Bangladesh", "Russia", "Japan", "Mexico"
)

energy2021 <- owid_energy %>%
  filter(country %in% top10, year == 2021) %>%
  select(
    country, population,
    oil_share_energy, gas_share_energy, coal_share_energy,
    nuclear_share_energy, renewables_share_energy
  ) %>%
  mutate(across(ends_with("_share_energy"), ~ replace_na(.x, 0))) %>%
  mutate(
    sum_known = oil_share_energy + gas_share_energy + coal_share_energy +
      nuclear_share_energy + renewables_share_energy,
    scale_factor = if_else(sum_known > 100, 100 / sum_known, 1),
    oil_share_energy = oil_share_energy * scale_factor,
    gas_share_energy = gas_share_energy * scale_factor,
    coal_share_energy = coal_share_energy * scale_factor,
    nuclear_share_energy = nuclear_share_energy * scale_factor,
    renewables_share_energy = renewables_share_energy * scale_factor,
    sum_known2 = oil_share_energy + gas_share_energy + coal_share_energy +
      nuclear_share_energy + renewables_share_energy,
    other_share_energy = pmax(0, 100 - sum_known2),
    iso2 = countrycode(country, "country.name", "iso2c")
  ) %>%
  pivot_longer(
    cols = c(
      coal_share_energy, gas_share_energy, oil_share_energy,
      nuclear_share_energy, renewables_share_energy, other_share_energy
    ),
    names_to = "type",
    values_to = "share"
  ) %>%
  mutate(
    type = str_remove(type, "_share_energy"),
    type = str_to_title(type),
    type = factor(type, levels = c("Coal", "Gas", "Oil", "Nuclear", "Renewables")),
    share = as.numeric(share)
  )

country_order <- owid_energy %>%
  filter(country %in% top10, year == 2021) %>%
  distinct(country, population) %>%
  arrange(desc(population)) %>%
  pull(country)

energy2021 <- energy2021 %>%
  mutate(country = factor(country, levels = rev(country_order)))

countries_df <- energy2021 %>%
  distinct(country, iso2) %>%
  filter(!is.na(iso2))

orig_colors <- c(
  "Coal" = "seashell4",
  "Gas" = "lightgray",
  "Oil" = "lightgoldenrod3",
  "Nuclear" = "wheat",
  "Renewables" = "darkolivegreen3",
  "Other" = "seashell2"
)

p <- ggplot(energy2021, aes(x = country, y = share)) +
  geom_col(
    aes(fill = type),
    width = 0.75,
    position = position_stack(reverse = TRUE)   # <<< TO odwraca kolejność segmentów
  ) +
  coord_flip() +
  geom_flag(
    data = countries_df,
    aes(x = country, y = -7, image = iso2),
    inherit.aes = FALSE,
    size = 0.04
  ) +
  geom_text(
    aes(label = ifelse(share >= 6, paste0(round(share, 1), "%"), "")),
    family = "hooray",
    size = 3,
    position = position_stack(vjust = 0.5, reverse = TRUE)  # <<< musi być tak samo jak w geom_col
  ) +
  scale_fill_manual(
    values = orig_colors,
    breaks = c("Coal", "Gas", "Oil", "Nuclear", "Renewables", "Other"),
    name = NULL
  ) +
  scale_y_continuous(
    limits = c(-10, 100.05),
    breaks = seq(0, 100, 10),
    labels = scales::label_percent(scale = 1)
  ) +
  labs(
    title = "Percent share of primary energy consumption by source in 2021 for ten most populated countries",
    caption = "*Nigeria did not have energy share data reported \nErin Franke | Source: Our World in Data's Energy Data Explorer"
  ) +
  theme_fivethirtyeight() +
  theme(
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    plot.background = element_rect(fill = "honeydew", color = NA),
    panel.background = element_rect(fill = "honeydew", color = NA),
    axis.text = element_text(family = "hooray", size = 10),
    plot.title.position = "plot",
    plot.title = element_text(size = 10.5),
    plot.caption = element_text(size = 8, family = "hooray"),
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(family = "hooray", size = 9),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

p