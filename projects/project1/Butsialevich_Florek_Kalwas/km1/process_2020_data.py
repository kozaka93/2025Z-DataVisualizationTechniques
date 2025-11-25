import pandas as pd
import numpy as np

# --- 1. Load and Clean Data ---
# Read tab.csv, skipping header rows to get to the data
# Based on inspection, data starts at row 7 (index 6)
# Columns of interest: 0 (Region), 7 (Vent dev), 8 (Vent pat), 9 (ECMO dev), 10 (ECMO pat), 11 (Iso dev), 12 (Iso pat)
try:
    df = pd.read_csv('tab.csv', header=None, skiprows=6)
    
    # Select relevant columns
    df = df.iloc[:, [0, 7, 8, 9, 10, 11, 12]]

    # Rename columns
    df.columns = [
        'region', 
        'ventilator_devices', 'ventilator_patients',
        'ecmo_devices', 'ecmo_patients',
        'isolation_transport_devices', 'isolation_transport_patients'
    ]

    # Filter out aggregate rows and empty rows
    df = df.dropna(subset=['region'])
    df = df[~df['region'].str.contains('POLSKA|POLAND|VOIVODSHIPS', case=False, na=False)]

    # Clean numeric columns
    numeric_cols = [
        'ventilator_devices', 'ventilator_patients',
        'ecmo_devices', 'ecmo_patients',
        'isolation_transport_devices', 'isolation_transport_patients'
    ]

    for col in numeric_cols:
        # Replace '-' with 0, remove spaces, convert to numeric
        df[col] = df[col].astype(str).str.replace('-', '0').str.replace(' ', '').str.replace(',', '')
        df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0)

    print(f"Loaded {len(df)} regions.")

    # --- 2. Calculate Ratios ---

    # Handle division by zero (if patients = 0, set ratio to NaN or 0)
    for col in ['ventilator_patients', 'ecmo_patients', 'isolation_transport_patients']:
        df[col] = df[col].replace(0, np.nan)

    df['ventilator_ratio'] = df['ventilator_devices'] / df['ventilator_patients']
    df['ecmo_ratio'] = df['ecmo_devices'] / df['ecmo_patients']
    df['isolation_ratio'] = df['isolation_transport_devices'] / df['isolation_transport_patients']

    # Fill NaN ratios with 0
    df['ventilator_ratio'] = df['ventilator_ratio'].fillna(0)
    df['ecmo_ratio'] = df['ecmo_ratio'].fillna(0)
    df['isolation_ratio'] = df['isolation_ratio'].fillna(0)

    # --- 3. Calculate Weighted Equipment Level ---
    # Weights provided by user
    w_vent = 0.12
    w_ecmo = 0.47
    w_iso = 0.41

    df['equipment_level'] = (w_vent * df['ventilator_ratio'] + 
                             w_ecmo * df['ecmo_ratio'] + 
                             w_iso * df['isolation_ratio'])

    # Normalize to 0-1 scale
    min_level = df['equipment_level'].min()
    max_level = df['equipment_level'].max()
    if max_level - min_level == 0:
        df['level_normalized'] = 0
    else:
        df['level_normalized'] = (df['equipment_level'] - min_level) / (max_level - min_level)

    print("Calculated weighted equipment levels.")

    # --- 4. Save Processed Data ---
    output_file = 'equipment_processed_2020.csv'
    df.to_csv(output_file, index=False)
    print(f"Saved processed data to {output_file}")
    print(f"Columns: {df.columns.tolist()}")

except Exception as e:
    print(f"An error occurred: {e}")
