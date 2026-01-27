import pandas as pd
import numpy as np
from src.io import load_all_data
from src.calendar import get_schedule_data


def parse_duration(x):
    if pd.isna(x):
        return np.nan
    if isinstance(x, (int, float, np.integer, np.floating)) and not isinstance(x, bool):
        return float(x)
    s = str(x).strip()
    if s == "":
        return np.nan
    if ":" not in s:
        try:
            return float(s)
        except ValueError:
            return np.nan
    try:
        parts = s.split(':')
        if len(parts) == 3:
            return float(parts[0]) + float(parts[1]) / 60 + float(parts[2]) / 3600
        if len(parts) == 2:
            return float(parts[0]) + float(parts[1]) / 60
        return np.nan
    except Exception:
        return np.nan


def normalize_person(df: pd.DataFrame) -> pd.DataFrame:
    if 'person' not in df.columns:
        df['person'] = 'unknown'
    df['person'] = df['person'].astype(str).str.strip().str.lower()
    return df


def build_daily_features(data_dir: str = "data") -> tuple:

    diagnostics = {
        'coverage': {},
        'anomalies': [],
        'metadata': {},
        'consistency': {}
    }

    datasets, data_meta = load_all_data(data_dir)
    diagnostics['metadata'] = data_meta

    steps_df = datasets.get('steps', pd.DataFrame())
    if not steps_df.empty:
        steps_df = normalize_person(steps_df)
        steps_df['date'] = pd.to_datetime(steps_df['date'], errors='coerce').dt.date
        steps_df['steps'] = pd.to_numeric(steps_df['steps'], errors='coerce')

        neg_steps = steps_df[steps_df['steps'] < 0]
        if not neg_steps.empty:
            diagnostics['anomalies'].append(f"Negative steps detected: {len(neg_steps)} rows")
            steps_df = steps_df[steps_df['steps'] >= 0]

        steps_df = steps_df.dropna(subset=['date'])
        steps_df = steps_df.groupby(['person', 'date'], as_index=False)['steps'].sum()
        steps_df['has_steps'] = True

        diagnostics['coverage']['steps'] = {
            'n_days': steps_df['date'].nunique(),
            'date_range': (steps_df['date'].min(), steps_df['date'].max()),
            'persons': steps_df['person'].unique().tolist()
        }
    else:
        diagnostics['coverage']['steps'] = {'n_days': 0}

    st_df = datasets.get('screentime', pd.DataFrame())
    if not st_df.empty:
        st_df = normalize_person(st_df)
        st_df['date'] = pd.to_datetime(st_df['date'], dayfirst=True, errors='coerce').dt.date
        st_df = st_df.dropna(subset=['date'])

        time_cols = [c for c in st_df.columns if c not in ['date', 'person']]
        for c in time_cols:
            key = str(c).strip().lower().replace(' ', '_')
            col_name = key if key.endswith('_hours') else f"{key}_hours"
            st_df[col_name] = st_df[c].apply(parse_duration)

        hour_cols = [c for c in st_df.columns if c.endswith('_hours')]

        if 'total_screen_hours_raw' not in st_df.columns:
            total_candidates = [c for c in hour_cols if 'total' in c]
            if total_candidates:
                total_col = max(total_candidates, key=lambda c: st_df[c].notna().sum())
                st_df = st_df.rename(columns={total_col: 'total_screen_hours_raw'})
                for c in total_candidates:
                    if c != 'total_screen_hours_raw' and c in st_df.columns:
                        st_df = st_df.drop(columns=c)

        hour_cols = [c for c in st_df.columns if c.endswith('_hours')]
        screen_cat_cols = [c for c in hour_cols if 'total' not in c]

        for c in screen_cat_cols:
            neg_vals = st_df[st_df[c] < 0]
            if not neg_vals.empty:
                diagnostics['anomalies'].append(f"Negative {c} detected: {len(neg_vals)} rows")
            st_df[c] = pd.to_numeric(st_df[c], errors='coerce').clip(lower=0)

        if 'total_screen_hours_raw' in st_df.columns:
            neg_total = st_df[st_df['total_screen_hours_raw'] < 0]
            if not neg_total.empty:
                diagnostics['anomalies'].append(f"Negative total_screen_hours_raw: {len(neg_total)} rows")
            st_df['total_screen_hours_raw'] = pd.to_numeric(
                st_df['total_screen_hours_raw'], errors='coerce'
            ).clip(lower=0)

        if screen_cat_cols:
            total_from_cats = st_df[screen_cat_cols].sum(axis=1, min_count=1)
        else:
            total_from_cats = pd.Series(np.nan, index=st_df.index)
        st_df['total_screen_hours'] = total_from_cats

        if 'total_screen_hours_raw' in st_df.columns:
            st_df['screen_time_delta_hours'] = st_df['total_screen_hours_raw'] - total_from_cats
            delta_stats = st_df['screen_time_delta_hours'].describe()
            diagnostics['consistency']['screen_time_delta'] = {
                'mean': float(delta_stats.get('mean', 0)),
                'max': float(delta_stats.get('max', 0)),
                'min': float(delta_stats.get('min', 0))
            }

            large_dev = st_df[st_df['screen_time_delta_hours'].abs() > 1.0]
            if not large_dev.empty:
                diagnostics['anomalies'].append(
                    f"Large screen time deviations (>1h): {len(large_dev)} days"
                )

            st_df.loc[st_df['total_screen_hours'].isna(), 'total_screen_hours'] = \
                st_df['total_screen_hours_raw']

        keep_cols = ['person', 'date'] + screen_cat_cols + ['total_screen_hours']
        for c in ['total_screen_hours_raw', 'screen_time_delta_hours']:
            if c in st_df.columns:
                keep_cols.append(c)

        st_df = st_df[keep_cols]
        st_df = st_df.groupby(['person', 'date'], as_index=False).sum(min_count=1)

        if 'total_screen_hours_raw' in st_df.columns:
            st_df['screen_time_delta_hours'] = \
                st_df['total_screen_hours_raw'] - st_df['total_screen_hours']

        screen_flag_cols = ['total_screen_hours']
        if 'total_screen_hours_raw' in st_df.columns:
            screen_flag_cols.append('total_screen_hours_raw')
        screen_flag_cols += screen_cat_cols
        st_df['has_screen'] = st_df[screen_flag_cols].notna().any(axis=1)

        diagnostics['coverage']['screen'] = {
            'n_days': st_df['date'].nunique(),
            'date_range': (st_df['date'].min(), st_df['date'].max()),
            'persons': st_df['person'].unique().tolist(),
            'categories': screen_cat_cols
        }
    else:
        diagnostics['coverage']['screen'] = {'n_days': 0}

    weather_df = datasets.get('weather', pd.DataFrame())
    if not weather_df.empty:
        weather_df['date'] = pd.to_datetime(weather_df['date'], errors='coerce').dt.date
        weather_df = weather_df.rename(columns={
            'temperature_2m_mean': 'temp_mean_c',
            'precipitation_sum': 'precip_mm'
        })
        weather_df['has_weather'] = True
        weather_df = weather_df.dropna(subset=['date'])

        diagnostics['coverage']['weather'] = {
            'n_days': weather_df['date'].nunique(),
            'date_range': (weather_df['date'].min(), weather_df['date'].max())
        }
    else:
        diagnostics['coverage']['weather'] = {'n_days': 0}

    act_df = datasets.get('activities', pd.DataFrame())
    visits_df = datasets.get('visits', pd.DataFrame())
    loc_metrics = pd.DataFrame()

    if not act_df.empty:
        act_df = normalize_person(act_df)
        act_df['start_time'] = pd.to_datetime(act_df['start_time'], errors='coerce')
        act_df['date'] = act_df['start_time'].dt.date
        act_df['activity_distance_meters'] = pd.to_numeric(
            act_df['activity_distance_meters'], errors='coerce'
        )
        act_df = act_df.dropna(subset=['date'])
        dist_agg = act_df.groupby(['person', 'date'], as_index=False).agg(
            distance_km=('activity_distance_meters', lambda x: x.sum() / 1000.0)
        )
        loc_metrics = dist_agg

    if not visits_df.empty:
        visits_df = normalize_person(visits_df)
        visits_df['start_time'] = pd.to_datetime(visits_df['start_time'], errors='coerce')
        visits_df['end_time'] = pd.to_datetime(visits_df['end_time'], errors='coerce')
        visits_df['date'] = visits_df['start_time'].dt.date
        visits_df['duration_min'] = (
            visits_df['end_time'] - visits_df['start_time']
        ).dt.total_seconds() / 60.0
        visits_df = visits_df.dropna(subset=['date'])

        visits_agg = visits_df.groupby(['person', 'date'], as_index=False).agg(
            unique_places=('visit_candidate_place_lat', 'nunique'),
            time_outside_home_min=('duration_min', 'sum')
        )

        if loc_metrics.empty:
            loc_metrics = visits_agg
        else:
            loc_metrics = pd.merge(loc_metrics, visits_agg, on=['person', 'date'], how='outer')

    if not loc_metrics.empty:
        loc_metrics['has_location'] = True
        diagnostics['coverage']['location'] = {
            'n_days': loc_metrics['date'].nunique(),
            'persons': loc_metrics['person'].unique().tolist()
        }
    else:
        diagnostics['coverage']['location'] = {'n_days': 0}

    schedule_daily, events_df = get_schedule_data()
    if not schedule_daily.empty:
        schedule_daily = normalize_person(schedule_daily)
        schedule_daily['date'] = pd.to_datetime(schedule_daily['date'], errors='coerce').dt.date
        schedule_daily = schedule_daily.dropna(subset=['date'])
        schedule_daily['has_classes'] = True

        diagnostics['coverage']['classes'] = {
            'n_days': schedule_daily['date'].nunique(),
            'persons': schedule_daily['person'].unique().tolist()
        }
    else:
        diagnostics['coverage']['classes'] = {'n_days': 0}

    if not events_df.empty:
        events_df = normalize_person(events_df)
        if 'date' in events_df.columns:
            events_df['date'] = pd.to_datetime(events_df['date'], errors='coerce').dt.date

    key_frames = []
    for df in [steps_df, st_df, loc_metrics, schedule_daily]:
        if df is not None and not df.empty:
            key_frames.append(df[['person', 'date']])

    if key_frames:
        master_keys = pd.concat(key_frames, ignore_index=True).drop_duplicates()
    else:
        if not weather_df.empty:
            persons = ['unknown']
            master_keys = pd.DataFrame({'date': weather_df['date'].unique()})
            master_keys['person'] = persons[0]
        else:
            master_keys = pd.DataFrame({
                'date': pd.date_range(start='2025-01-01', periods=30).date
            })
            master_keys['person'] = 'unknown'

    master = master_keys.copy()

    if not steps_df.empty:
        master = pd.merge(master, steps_df, on=['person', 'date'], how='left')
    if not st_df.empty:
        master = pd.merge(master, st_df, on=['person', 'date'], how='left')
    if not loc_metrics.empty:
        master = pd.merge(master, loc_metrics, on=['person', 'date'], how='left')
    if not schedule_daily.empty:
        master = pd.merge(master, schedule_daily, on=['person', 'date'], how='left')
    if not weather_df.empty:
        master = pd.merge(master, weather_df, on='date', how='left')

    master = normalize_person(master)

    required_cols = [
        'steps', 'total_screen_hours', 'total_screen_hours_raw', 'screen_time_delta_hours',
        'social_hours', 'entertainment_hours', 'productivity_hours', 'education_hours',
        'other_hours', 'class_hours', 'temp_mean_c', 'precip_mm',
        'distance_km', 'unique_places', 'time_outside_home_min'
    ]
    for col in required_cols:
        if col not in master.columns:
            master[col] = np.nan

    for col in required_cols:
        master[col] = pd.to_numeric(master[col], errors='coerce')

    for flag in ['has_steps', 'has_screen', 'has_weather', 'has_classes', 'has_location']:
        if flag not in master.columns:
            master[flag] = False
        master[flag] = master[flag].fillna(False).astype(bool)

    screen_cats = [c for c in master.columns if c.endswith('_hours') and
                   c not in ['total_screen_hours', 'total_screen_hours_raw',
                            'screen_time_delta_hours', 'class_hours']]

    entertainment_like = [c for c in screen_cats if 'entertainment' in c or 'game' in c]
    social_like = [c for c in screen_cats if 'social' in c or 'communication' in c]
    digital_load_cols = list(set(entertainment_like + social_like))

    if digital_load_cols:
        master['digital_load'] = master[digital_load_cols].sum(axis=1, min_count=1)
    else:
        master['digital_load'] = np.nan

    master.loc[~master['has_screen'], 'digital_load'] = np.nan

    master['screen_share_social'] = np.nan
    if 'social_hours' in master.columns:
        screen_mask = master['total_screen_hours'].notna() & (master['total_screen_hours'] > 0)
        master.loc[screen_mask, 'screen_share_social'] = \
            master.loc[screen_mask, 'social_hours'] / master.loc[screen_mask, 'total_screen_hours']

    master['rain_flag'] = master['has_weather'] & (master['precip_mm'] > 0)

    master['active_day_flag'] = master['has_steps'] & (master['steps'] > 8000)

    master['coverage_score'] = (
        master['has_steps'].astype(int) +
        master['has_screen'].astype(int) +
        master['has_weather'].astype(int) +
        master['has_classes'].astype(int) +
        master['has_location'].astype(int)
    )

    master['date_dt'] = pd.to_datetime(master['date'], errors='coerce')
    master['day_of_week'] = master['date_dt'].dt.day_name()
    master['weekend_flag'] = master['date_dt'].dt.dayofweek >= 5

    def calc_balance(row):
        if not row['has_steps'] and not row['has_screen']:
            return np.nan

        score = 50.0

        steps = row['steps'] if pd.notna(row['steps']) else 0
        score += min(40, (steps / 10000) * 40)

        if pd.notna(row.get('distance_km')):
            score += min(10, (row['distance_km'] / 5) * 10)

        if pd.notna(row.get('digital_load')) and row['digital_load'] > 2:
            penalty = (row['digital_load'] - 2) * 5
            score -= min(30, penalty)

        if row.get('rain_flag', False) and steps > 6000:
            score += 5

        return float(max(0, min(100, score)))

    master['balance_index'] = master.apply(calc_balance, axis=1)

    zero_steps_with_screen = master[
        (master['steps'] == 0) & master['has_screen'] &
        (master['total_screen_hours'] > 0)
    ]
    if not zero_steps_with_screen.empty:
        diagnostics['anomalies'].append(
            f"Days with 0 steps but screen time: {len(zero_steps_with_screen)}"
        )

    if not visits_df.empty and 'date' in visits_df.columns:
        visits_df['date'] = pd.to_datetime(visits_df['date'], errors='coerce').dt.date

    duplicates = master[master.duplicated(subset=['person', 'date'], keep=False)]
    if not duplicates.empty:
        diagnostics['anomalies'].append(
            f"Duplicate person+date rows detected: {len(duplicates)} (will aggregate)"
        )
        master = master.groupby(['person', 'date'], as_index=False).first()

    diagnostics['missing_data'] = {}
    for col in required_cols:
        if col in master.columns:
            pct_missing = (master[col].isna().sum() / len(master)) * 100
            diagnostics['missing_data'][col] = f"{pct_missing:.1f}%"

    n_complete = len(master[master['coverage_score'] >= 2])
    if n_complete < 8:
        diagnostics['anomalies'].append(
            f"Warning: Only {n_complete} days with coverage>=2, correlations may be unstable"
        )

    return master, events_df, visits_df, diagnostics


def process_data(data_dir: str = "data"):
    master, events_df, visits_df, diagnostics = build_daily_features(data_dir)
    return master, events_df, visits_df, diagnostics.get('metadata', {})
