# Oryginalna wizualizacja:
#     - post z hashtagiem #TidyTuesday:
#       https://x.com/maria_alexus/status/1985875185887494413
#     - dane z repozytorium TidyTuesday (Selected British Literary Prizes):
#       https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-10-28
#
# Co wymagało poprawy:
#     Oryginalny wykres ma segmenty ułożone w nielogicznej kolejności
#     (None -> Doctorate -> Unknown -> Masters -> Bachelors), przez co trudno
#     porównywać poziomy wykształcenia. Dodatkowo wykres nie podaje liczebności
#     grup ani osi z wartościami, a kategoria „Unknown” jest wyróżniona
#     równie intensywnie jak realne stopnie, co może ją nadmiernie eksponować.
#
# Poniższy kod tworzy poprawioną wizualizację:
#     - górny panel: porównanie struktury wykształcenia w dwóch grupach
#       (Winner vs Shortlisted) jako wykres słupkowy skumulowany,
#       z uporządkowanymi kategoriami i opisem n w podtytule,
#     - dolny panel: różnice w udziałach procentowych (Winner – Shortlisted)
#       w punktach procentowych (lollipop chart).
#
# Dlaczego nowy wykres jest lepszy:
#     Nowy wykres porządkuje poziomy wykształcenia od „None” do „Doctorate”,
#     dodaje informację o liczebnościach grup i wyraźną oś procentową,
#     a dodatkowy panel z różnicami w punktach procentowych jasno pokazuje,
#     przy jakich stopniach zwycięzcy są nad lub niedoreprezentowani
#     względem osób z shortlisty.
# 
# pakiety ----
library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)
library(janitor)
library(scales)
library(showtext)
library(ggtext)
library(patchwork)

# czcionki ------------
font_family <- "barlow"
showtext_auto()
tryCatch(
  font_add_google("Barlow", font_family),
  error = function(e) {
    message("font_add_google failed; falling back to system sans. Reason: ", e$message)
    font_family <<- "sans"
  }
)

# kolory / motyw --------
bg   <- "#f6f2e9"
txt  <- "#181818"

degree_cols <- c(
  "None"      = "#597E52",
  "Bachelors" = "#3D5A80",
  "Masters"   = "#E09F3E",
  "Doctorate" = "#C3444F",
  "Unknown"   = "#C7CED6"
)

theme_prizes <- function() {
  theme_minimal(base_family = font_family) +
    theme(
      plot.background   = element_rect(fill = bg, colour = NA),
      panel.background  = element_rect(fill = bg, colour = NA),
      panel.grid.minor  = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.text         = element_text(colour = txt, size = 13),
      axis.title        = element_text(colour = txt, size = 13, face = "bold"),
      plot.title        = element_markdown(
        face = "bold", size = 24, colour = txt,
        margin = margin(b = 4)
      ),
      plot.subtitle     = element_text(size = 15, colour = "grey25",
                                       margin = margin(b = 10)),
      plot.caption      = element_text(size = 11, colour = "grey40",
                                       hjust = 0, margin = margin(t = 8)),
      legend.position   = "bottom",
      legend.title      = element_text(size = 12),
      legend.text       = element_text(size = 11.5),
      plot.margin       = margin(12, 16, 12, 16)
    )
}

# dane ---------------------------------------
prizes_path <- file.path("data", "prizes.csv")
prizes_url  <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-10-28/prizes.csv"
read_any_csv <- function(path) {
  if (requireNamespace("readr", quietly = TRUE)) readr::read_csv(path, show_col_types = FALSE)
  else read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

prizes <- (if (file.exists(prizes_path)) read_any_csv(prizes_path) else read_any_csv(prizes_url)) |>
  clean_names()

degree_levels <- c("None", "Bachelors", "Masters", "Doctorate", "Unknown")

prizes_deg <- prizes |>
  filter(person_role %in% c("winner", "shortlisted")) |>
  mutate(
    degree_raw = str_to_lower(highest_degree),
    degree = case_when(
      is.na(highest_degree) ~ "Unknown",
      str_detect(degree_raw, "none|no degree") ~ "None",
      str_detect(degree_raw, "bachelor")       ~ "Bachelors",
      str_detect(degree_raw, "master")         ~ "Masters",
      str_detect(degree_raw, "doctor|phd|dphil|md|juris doctor") ~ "Doctorate",
      TRUE ~ "Unknown"
    ),
    degree = factor(degree, levels = degree_levels),
    role   = recode(person_role,
                    winner = "Winner",
                    shortlisted = "Shortlisted")
  )

deg_summary <- prizes_deg |>
  count(role, degree) |>
  group_by(role) |>
  mutate(
    pct   = n / sum(n),
    label = percent(pct, accuracy = 1)
  ) |>
  ungroup()

group_labels <- deg_summary |>
  group_by(role) |>
  summarise(n_total = sum(n), .groups = "drop") |>
  mutate(label = paste0("n = ", n_total))

subtitle_text <- sprintf(
  "Shares within group; winners n = %s · shortlisted n = %s. Selected British literary prizes, 1990–2022.",
  comma(group_labels$n_total[group_labels$role == "Winner"]),
  comma(group_labels$n_total[group_labels$role == "Shortlisted"])
)

# różnice (Winner – Shortlisted) --------------------------------------
deg_diff <- deg_summary |>
  select(role, degree, pct) |>
  pivot_wider(names_from = role, values_from = pct, values_fill = 0) |>
  mutate(
    diff = Winner - Shortlisted,
    sign = case_when(
      diff > 0 ~ "Winner higher",
      diff < 0 ~ "Shortlisted higher",
      TRUE ~ "No difference"
    ),
    text_y = diff + if_else(diff > 0, 0.005, -0.005)
  )

sign_cols <- c(
  "Winner higher" = "#3D5A80",
  "Shortlisted higher" = "#C3444F",
  "No difference" = "grey50"
)

# panel 1: udziały ----------------------------------
p1 <- ggplot(deg_summary,
             aes(x = role, y = pct, fill = degree)) +
  geom_col(width = 0.7, colour = bg, linewidth = 0.3) +
  geom_text(
    data = ~ dplyr::filter(.x, pct >= 0.035),
    aes(label = label),
    position = position_stack(vjust = 0.5),
    family = font_family, size = 4.2, colour = txt
  ) +
  geom_text(
    data = group_labels,
    aes(x = role, y = 1.015, label = label),
    family = font_family,
    size = 4.8,
    fontface = "bold",
    colour = txt,
    inherit.aes = FALSE
  ) +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_fill_manual(values = degree_cols, name = "Highest degree") +
  labs(
    title = "Education levels of winners vs shortlisted authors",
    subtitle = subtitle_text,
    y = "Share of authors within role",
    x = NULL,
    caption = "Data: Selected British Literary Prizes (SBLP) #TidyTuesday 2025 W43\nDegrees grouped into None, Bachelors, Masters, Doctorate; other / missing values -> Unknown."
  ) +
  coord_cartesian(clip = "off") +
  theme_prizes()

# panel 2: lollipop z różnicą ---------------------------------------
p2 <- ggplot(deg_diff,
             aes(x = degree, y = diff, fill = sign, colour = sign)) +
  geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.4) +
  geom_segment(aes(xend = degree, y = 0, yend = diff),
               linewidth = 2) +
  geom_point(size = 3) +
  geom_text(
    aes(y = text_y, label = percent(diff, accuracy = 1)),
    family = font_family, size = 3.8, colour = txt,
    hjust = 0.5
  ) +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    limits = ~ max(abs(.x)) * c(-1.2, 1.2),
    expand = expansion(mult = c(0.02, 0.08))
  ) +
  scale_fill_manual(values = sign_cols, name = NULL, drop = FALSE) +
  scale_colour_manual(values = sign_cols, name = NULL, drop = FALSE) +
  labs(
    title = "Difference in share (Winner – Shortlisted)",
    subtitle = "Positive values indicate degrees more common among winners",
    x = NULL,
    y = "Percentage points"
  ) +
  coord_flip() +
  theme_prizes() +
  theme(
    legend.position = "none",
    plot.title = element_markdown(size = 15, face = "bold"),
    plot.subtitle = element_text(size = 11),
    plot.caption = element_blank()
  )


# połączenie + zapis -------------------------------------
final_plot <- p1 / p2 + plot_layout(heights = c(2.2, 1.4))

final_plot

ggsave(
  "british_prizes_education.png",
  final_plot,
  width = 9,
  height = 7,
  dpi = 320,
  bg = bg
)

