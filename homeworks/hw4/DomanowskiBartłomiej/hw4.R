# link do posta (z moim zdaniem wadliwą wizualizajcą): https://x.com/malasi_abhinav/status/1568325323787325442/photo/1
# link do danych: https://github.com/rfordatascience/tidytuesday/tree/main/data/2022/2022-09-06

# Błędy: 
# Tytuł brzmi: 
# 1.
# Na tym obrazku truno jest dotrzeć innej informacji niż to że czarnych jest 
# najwięcej, a porównanie liczebności niebieskich z zółtymi to już więcej niż wyzwanie. 
# Oczwiście ten problem to wielkość, za którą stoją pola kół i mocno utrudnia to 
# ocenę liczebności poszczególnych kolorów
# 2. 
# Nie ma żadnych etykiet danych (a odcieni jak napisano jest 2022), co utrudnia 
# dokładną identyfikacje kolorów, głównie ze względu na odcienie. Brak jest również 
# konkretnych watości liczbowych oraz pojawia się ogromny szum informacyjny związany 
# z kolorami, których jest tak mało, że kolory malutkich kółeczek się zlewają. 
# Jakie elementy wymagają poprawy? 
# - Zmiana pola kół na długość głupków
# - Dodanie osi i siatki, które ułatwią odczyt liczby kloców oraz ich porównywanie
# - Dodanie opisów kolorów, jakie to są wraz z nazwą 
# - (mój dodatek) Porostowanie wyników od największego, żeby przekazać coś więcej 
#   niż tylko to, że najwięcej jest czarnych.
# - ograniczenie się do np. tych 20 najczęściej występujących, żeby nie pokazywać 
#   202 etykiet kolorów, aby uniknąć zbętnych informacji, których nie ma również w oryginale
library(tidyverse)

inventories <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-06/inventories.csv.gz')
inventory_parts <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-06/inventory_parts.csv.gz')
colors <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-06/colors.csv.gz')

lego_colors_summary <- inventory_parts %>%
  inner_join(colors, by = c("color_id" = "id")) %>%
  group_by(name, rgb) %>%
  summarise(total_parts = sum(quantity), .groups = "drop") %>%
  slice_max(total_parts, n = 20) %>%
  mutate(
    hex_color = paste0("#", rgb),
    name = fct_reorder(name, -total_parts) 
  ) 

ggplot(lego_colors_summary, aes(x = name, y = total_parts, fill = hex_color)) +
  geom_col(color = "black", linewidth = 0.2) + 
  scale_fill_identity() + 
  scale_y_continuous(
    n.breaks = 7,                   
    labels = scales::comma_format(),   
    expand = expansion(mult = c(0, 0.05)) 
  ) + 
labs(
  title = "20 najczęstszych kolorów klocków LEGO",
  subtitle = "Lego ogólnie posiada 202 unikalne kolory",
  x = "Nazwa koloru",
  y = "Liczba części",
  caption = "Źródło: TidyTuesday 2022-09-06 | W36 | Lego dataset"
) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#f0f0f0", color = NA),
    panel.background = element_rect(fill = "#f2f2f2", color = NA),
    plot.margin = margin(t = 20, r = 10, b = 20, l = 10),
    plot.title.position = "plot", 
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5),
    plot.subtitle = element_text(color = "black", hjust = 0.5),
    axis.text.x = element_text(angle = 60, hjust = 1, size = 10, color = "black"),
    axis.text.y = element_text(color = "black"),
    panel.grid.major.y = element_line(color = "darkgrey"), 
    panel.grid.major.x = element_blank(), 
  )

# Wyjaśnienie dlaczego moja wizualizacja jest lepsza: 
# Od teraz długość słupków łatwo pozwala porównać ilości (nawet tego nieszczęstnego
# niebieskiego i żółtego). Dalej kolory są pokazane w wizualizacji tylko w inny 
# sposób. Co więcej pozbyłem się szumu informacyjnego, ponieważ w oryginale nie
# były pokazane wszystkie kolory (mimo, że i tak było już ich za dużo, to nigdzie
# nie było to wyszczególnione, że jakichś brakuje). Teraz widać, że jest to 
# 20 naczęściej (bo więcej to różnice są coraz mniejsze i trundniejsze do porównania) 
# występujących kolorów oraz są ładnie posortowane.