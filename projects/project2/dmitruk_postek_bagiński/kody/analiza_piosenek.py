# %%
import pandas as pd
import json
import os
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
DATA_DIR = PROJECT_ROOT /'TWD_PROJEKT2'/ 'dane'

sciezka_json = DATA_DIR / 'cale_spotify_wika.json'
sciezka_csv = DATA_DIR / 'dataset.csv'
sciezka_csv1 = DATA_DIR / 'spotify_tracks.csv'

with open(sciezka_json, 'r', encoding='utf-8') as f:
    history_data = json.load(f)
df_history = pd.DataFrame(history_data)

# %%
df_history['ts'] = pd.to_datetime(df_history['ts'])
df_history['date'] = df_history['ts'].dt.date
df_history['hour'] = df_history['ts'].dt.hour
df_history['track_name_clean'] = df_history['master_metadata_track_name'].str.lower().str.strip()
df_history['artist_name_clean'] = df_history['master_metadata_album_artist_name'].str.lower().str.strip()
# %%
df_export = df_history[["date","hour","track_name_clean","artist_name_clean"]]
output_path = os.path.join(DATA_DIR, "wika_muzyka_bez.csv")
df_export.to_csv(output_path, index=False, sep=';', encoding='utf-8-sig')
# %%
cols = ['track_name', 'artists', 'valence', 'energy', 'danceability', 'liveness']
kaggle_db = pd.read_csv(sciezka_csv, usecols=cols)
kaggle_db['track_name_clean'] = kaggle_db['track_name'].str.lower().str.strip()
kaggle_db['main_artist_clean'] = kaggle_db['artists'].str.split(';').str[0].str.lower().str.strip()
kaggle_db = kaggle_db.drop_duplicates(subset=['track_name_clean', 'main_artist_clean'])

cols1 = ['track_name', 'artist_name', 'valence', 'energy', 'danceability', 'liveness']

kaggle_db1 = pd.read_csv(sciezka_csv1, usecols=cols1)
kaggle_db1['track_name_clean'] = kaggle_db1['track_name'].str.lower().str.strip()
kaggle_db1['main_artist_clean'] = kaggle_db1['artist_name'].str.split(';').str[0].str.lower().str.strip()
kaggle_db1 = kaggle_db1.drop_duplicates(subset=['track_name_clean', 'main_artist_clean'])
kaggle_db1 = kaggle_db1.rename(columns={"artist_name": "artists"})
kaggle_db = pd.concat([kaggle_db, kaggle_db1], ignore_index=True)

df_merged = pd.merge(
    df_history, 
    kaggle_db, 
    left_on=['track_name_clean', 'artist_name_clean'], 
    right_on=['track_name_clean', 'main_artist_clean'],
    how='inner'
)

print(df_merged.columns)
print(kaggle_db1.columns)
# %%
if not df_merged.empty:
    df_export = df_merged[["date","hour","track_name_clean","artist_name_clean","artists","track_name","danceability","energy","liveness","valence","main_artist_clean"]]
    output_path = os.path.join(DATA_DIR, "wika_muzyka.csv")
    df_export.to_csv(output_path, index=False, sep=';', encoding='utf-8-sig')

    print(f"Sukces! Dopasowano {len(df_merged)} odtworzeń.")
        
else:
    print("Nie udało się dopasować utworów. Sprawdź czy nazwy wykonawców w obu plikach są identyczne.")

total_plays = len(df_history)
matched_plays = len(df_merged)
missing_plays = total_plays - matched_plays
percent_missing = (missing_plays / total_plays) * 100

total_unique = df_history.drop_duplicates(subset=['track_name_clean', 'artist_name_clean']).shape[0]
matched_unique = df_merged.drop_duplicates(subset=['track_name_clean', 'artist_name_clean']).shape[0]
missing_unique = total_unique - matched_unique
percent_missing_unique = (missing_unique / total_unique) * 100

print("-" * 50)
print(f"STATYSTYKI DOPASOWANIA:")
print(f"Całkowita liczba odtworzeń: {total_plays}")
print(f"Odtworzenia znalezione w bazie: {matched_plays}")
print(f"Odtworzenia NIEZNALEZIONE: {missing_plays} ({percent_missing:.2f}%)")
print(f"\nUnikalne utwory w Twojej historii: {total_unique}")
print(f"Unikalne utwory NIEZNALEZIONE: {missing_unique} ({percent_missing_unique:.2f}%)")
print("-" * 50)