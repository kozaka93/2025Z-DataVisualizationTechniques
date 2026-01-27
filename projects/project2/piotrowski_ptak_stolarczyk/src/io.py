import pandas as pd
import os
import glob
from typing import Dict, List, Optional, Tuple


def read_csv_flexible(path: str) -> pd.DataFrame:
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        header = f.readline()
    sep = ';' if header.count(';') > header.count(',') else ','
    df = pd.read_csv(path, sep=sep)
    df.columns = [str(c).strip() for c in df.columns]
    df = df.loc[:, ~df.columns.str.contains('^Unnamed', na=False)]
    df = df.loc[:, df.columns != '']
    return df


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    rename_map = {c: str(c).strip().lower() for c in df.columns}
    df = df.rename(columns=rename_map)
    if 'totalscreentime' in df.columns:
        df = df.rename(columns={'totalscreentime': 'total'})
    return df

def load_all_data(data_dir: str = "data") -> Tuple[Dict[str, pd.DataFrame], Dict[str, Dict[str, list]]]:
    datasets = {}
    meta = {"files": {}, "columns": {}}
    
    steps_files = glob.glob(os.path.join(data_dir, "steps", "*.csv"))
    if steps_files:
        dfs = []
        for f in steps_files:
            if "summary" in f: continue
            df = normalize_columns(read_csv_flexible(f))
            if 'steps' in df.columns:
                name = os.path.basename(f).replace(".csv", "").replace("steps_", "")
                if 'person' not in df.columns:
                    df['person'] = name.lower()
                dfs.append(df)
        if dfs:
            datasets['steps'] = pd.concat(dfs, ignore_index=True)
            meta["files"]["steps"] = steps_files
            meta["columns"]["steps"] = list(datasets['steps'].columns)

    st_files = glob.glob(os.path.join(data_dir, "screentime", "*.csv"))
    if st_files:
        dfs = []
        for f in st_files:
            df = normalize_columns(read_csv_flexible(f))
            if 'total' in df.columns or 'total_hours' in df.columns:
                name = os.path.basename(f).replace(".csv", "").replace("ScreenTime", "")
                if 'person' not in df.columns:
                    df['person'] = name.lower()
                dfs.append(df)
            else:
                 if 'date' in df.columns:
                    name = os.path.basename(f).replace(".csv", "").replace("ScreenTime", "")
                    if 'person' not in df.columns:
                        df['person'] = name.lower()
                    dfs.append(df)

        if dfs:
            datasets['screentime'] = pd.concat(dfs, ignore_index=True)
            meta["files"]["screentime"] = st_files
            meta["columns"]["screentime"] = list(datasets['screentime'].columns)

    weather_files = glob.glob(os.path.join(data_dir, "weather", "*.csv"))
    daily_weather = [f for f in weather_files if 'daily' in f]
    if daily_weather:
        datasets['weather'] = pd.read_csv(daily_weather[0])
        meta["files"]["weather"] = daily_weather
        meta["columns"]["weather"] = list(datasets['weather'].columns)
    
    visit_files = glob.glob(os.path.join(data_dir, "locations", "*visits*.csv"))
    if visit_files:
        dfs = []
        for f in visit_files:
            df = pd.read_csv(f)
            if 'person' not in df.columns:
                pass 
            dfs.append(df)
        if dfs:
            datasets['visits'] = pd.concat(dfs, ignore_index=True)
            meta["files"]["visits"] = visit_files
            meta["columns"]["visits"] = list(datasets['visits'].columns)
            
    act_files = glob.glob(os.path.join(data_dir, "locations", "*activities*.csv"))
    if act_files:
        dfs = []
        for f in act_files:
            df = pd.read_csv(f)
            dfs.append(df)
        if dfs:
            datasets['activities'] = pd.concat(dfs, ignore_index=True)
            meta["files"]["activities"] = act_files
            meta["columns"]["activities"] = list(datasets['activities'].columns)

    return datasets, meta

def detect_person(filename: str) -> str:
    base = os.path.basename(filename).lower()
    for name in ['igor', 'tomek', 'kacper']:
        if name in base:
            return name
    return "unknown"
