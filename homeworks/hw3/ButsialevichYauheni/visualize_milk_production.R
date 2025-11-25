library(sf)
library(ggplot2)
library(dplyr)
library(giscoR)
library(stringr)
library(tidyr)
library(readr)

# --- 1. Data Processing ---


if (!file.exists("estat_tag00041.tsv")) {
  stop("File 'estat_tag00041.tsv' not found in the working directory.")
}

raw_data <- read_tsv("estat_tag00041.tsv", show_col_types = FALSE)

# Rename the first column to handle the composite key
colnames(raw_data)[1] <- "composite_key"

# Separate the composite key into columns

processed_data <- raw_data %>%
  separate(composite_key, into = c("freq", "dairyprod", "milkitem", "geo"), sep = ",") %>%
  mutate(geo = str_trim(geo))

# Reshape to long format
long_data <- processed_data %>%
  pivot_longer(
    cols = -c(freq, dairyprod, milkitem, geo),
    names_to = "year",
    values_to = "value_raw"
  )

# Clean the values
clean_data <- long_data %>%
  mutate(
    # Extract numeric part from values like "3424.60", "214.09 p", ":"
    value_clean = suppressWarnings(as.numeric(str_extract(value_raw, "^[0-9.]+"))),
    year = as.integer(str_trim(year))
  ) %>%
  filter(!is.na(value_clean))

# Filter for "Production of milk on farms"
target_data <- clean_data %>%
  filter(dairyprod == "D1100A", milkitem == "PRO")

# Save to CSV as requested
write_csv(target_data, "milk_production_processed.csv")
message("Processed data saved to 'milk_production_processed.csv'")

# --- 2. Prepare Map Data ---

# Select the most recent year with good coverage
# Let's check 2023.
target_year <- 2023
map_data_values <- target_data %>%
  filter(year == target_year) %>%
  select(geo, value_clean)

# Get EU map data (NUTS 0 for countries)
# resolution = "10" is good for continental maps
eu_map <- gisco_get_nuts(
  nuts_level = "0",
  resolution = "10",
  year = "2021"
) %>%
  st_transform(crs = 3035) # LAEA Europe projection

# Merge map and data
# Eurostat uses 2-letter codes (NUTS_ID)
map_merged <- eu_map %>%
  left_join(map_data_values, by = c("NUTS_ID" = "geo"))

# Define a bounding box to focus on Europe (exclude distant territories like French Guiana)
# Coordinates in EPSG:3035
europe_bbox <- st_bbox(c(xmin = 2500000, xmax = 7000000, ymin = 1500000, ymax = 5500000), crs = st_crs(3035))
map_cropped <- st_crop(map_merged, europe_bbox)

# --- 3. Visualization ---

# Create the map
p <- ggplot(data = map_cropped) +
  geom_sf(aes(fill = value_clean), color = "white", size = 0.2) +
  scale_fill_viridis_c(
    option = "mako",
    direction = -1, 
    name = "Milk Production\n(1000 tonnes)",
    na.value = "#f0f0f0",
    label = scales::comma,
    guide = guide_colorbar(barwidth = 0.7, barheight = 15)
  ) +
  labs(
    title = paste("Production of Milk on Farms in Europe (", target_year, ")", sep = ""),
    subtitle = "Volume in 1000 tonnes. Data source: Eurostat.",
    caption = "Visualization by GitHub Copilot"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold", color = "#2c3e50"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "#7f8c8d"),
    plot.caption = element_text(size = 8, color = "#95a5a6"),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.title = element_text(size = 10, face = "bold"),
    plot.background = element_rect(fill = "white", color = NA)
  )

# Save the plot
ggsave("europe_milk_production_map.png", plot = p, width = 12, height = 10, dpi = 300)
message("Map saved to 'europe_milk_production_map.png'")
