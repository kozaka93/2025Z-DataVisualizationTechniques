# Load libraries
library(sf)
library(ggplot2)
library(dplyr)
library(giscoR)
library(stringr) # For string manipulation
library(purrr)

# Helper: canonicalize names to robust join key (lowercase, remove NBSP, collapse spaces, keep hyphens)
canonicalize <- function(x) {
  x %>%
    str_replace_all("\u00A0", " ") %>%        # replace non-breaking spaces
    str_replace_all("[[:space:]]+", " ") %>%   # collapse whitespace
    str_trim() %>%
    str_to_lower() %>%
    # remove trailing commas or accidental punctuation
    str_replace_all(",+$", "")
}

# --- 1. Load Data ---
# Read the equipment data
equipment_data <- read.csv("equipment_processed.csv")

# Get administrative boundaries for Poland (Voivodeships are NUTS level 2)
poland_map <- gisco_get_nuts(
  country = "PL",
  nuts_level = "2",
  resolution = "03"
) %>%
  st_transform(crs = 4326)

# --- 2. Prepare and Standardize Data for Merging ---
# Standardize region names to Title Case for consistent matching.
equipment_data_agg <- equipment_data %>%
  mutate(region_original = region,
         region_key = canonicalize(region)) %>%
  group_by(region_key) %>%
  summarise(level_normalized = mean(level_normalized, na.rm = TRUE), .groups = 'drop') %>%
  # Recover a display name (Title Case) from first occurrence
  left_join(
    equipment_data %>% mutate(region_key = canonicalize(region)) %>% distinct(region_key, region) %>%
      mutate(NAME_LATN = str_to_title(str_trim(region))),
    by = "region_key"
  ) %>%
  select(region_key, NAME_LATN, level_normalized)

# Standardize map names as well
poland_map <- poland_map %>%
  mutate(NAME_LATN = str_to_title(NAME_LATN)) %>%
  mutate(region_key_raw = canonicalize(NAME_LATN)) %>%
  mutate(region_key = dplyr::case_when(
    region_key_raw %in% c("warszawski stołeczny", "mazowiecki regionalny") ~ "mazowieckie",
    TRUE ~ region_key_raw
  )) %>%
  select(-region_key_raw)

# --- 3. Debugging: Print names from both sources ---
print("--- Debugging Region Names ---")
print("Names from your CSV (equipment_processed.csv) [canonical keys]:")
print(sort(unique(equipment_data_agg$region_key)))
print("Names from the Map Data (giscoR) [canonical keys]:")
print(sort(unique(poland_map$region_key)))
print("Set difference (CSV -> Map):")
print(setdiff(equipment_data_agg$region_key, poland_map$region_key))
print("Set difference (Map -> CSV):")
print(setdiff(poland_map$region_key, equipment_data_agg$region_key))
print("--- End Debugging ---")

# --- 4. Merge Map and Equipment Data ---
# Join the map data with your aggregated equipment data.
poland_map_data <- poland_map %>%
  left_join(equipment_data_agg, by = "region_key")

# Resolve duplicated name columns from the join (NAME_LATN.x from map, NAME_LATN.y from CSV)
poland_map_data <- poland_map_data %>%
  mutate(NAME_LATN = dplyr::coalesce(.data$NAME_LATN.x, .data$NAME_LATN.y)) %>%
  select(-dplyr::any_of(c("NAME_LATN.x", "NAME_LATN.y")))

# --- 5. Validate the Merge ---
# Check for any voivodeships that didn't get data after the merge.
missing_data_regions <- poland_map_data %>%
  filter(is.na(level_normalized)) %>%
  pull(NAME_LATN)

if (length(missing_data_regions) > 0) {
  warning("The following voivodeships could not be matched and have no data: ", 
          paste(missing_data_regions, collapse = ", "))
} else {
  print("✓ All voivodeships successfully merged with data.")
}

# --- 6. Create the Visualization ---
# Define colors for the annotation
color_vent <- "#1f77b4" # Blue
color_ecmo <- "#2ca02c" # Green
color_iso <- "#9467bd"  # Purple

# Create a custom grob for the annotation (Top-Left Corner)
# We use normalized coordinates (0-1) relative to the plot area
weights_grob <- grid::grobTree(
  # Line 1: Weights and values
  grid::textGrob("Weights:", x = 0.02, y = 0.95, hjust = 0, gp = grid::gpar(fontsize = 12, fontface = "bold", col = "black")),
  grid::textGrob("0.12", x = 0.12, y = 0.95, hjust = 0, gp = grid::gpar(fontsize = 14, fontface = "bold", col = color_vent)),
  grid::textGrob("|", x = 0.17, y = 0.95, hjust = 0.5, gp = grid::gpar(fontsize = 12, col = "black")),
  grid::textGrob("0.47", x = 0.22, y = 0.95, hjust = 0.5, gp = grid::gpar(fontsize = 14, fontface = "bold", col = color_ecmo)),
  grid::textGrob("|", x = 0.27, y = 0.95, hjust = 0.5, gp = grid::gpar(fontsize = 12, col = "black")),
  grid::textGrob("0.41", x = 0.32, y = 0.95, hjust = 0, gp = grid::gpar(fontsize = 14, fontface = "bold", col = color_iso)),
  
  # Line 2: Labels (aligned roughly with values)
  grid::textGrob("Ventilators", x = 0.12, y = 0.91, hjust = 0, gp = grid::gpar(fontsize = 10, fontface = "bold", col = color_vent)),
  grid::textGrob("|", x = 0.20, y = 0.91, hjust = 0.5, gp = grid::gpar(fontsize = 10, col = "black")),
  grid::textGrob("ECMO", x = 0.22, y = 0.91, hjust = 0.5, gp = grid::gpar(fontsize = 10, fontface = "bold", col = color_ecmo)),
  grid::textGrob("|", x = 0.27, y = 0.91, hjust = 0.5, gp = grid::gpar(fontsize = 10, col = "black")),
  grid::textGrob("Isolation", x = 0.32, y = 0.91, hjust = 0, gp = grid::gpar(fontsize = 10, fontface = "bold", col = color_iso))
)

# Plot the map with a gradient fill for 'level_normalized'.
ggplot(data = poland_map_data) +
  geom_sf(aes(fill = level_normalized), color = "white", size = 0.2) +
  scale_fill_viridis_c(
    option = "plasma",
    name = "Normalized\nEquipment Level",
    limits = c(0,1),
    na.value = "lightgrey",
    guide = guide_colorbar(barwidth = 0.7, barheight = 15)
  ) +
  labs(
    title = "Medical Equipment Level by Voivodeship",
    subtitle = "Normalized index (0-1 scale) comparing equipment availability relative to patient needs.\nHigher values indicate better equipment-to-patient ratios.",
    caption = "Data source: equipment_processed.csv"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right"
  ) +
  coord_sf(clip = "off") + # Allow text to spill over if needed
  # Add the custom annotation
  annotation_custom(grob = weights_grob)

# To save the plot to a file:
ggsave("poland_equipment_map.png", width = 10, height = 8, dpi = 300)
