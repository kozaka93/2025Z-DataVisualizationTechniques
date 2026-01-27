import pandas as pd
import glob
import json
import os
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
DATA_DIR = PROJECT_ROOT / 'dane'

folder_path = DATA_DIR / 'messages'
file_pattern = os.path.join(folder_path, "*.json")
all_files = glob.glob(file_pattern)

all_messages = []

print(f"Znaleziono {len(all_files)} plików JSON. Rozpoczynam łączenie...")
for file_path in all_files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

            if 'messages' in data:
                all_messages.extend(data['messages'])
                print(f"Dodano dane z: {os.path.basename(file_path)}")
                
    except Exception as e:
        print(f"Błąd przy pliku {file_path}: {e}")

full_df = pd.DataFrame(all_messages)
output_path = os.path.join(DATA_DIR, "wszystkie_wiadomosci_ola.csv")
full_df.to_csv(output_path, index=False, sep=';', encoding='utf-8-sig')

print(f"\nSukces! Połączono {len(full_df)} wiadomości.")
print(f"Połączone dane zapisano w: {output_path}")