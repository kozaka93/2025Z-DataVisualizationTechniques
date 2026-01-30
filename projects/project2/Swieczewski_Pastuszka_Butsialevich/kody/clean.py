#Skrypt do oczyszczania jsonow 
import json
from pathlib import Path


if __name__ == "__main__":
    raw = Path("data/raw")
    clean = Path("data/clean")

    to_keep = [
    "ts",
    "ms_played",
    "conn_country",
    "master_metadata_track_name",
    "master_metadata_album_artist_name",
    "master_metadata_album_album_name",
    "spotify_track_uri",
    ]

    for subfolder in raw.iterdir():
        clean_subfolder = clean / subfolder.name
        for file_path in subfolder.iterdir():
            output_file = clean_subfolder / file_path.name
            with open(file_path,"r",encoding="utf-8") as f:
                data = json.load(f)

            cleaned = []

            for entry in data:
                new_entry = {}
                for key in to_keep:
                    if key in entry:
                        new_entry[key] = entry[key]
                cleaned.append(new_entry)
            
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(cleaned,f,indent=4)
