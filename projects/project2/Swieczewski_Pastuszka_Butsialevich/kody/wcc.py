#skrypt do stworzenia json z word frequencies, zeby troche przyspieszyc bierzemy tylko
#>=3 literowe oraz piosenki ktorych laczny czas sluchania stanowi 90% calego (roznica jest spora
#7200 ogl vs 2300 stanowiacych 90%)
import lyricsgenius
from collections import Counter
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import regex as re
import nltk
import json
import time
from process import process
from stop_words import get_stop_words

if __name__ == "__main__":
    GENIUS_TOKEN = "8AriRly56vdQZb9VB8nb8lsADCVeTM3bM5_aV0GjlKp6gn447BI2MnoJbaf4ywM7"  
    genius = lyricsgenius.Genius(GENIUS_TOKEN, timeout=15, retries=3, sleep_time=0.5)

    nltk.download('stopwords')
    nltk.download('wordnet')

    stop_words_en = set(stopwords.words('english'))
    stop_words_pl = set(get_stop_words('polish'))
    stop_words = stop_words_en.union(stop_words_pl)
    lemmatizer = WordNetLemmatizer()

    filler_words = set([
        'verse','chorus','bridge','outro','embed','album','remix','ft','feat','lyrics',
        'prehook','hook','part','intro','ooh','oohooh','aah','ah','oh','yeah','na','la',
        'przedrefren','refren','zwrotka','mostek','wstęp','ooo','aaa','haha','heh'
    ])

    dfs = process()

    for user, df in dfs.items():
        agg = df.groupby(['artist_name', 'track_name'])['s_played'].sum().reset_index()
        agg = agg.sort_values('s_played', ascending=False)
        agg['cumsum'] = agg['s_played'].cumsum()
        agg['cum_frac'] = agg['cumsum'] / agg['s_played'].sum()
        top_tracks = agg[agg['cum_frac'] <= 0.9]
        total_tracks = len(top_tracks)
        freq_dict = {}
        i = 1

        for t, row in top_tracks.iterrows():
            artist = row['artist_name']
            track = row['track_name']
            key = f"{artist}_{track}"

            try:
                song = genius.search_song(track, artist)
                lyrics = song.lyrics if song and song.lyrics else ""
                lyrics = lyrics.lower()
                lyrics = re.sub(r"[^\p{L}\s]", " ", lyrics)
                tokens = re.findall(r'\b\p{L}{3,}\b', lyrics)
                tokens = [
                    lemmatizer.lemmatize(t) for t in tokens if t not in stop_words and t not in filler_words
                ]
                freq_dict[key] = dict(Counter(tokens))
                print(f"{i}/{total_tracks}")
                i += 1
                time.sleep(0.5) 
            except Exception as e:
                freq_dict[key] = {}
                i += 1

        json_path = f"{user}.json"
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(freq_dict, f, ensure_ascii=False, indent=2)
