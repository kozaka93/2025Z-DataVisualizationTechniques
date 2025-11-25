import pandas as pd

# Load data
df_2020 = pd.read_csv('equipment_processed_2020.csv')
df_2023 = pd.read_csv('equipment_processed.csv')

# Standardize region names (remove whitespace)
df_2020['region'] = df_2020['region'].str.strip()
df_2023['region'] = df_2023['region'].str.strip()

# Merge
merged = pd.merge(df_2020[['region', 'equipment_level', 'ventilator_ratio', 'ecmo_ratio', 'isolation_ratio']],
                  df_2023[['region', 'equipment_level', 'ventilator_ratio', 'ecmo_ratio', 'isolation_ratio']],
                  on='region', suffixes=('_2020', '_2023'))

# Calculate differences
merged['diff_level'] = merged['equipment_level_2023'] - merged['equipment_level_2020']
merged['diff_vent'] = merged['ventilator_ratio_2023'] - merged['ventilator_ratio_2020']
merged['diff_ecmo'] = merged['ecmo_ratio_2023'] - merged['ecmo_ratio_2020']
merged['diff_iso'] = merged['isolation_ratio_2023'] - merged['isolation_ratio_2020']

# Sort by difference in level
merged_sorted = merged.sort_values('diff_level', ascending=False)

print("Comparison of Equipment Levels (2023 - 2020):")
print(merged_sorted[['region', 'equipment_level_2020', 'equipment_level_2023', 'diff_level']].to_string())

print("\nTop 3 Increases:")
print(merged_sorted.head(3)[['region', 'diff_level', 'diff_iso']])

print("\nTop 3 Decreases:")
print(merged_sorted.tail(3)[['region', 'diff_level', 'diff_iso']])
