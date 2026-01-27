#skrypt do procesowania df - zmiana nazw kolumn, ekstrakcja daty, nowa flaga skipped
import json
from pathlib import Path
import pandas as pd

def process():
    BASE_DIR = Path(__file__).parent.parent  
    clean = BASE_DIR / "data" / "clean"
    users = ["piotr","maciek","zenia"]
    dfs = {}

    for user in users:
        user_folder = clean / user
        dfs_temp = []

        for file_path in user_folder.iterdir():
            with open(file_path,"r",encoding="utf-8") as f:
                data = json.load(f)
                dfs_temp.append(pd.DataFrame(data))

        df = pd.concat(dfs_temp,ignore_index=True)

        df.rename(columns={
            "ms_played": "s_played",
            "master_metadata_track_name": "track_name",
            "master_metadata_album_artist_name": "artist_name",
            "master_metadata_album_album_name": "album_name"
        },inplace=True)

        df['s_played'] = (df['s_played']/1000).round(1)
        df['h_played'] = (df['s_played']/3600).round(1)
        df["ts"] = pd.to_datetime(df["ts"])
        df['hour'] = df['ts'].dt.hour.astype(int)
        df['weekday'] = df['ts'].dt.weekday.astype(int)
        df['day'] = df['ts'].dt.day.astype(int)
        df['month'] = df['ts'].dt.month.astype(int)
        df['year'] = df['ts'].dt.year.astype(int)
        
        #w oryginalnych danych utwor ma flage pominiety nawet jezeli sie odslucha 98% 
        #odfiltrowuje <3s bo ciezko mowic o pominieciu, pominiete to te <15s sluchania
        df = df[df['s_played'] > 3]
        df["skipped"] = df["s_played"] < 15 
        dfs[user] = df

    return dfs