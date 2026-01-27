# Tomasz Stolarczyk, 333090

# -------------- 0. ORYGINALNA WIZUALIZACJA ------------

# Link do posta:
# https://x.com/GDataScience1/status/1759400123770257627
# Dane:
# https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-02-13/readme.md

# -------------- 1. CO WYMAGA POPRAWY ------------

# Krótkie uzasadnienie, jakie elementy wykresu wymagają poprawy:

# 1. Oryginalna wizualizacja wprowadza w błąd poprzez zastosowanie niezależnych skal osi Y
#   dla każdej kategorii bez wyraźnego tego oznaczenia, 
#   co wizualnie zrównuje kategorie o niskich wydatkach z tymi wysokimi. 

# 2. Dodatkowo rozbicie danych na dziewięć osobnych wykresów liniowych rozprasza informacje, 
#   utrudniając bezpośrednie porównanie wydatków między kategoriami oraz
#   szybką identyfikację najistotniejszych kosztów na pierwszy rzut oka.

# Pora zrobić to lepiej... :)

# -------------- 2. ZACIĄGNIJMY DANE I BIBLIOTEKI ------------

library(tidyverse)
library(tidytuesdayR)
tuesdata <- tidytuesdayR::tt_load(2024, week = 7)
spending <- tuesdata$historical_spending

# -------------- 3. PRZYGOTUJMY DANE DO  WYKRESU ------------

plot_data <- spending %>%
  # obliczymy kolumne other, poniewaz autor posta to uwzglednil, a nie ma tego poczatkowo w danych
  mutate(Other = PerPerson - (Candy + Flowers + Jewelry + GreetingCards + EveningOut + Clothing + GiftCards)) %>%
  pivot_longer(
    cols = c(Candy, Flowers, Jewelry, GreetingCards, EveningOut, Clothing, GiftCards, Other),
    names_to = "Category",
    values_to = "Amount"
  ) %>%
  # poprawmy nazwy kategorii, dodajemy spacje
  mutate(Category = gsub("([a-z])([A-Z])", "\\1 \\2", Category)) %>%
  # posortujemy kategorie malejaco tak zeby heat mapa byla ladna 
  mutate(Category = fct_reorder(Category, Amount, .fun = mean, .desc = FALSE))

# -------------- 4. STWÓRZMY WIZUALIZACJĘ W POSTACI HEAT MAPY ------------

# estetyka bedzie w walentynkowych klimatach, żeby ładnie 
# to wszystko się prezentowało

ggplot(plot_data, aes(x = factor(Year), y = Category, fill = Amount)) +
  geom_tile(color = "white", linewidth = 1.2) + 
  geom_text(aes(label = round(Amount, 0), color = ifelse(Amount > 25, "white", "#6A1B4D")), size = 3.5, fontface = "bold") +
  scale_fill_gradient(low = "#FFEBEE", high = "#880E4F", name = "Amount ($)") +
  scale_color_identity() + 
  labs(
    title = "The True Cost of Love: Valentine's Day Spending",
    subtitle = "Average per person spending in the US (2010-2022) by category",
    x = "",
    y = "",
    caption = "Darker color indicates higher spending.\nData: National Retail Federation via #TidyTuesday | DataVis: Tomasz Stolarczyk"
  ) +
  theme_minimal(base_family = "serif") + 
  theme(
    plot.background = element_rect(fill = "#FFF5F7", color = NA),
    panel.background = element_rect(fill = "#FFF5F7", color = NA),
    plot.title = element_text(size = 22, face = "bold", color = "#6A1B4D", hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(size = 14, color = "#AD1457", hjust = 0.5, margin = margin(b = 20)),
    plot.caption = element_text(size = 10, color = "#9E9E9E", margin = margin(t = 20)),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, color = "#4A4A4A"),
    axis.text.y = element_text(size = 11, face = "bold", color = "#880E4F"),
    panel.grid = element_blank(),
    legend.position = "right"
  )

# -------------- 5. DLACZEGO NASZA WIZUALIZACJA JEST LEPSZA OD ORYGINAŁU ------------

# Krótkie wyjaśnienie, dlaczego przygotowany wykres jest lepszy od oryginału:

# 1. Zmieniłem formę wizualizacji na heatmapę, aby zaprezentować wszystkie kategorie na jednym,
#   spójnym panelu, co eliminuje problem fragmentaryzacji porównań. 
# 
# 2. Dzięki zakodowaniu wartości intensywnością koloru (ciemniejszy odcień = wyższy koszt) 
#   odbiorca może natychmiast wychwycić kluczowe trendy - takie jak dominacja wydatków na biżuterię 
#   i wyjścia – a ujednolicona skala wraz z etykietami liczbowymi zapewnia precyzję
#   danych i zapobiega ich błędnej interpretacji.
#
# 3. Dodatkowo zadbałem o spójną, walentynkową estetykę, która czyni wizualizację nie tylko poprawną 
#   merytorycznie, ale także atrakcyjną wizualnie i przyjemną w odbiorze

# chyba udalo nam sie zrobic to lepiej! :)