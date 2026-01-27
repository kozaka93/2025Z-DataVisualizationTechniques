import pandas as pd
from icalendar import Calendar
import os
import glob
import datetime

def parse_ics_schedule(ics_path: str) -> pd.DataFrame:
    with open(ics_path, 'rb') as f:
        cal = Calendar.from_ical(f.read())

    events = []
    for component in cal.walk():
        if component.name == "VEVENT":
            summary = str(component.get('summary'))
            start = component.get('dtstart').dt
            end = component.get('dtend').dt
            
            if not isinstance(start, datetime.datetime):
                start = datetime.datetime.combine(start, datetime.time.min)
            if not isinstance(end, datetime.datetime):
                end = datetime.datetime.combine(end, datetime.time.min)
                
            if start.tzinfo:
                start = start.replace(tzinfo=None)
            if end.tzinfo:
                end = end.replace(tzinfo=None)
                
            duration = (end - start).total_seconds() / 3600.0
            
            events.append({
                'date': start.date(),
                'start_time': start,
                'end_time': end,
                'event_name': summary,
                'duration_hours': duration
            })
            
    return pd.DataFrame(events)

def get_schedule_data(data_dir: str = "oldge/schedule") -> pd.DataFrame:
    ics_files = glob.glob(os.path.join(data_dir, "*.ics"))
    all_dfs = []
    
    for f in ics_files:
        person = os.path.basename(f).replace(".ics", "").lower()
        try:
            df = parse_ics_schedule(f)
            df['person'] = person
            all_dfs.append(df)
        except Exception as e:
            print(f"Error parsing {f}: {e}")
            
    if not all_dfs:
        return pd.DataFrame(), pd.DataFrame()
        
    full_df = pd.concat(all_dfs, ignore_index=True)
    
    daily_sched = full_df.groupby(['person', 'date']).agg(
        class_hours=('duration_hours', 'sum'),
        event_count=('event_name', 'count')
    ).reset_index()
    
    daily_sched['has_classes'] = daily_sched['class_hours'] > 0
    daily_sched['date'] = pd.to_datetime(daily_sched['date'])
    
    return daily_sched, full_df