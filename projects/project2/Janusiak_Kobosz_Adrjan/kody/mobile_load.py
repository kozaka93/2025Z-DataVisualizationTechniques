from data_load import classify_activity, delete_cache
import pandas as pd
import numpy as np
import json
from sys import argv

def load_mobile_data(bucket: str, person: str) -> None:
    with open(bucket, 'r', encoding='utf-8') as f: #Scieżka
        raw_data = json.load(f)
    data = raw_data['buckets']['aw-watcher-android-test']['events']
    df_out = pd.DataFrame()
    df_out['timestamp'] = [i['timestamp'] for i in data]
    df_out['duration'] = [i['duration'] for i in data]
    df_out['app'] = [i['data']['app'] for i in data]
    df_out['status'] = 'not-afk'
    df_out['device'] = 'Phone'
    df_out['osoba'] = person
    df_out['category'] = df_out['app'].apply(classify_activity)
    df_out["timestamp"] = pd.to_datetime(df_out["timestamp"], format="ISO8601", utc=True)
    time_temp = df_out['timestamp'].max().strftime("%d.%m.%Y")
    df_out['timestamp'] = df_out['timestamp'].dt.strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    df_out.to_json(
    f"Dane Dash\\MOBILE-SUM-{person}-{time_temp}.json",
    orient="records",
    indent=4,
    force_ascii=False
    )
if __name__ == "__main__":
    load_mobile_data(f"Dane prywatne\\{argv[1]}.json", argv[2])
    delete_cache()