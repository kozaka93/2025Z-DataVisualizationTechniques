import pandas as pd
import numpy as np
import json
from sys import argv
from os import system

def classify_activity(combined):
    
    
    combined = combined.lower()
    
    # 3. Gry komputerowe
     # 4. Oglądanie filmów
    video_keywords = [
        'youtube', 'youtu.be', 'netflix', 'hbo', 'disney', 'prime video', 
        'twitch', 'vlc', 'potplayer', 'cda', 'film', 'movie', 'serial', 
        'wmplayer', 'windows media player', 'vod'        
    ]
    if any(k in combined for k in video_keywords):
        return 'oglądanie filmów'

    game_keywords = [
        'steam','sandfall-win64-shipping.exe', 'epic games', 'riot', 'league of legends', 'lol', 'valorant', 
        'cs', 'counter-strike', 'minecraft', 'roblox', 'fortnite', 'gta', 
        'wiedźmin', 'cyberpunk', 'blizzard', 'battlenet', 'ubisoft', 'game', 
        'gra', 'binding of isaac', 'hollow knight', 'clash of clans', 'half-life', 'half life',
        'oldboy', 'myboy', 'melonds', 'drastic', 'citra', 'clash royale', 'sandfall', 'aces',
        'clash of clans', 'warthunder','aces.exe','foundry.exe','kr battles',
        'factorio.exe','geometry dash'

        ]
    if any(k in combined for k in game_keywords):
        return 'gry komputerowe'
    
    # 2. Komunikatory
    comm_keywords = [
        'discord', 'messenger', 'whatsapp', 'signal', 'telegram', 'wiadomości', 'połącz',
        'zoom', 'slack', 'skype', 'outlook', 'poczta', 'mail', 'thunderbird', 'wiadomości',
        'facebook','twitter', 'x.com', ' x — ','linkedin','reddit', 'telefon','instagram'
    ]
    if any(k in combined for k in comm_keywords):
        return 'komunikatory'   
   
    # 5. Muzyka
    music_keywords = [
        'spotify', 'tidal', 'apple music', 'soundcloud', 'deezer', 'foobar', 
        'winamp', 'music', 'muzyka',
    ]
    if any(k in combined for k in music_keywords):
        return 'muzyka'
    
    # 1. Studia 
    
    ds_keywords = [
        'python', 'pandas', 'numpy', 'scikit', 'sklearn', 'jupyter', 'colab', 
        'code.exe', 'visual studio', 'vscode', 'pycharm', 'rstudio','to do',
        'matlab', 'mathworks', 'simulink', 'numeryczne', 'metody numeryczne','onedrive.exe',
        'sql', 'kaggle', 'github', 'git', 'stack overflow', 'stackoverflow', 
        'data science', 'machine learning','sztuczna inteligencja','camscanner',
        'gemini', 'chatgpt', 'openai', 'claude', 'leon', 'usos', 'politechnika',
        'pochodna', 'całka', 'zapiski', 'laboratorium', 'projekt', 'studia','wordPal.exe',
        '.py', '.ipynb', '.m', '.cpp', '.c', 'json crack', 'gemini', 'dysk','mspaint.exe',
        'intellij', 'idea','obsidian','wikipedia', 'wiki', 'kurs', 'course', 'udemy', 'coursera', 'edx', 
        'duolingo', 'tłumacz', 'translate', 'słownik', 'dictionary', 'notion','angielski',
        'rosyjski', 'asd', 'tp', 'metody numeryczne', 'twd', 'fizyka', 'rstudio','powerpnt.exe','photos.exe',
        'excel.exe'	,'studio64.exe','acrobat.exe','notepad.exe','java.exe','cmd.exe','onedrive',
        'eclipse.exe','shellexperiencehost.exe','desmos', 'teams','wordpal.exe','notatki samsung'
    ]
    if any(k in combined for k in ds_keywords):
        return 'studia'
    
    Browsers_keywords = [
        "chrome",'firefox','brave.exe','chrome.exe','google','firefox.exe','msedge.exe','brave'
    ]
    if any(k in combined for k in Browsers_keywords):
        return 'przeglądarka'
    
    System_keywords = [
        'explorer.exe','LockApp.exe','ekran startowy one ui','ipsmonitor.exe',
        'launcher systemu','zegar','systemowy menedżer pulpitu','steelseriesggclient.exe',
        'applicationframehost.exe','swusb.exe','stayfree','winword.exe','taskmgr.exe','nvidia app.exe',
        'ustawienia','kontroler uprawnień','applicationframehost.exe','lockapp.exe','searchhost.exe'
    ]
    if any(k in combined for k in System_keywords):
        return 'system'
    
    # 7. Inne (System,  ogólna, Zakupy, Zdjęcia itp.)
    return 'inne'

def classify_activity2(combined): #Trytytka
    if(combined == "X"):
        return 'komunikatory'
    if(combined == "Instagram"):
        return 'komunikatory'
    if(combined == "studio64.exe"):
        return 'studia'
    return 'inne'

def delete_cache() -> None:
    system(r'del ".\\Dane Dash Fastboot\\*" /q')

def load_desktop_data(watcher: str, afk: str, person: str) -> None:
    with open(afk, 'r', encoding='utf-8') as f: #Scieżka
        raw_data = json.load(f)
    events_list = raw_data['buckets'][list(raw_data['buckets'].keys())[0]]['events']
    df1 = pd.json_normalize(events_list)
    with open(watcher, 'r', encoding='utf-8') as f:
        raw_data = json.load(f)
    events_list = raw_data['buckets'][list(raw_data['buckets'].keys())[0]]['events']
    df2 = pd.json_normalize(events_list)
    df_afk = df1.copy()
    df_window = df2.copy()
    df_afk['timestamp'] = pd.to_datetime(df_afk['timestamp'], format='ISO8601', utc=True)
    df_window['timestamp'] = pd.to_datetime(df_window['timestamp'], format='ISO8601', utc=True)
    df_afk['end_time'] = df_afk['timestamp'] + pd.to_timedelta(df_afk['duration'], unit='s')
    df_window['end_time'] = df_window['timestamp'] + pd.to_timedelta(df_window['duration'], unit='s')
    all_timestamps = pd.concat([
        df_window['timestamp'], 
        df_window['end_time'], 
        df_afk['timestamp'], 
        df_afk['end_time']
    ]).unique()
    df_master = pd.DataFrame({'timestamp': all_timestamps})
    df_master = df_master.sort_values('timestamp').reset_index(drop=True)
    df_window = df_window.rename(columns={'data.app': 'app', 'data.title': 'title'})
    df_afk = df_afk.rename(columns={'data.status': 'status'})
    df_master = pd.merge_asof(
        df_master, 
        df_window[['timestamp', 'end_time', 'app', 'title']].sort_values("timestamp"), 
        on='timestamp', 
        direction='backward',
        suffixes=('', '_win')
    )
    df_master = pd.merge_asof(
        df_master, 
        df_afk[['timestamp', 'end_time', 'status']].sort_values("timestamp"), 
        on='timestamp', 
        direction='backward',
        suffixes=('', '_afk')
    )
    df_master['duration'] = df_master['timestamp'].diff().shift(-1).dt.total_seconds()
    is_window_active = df_master['timestamp'] < df_master['end_time']
    is_afk_active = df_master['timestamp'] < df_master['end_time_afk']
    df_final = df_master[is_window_active].copy()
    df_final['status'] = np.where(
        df_final['timestamp'] < df_final['end_time_afk'], 
        df_final['status'], 
        'not-afk'
    )
    df_final = df_final[df_final['duration'] > 0]
    df_final['category'] = df_final['app'].apply(classify_activity2)
    df_final['category'] = np.where(df_final['category']=='inne', df_final['title'].apply(classify_activity), df_final['category'])
    df_final['category'] = np.where(df_final['category']=='inne', df_final['app'].apply(classify_activity), df_final['category'])
    df_final['osoba'] = person
    df_final['device'] = 'PC'
    time_temp = max(df_final['end_time']).strftime("%d.%m.%Y")
    df_final["timestamp"] = df_final["timestamp"].dt.strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    df_final = df_final.drop(columns=["title", "end_time", "end_time_afk"])
    df_final['status'] = np.where(df_final['app']=='LockApp.exe', 'afk', df_final['status'])
    df_final.to_json(
    f"Dane Dash\\PC-SUM-{person}-{time_temp}.json",
    orient="records",
    indent=4,
    force_ascii=False
)
if __name__ == "__main__":
    load_desktop_data(f"Dane prywatne\\{argv[1]}.json", f"Dane prywatne\\{argv[2]}.json", argv[3])
    delete_cache()