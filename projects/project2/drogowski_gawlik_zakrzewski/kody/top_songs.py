import pandas as pd

FILES = {
    "Adam": "dane/dane_adam.csv",
    "Basia": "dane/dane_basia.csv",
    "Paweł": "dane/dane_pawel.csv"
}

wyniki = []

for user, path in FILES.items():
    df = pd.read_csv(path)

    df = df.dropna(
        subset=[
            "master_metadata_track_name",
            "master_metadata_album_artist_name"
        ]
    )

    top_tracks = (
        df
        .groupby(
            ["master_metadata_track_name", "master_metadata_album_artist_name"]
        )
        .size()
        .reset_index(name="play_count")
        .sort_values("play_count", ascending=False)
        .head(10)
    )

    for _, row in top_tracks.iterrows():
        wyniki.append({
            "user": user,
            "track": row["master_metadata_track_name"],
            "artist": row["master_metadata_album_artist_name"],
            "play_count": row["play_count"]
        })


result_df = pd.DataFrame(wyniki)
result_df.to_csv("dane/our_top_30_songs.csv", index=False, encoding="utf-8")

print("Gotowe! Zapisano plik: dane/our_top_30_songs.csv")