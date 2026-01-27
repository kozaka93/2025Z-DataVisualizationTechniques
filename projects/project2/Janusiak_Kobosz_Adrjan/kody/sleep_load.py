import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import json
from sys import argv
from data_load import delete_cache

def sleep_load(file: str, user_name: str) -> None:
    df = pd.read_csv(file, parse_dates=[['Date','StartTime']], dayfirst=True)
    category = "sen"
    device = "Phone"
    status = "sleep"
    app = "Sen"
    json_list = []

    for _, row in df.iterrows():
        
        start_ts = row['Date_StartTime']
        
        end_time_str = row['EndTime']
        end_hour, end_min = map(int, end_time_str.split(":"))
        
        end_ts = start_ts.replace(hour=end_hour, minute=end_min)
        if end_ts < start_ts:
            end_ts += timedelta(days=1)
        
        duration_sec = (end_ts - start_ts).total_seconds()
        
        if start_ts.date() != end_ts.date():
            midnight = datetime.combine(start_ts.date(), datetime.min.time())
            duration_sec1 = (midnight - start_ts).total_seconds()
            json_list.append({
                "timestamp": (start_ts-timedelta(days=1, hours=1)).strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
                "app": app,
                "status": status,
                "duration": duration_sec1+86399,
                "category": category,
                "osoba": user_name,
                "device": device
            })
            duration_sec2 = (end_ts - midnight).total_seconds()
            json_list.append({
                "timestamp": (midnight-timedelta(hours=1)).strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
                "app": app,
                "status": status,
                "duration": duration_sec2-86400,
                "category": category,
                "osoba": user_name,
                "device": device
            })
        else:
            # No split needed
            duration_sec = (end_ts - start_ts).total_seconds()
            json_list.append({
                "timestamp": (start_ts-timedelta(hours=1)).strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
                "app": app,
                "status": status,
                "duration": duration_sec,
                "category": category,
                "osoba": user_name,
                "device": device
            })
            

    time_temp = df['Date_StartTime'].max().strftime("%d.%m.%Y")
    json_file = f"Dane Dash\\SLEEP-SUM-{user_name}-{time_temp}.json"
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(json_list, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    sleep_load(f"Dane prywatne\\{argv[1]}.csv", argv[2])
    delete_cache()