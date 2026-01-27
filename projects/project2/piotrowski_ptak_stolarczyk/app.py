import datetime
import os
import glob
import pandas as pd
import streamlit as st

from src.etl import build_daily_features
from src import viz_overview, viz_drivers, viz_day, insights

st.set_page_config(
    page_title="Project JA - Personal Dashboard",
    page_icon="🧬",
    layout="wide",
    initial_sidebar_state="expanded"
)

if 'selected_day' not in st.session_state:
    st.session_state.selected_day = None
if 'current_week_start' not in st.session_state:
    st.session_state.current_week_start = None
if 'date_range' not in st.session_state:
    st.session_state.date_range = None
if 'range_mode' not in st.session_state:
    st.session_state.range_mode = "Custom Range"
if 'last_timeline_click' not in st.session_state:
    st.session_state.last_timeline_click = None
if 'last_calendar_click' not in st.session_state:
    st.session_state.last_calendar_click = None
if 'prev_person' not in st.session_state:
    st.session_state.prev_person = None

st.markdown(
    """
<style>
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap');

html, body, [class*="css"] {
    font-family: 'Space Grotesk', 'Segoe UI', sans-serif;
}

.block-container {padding-top: 3rem; padding-bottom: 2rem;}

.kpi-card {
    background: linear-gradient(145deg, #111827 0%, #1f2937 100%);
    border: 1px solid rgba(148, 163, 184, 0.2);
    border-radius: 12px;
    padding: 14px 16px;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.15);
}

.kpi-label {
    color: #cbd5f5;
    font-size: 0.85rem;
    letter-spacing: 0.02em;
    text-transform: uppercase;
    margin-bottom: 6px;
}

.kpi-value {
    color: #f8fafc;
    font-size: 1.6rem;
    font-weight: 600;
}

.kpi-subtext {
    color: #94a3b8;
    font-size: 0.85rem;
    margin-top: 4px;
}
</style>
""",
    unsafe_allow_html=True
)


def render_kpi(container, label, value, subtext=None):
    if value is None or (isinstance(value, float) and pd.isna(value)):
        value = "—"
        if subtext is None:
            subtext = "No data"
    html = f"""
    <div class="kpi-card">
        <div class="kpi-label">{label}</div>
        <div class="kpi-value">{value}</div>
        {f'<div class="kpi-subtext">{subtext}</div>' if subtext else ''}
    </div>
    """
    container.markdown(html, unsafe_allow_html=True)


def render_weekly_summary(df, start_date, end_date):
    if df.empty:
        return
    
    if 'balance_index' in df.columns and df['balance_index'].notna().any():
        best_idx = df['balance_index'].idxmax()
        worst_idx = df['balance_index'].idxmin()
        best_day = df.loc[best_idx]
        worst_day = df.loc[worst_idx]
        best_str = f"{pd.to_datetime(best_day['date']).strftime('%b %d')} (Balance {best_day['balance_index']:.0f})"
        worst_str = f"{pd.to_datetime(worst_day['date']).strftime('%b %d')} (Balance {worst_day['balance_index']:.0f})"
    else:
        best_str = "—"
        worst_str = "—"
    
    total_steps = int(df['steps'].sum()) if 'steps' in df.columns else 0
    avg_screen = df['total_screen_hours'].mean() if 'total_screen_hours' in df.columns else 0
    rainy_days = int(df['rain_flag'].sum()) if 'rain_flag' in df.columns else 0
    class_days = int(df['has_classes'].sum()) if 'has_classes' in df.columns else 0
    total_days = len(df)
    period = f"{start_date.strftime('%b %d')} - {end_date.strftime('%b %d, %Y')}"
    
    html = f"""
    <div style="
        background: linear-gradient(145deg, #111827 0%, #1f2937 100%);
        border: 1px solid rgba(148, 163, 184, 0.2);
        border-radius: 12px;
        padding: 18px 20px;
        margin: 16px 0;
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.15);">
        <div style="color: #cbd5f5; font-size: 0.95rem; font-weight: 600; margin-bottom: 12px; letter-spacing: 0.02em;">Aggregated Summary: {period}</div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px 16px;">
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Best day:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{best_str}</span></div>
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Worst day:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{worst_str}</span></div>
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Total steps:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{total_steps:,}</span></div>
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Avg screen:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{avg_screen:.1f}h/day</span></div>
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Rainy days:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{rainy_days}/{total_days}</span></div>
            <div style="min-width: 0;"><span style="color: #94a3b8; font-size: 0.85rem;">Class days:</span> <span style="color: #f8fafc; font-weight: 500; display: block; margin-top: 2px;">{class_days}/{total_days}</span></div>
        </div>
    </div>
    """
    st.markdown(html, unsafe_allow_html=True)


def render_goals_tracking(df):
    if df.empty:
        return
    
    avg_steps = df['steps'].mean() if 'steps' in df.columns and df['steps'].notna().any() else 0
    avg_screen = df['total_screen_hours'].mean() if 'total_screen_hours' in df.columns and df['total_screen_hours'].notna().any() else 0
    avg_digital = df['digital_load'].mean() if 'digital_load' in df.columns and df['digital_load'].notna().any() else 0
    
    def goal_status(actual, target, lower_is_better=False):
        if lower_is_better:
            status = "on track" if actual <= target else "over limit"
            diff = actual - target
        else:
            status = "achieved" if actual >= target else "below target"
            diff = actual - target
        return status, diff
    
    steps_status, steps_diff = goal_status(avg_steps, 10000)
    screen_status, screen_diff = goal_status(avg_screen, 4.0, True)
    digital_status, digital_diff = goal_status(avg_digital, 2.0, True)
    
    html = f"""
    <div style="
        background: linear-gradient(145deg, #111827 0%, #1f2937 100%);
        border: 1px solid rgba(148, 163, 184, 0.2);
        border-radius: 12px;
        padding: 18px 20px;
        margin: 16px 0;
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.15);">
        <div style="color: #cbd5f5; font-size: 0.95rem; font-weight: 600; margin-bottom: 12px; letter-spacing: 0.02em;">Goals vs Actual</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px;">
            <div style="border-left: 3px solid #0EA5E9; padding-left: 10px;">
                <div style="color: #94a3b8; font-size: 0.8rem; margin-bottom: 4px;">Daily Steps Goal: 10,000</div>
                <div style="color: #f8fafc; font-size: 1.1rem; font-weight: 600;">{avg_steps:,.0f} <span style="font-size: 0.85rem; color: #94a3b8;">({steps_status})</span></div>
            </div>
            <div style="border-left: 3px solid #F97316; padding-left: 10px;">
                <div style="color: #94a3b8; font-size: 0.8rem; margin-bottom: 4px;">Screen Time Limit: <4h/day</div>
                <div style="color: #f8fafc; font-size: 1.1rem; font-weight: 600;">{avg_screen:.1f}h <span style="font-size: 0.85rem; color: #94a3b8;">({screen_status})</span></div>
            </div>
            <div style="border-left: 3px solid #A855F7; padding-left: 10px;">
                <div style="color: #94a3b8; font-size: 0.8rem; margin-bottom: 4px;">Digital Load Limit: <2h/day</div>
                <div style="color: #f8fafc; font-size: 1.1rem; font-weight: 600;">{avg_digital:.1f}h <span style="font-size: 0.85rem; color: #94a3b8;">({digital_status})</span></div>
            </div>
        </div>
    </div>
    """
    st.markdown(html, unsafe_allow_html=True)


def kpi_avg(df, value_col, flag_col):
    if flag_col in df.columns and df[flag_col].dtype == bool:
        subset = df[df[flag_col]]
    else:
        subset = df[df[value_col].notna()]
    n = subset[value_col].dropna().shape[0]
    if n == 0:
        return None, 0
    return subset[value_col].mean(), n


def set_selected_day(date_val):
    st.session_state.selected_day = date_val


def jump_to_range(start_d, end_d):
    st.session_state.date_range = (start_d, end_d)
    st.session_state.current_week_start = start_d
    st.rerun()


def nearest_valid_day(days, target):
    if not days:
        return None
    days_sorted = sorted(days)
    if target in days_sorted:
        return target
    earlier = [d for d in days_sorted if d <= target]
    if earlier:
        return earlier[-1]
    return days_sorted[0]


def show_empty_state(message, key, start_d, end_d):
    st.warning(message)
    if st.button("Jump to nearest data", key=key):
        jump_to_range(start_d, end_d)


def get_metric_options(df, candidates, min_count=1):
    options = []
    for c in candidates:
        if c in df.columns and df[c].notna().sum() >= min_count:
            options.append(c)
    return options


def rank_metrics(df, options):
    if not options:
        return []
    counts = {c: df[c].notna().sum() for c in options}
    return sorted(options, key=lambda c: counts.get(c, 0), reverse=True)


@st.cache_data(show_spinner=False)
def split_by_person(df: pd.DataFrame) -> dict:
    if df is None or df.empty or 'person' not in df.columns:
        return {}
    person_map = {}
    for person, group in df.groupby('person'):
        if 'date' in group.columns:
            person_map[person] = group.sort_values('date').reset_index(drop=True)
        else:
            person_map[person] = group.reset_index(drop=True)
    return person_map


@st.cache_data(show_spinner=False)
def build_views(
    person: str,
    start_d: datetime.date,
    end_d: datetime.date,
    active_threshold: int,
    view_mode: str,
    require_weather: bool,
    person_df: pd.DataFrame
) -> tuple[pd.DataFrame, pd.DataFrame]:
    if person_df is None or person_df.empty:
        return pd.DataFrame(), pd.DataFrame()

    mask = (person_df['date'] >= start_d) & (person_df['date'] <= end_d)
    filtered = person_df.loc[mask].copy()
    if filtered.empty:
        return filtered, filtered

    if person == 'combined' and 'person' in filtered.columns:
        agg_dict = {
            'steps': 'sum',
            'total_screen_hours': 'sum',
            'digital_load': 'sum',
            'class_hours': 'sum',
            'distance_km': 'sum',
            'time_outside_home_min': 'sum',
            'unique_places': 'sum',
            'coverage_score': 'sum',
            'has_steps': 'max',
            'has_screen': 'max',
            'has_weather': 'max',
            'has_classes': 'max',
            'has_location': 'max',
            'temp_mean_c': 'mean',
            'precip_mm': 'mean',
            'rain_flag': 'max',
            'weekend_flag': 'first',
            'weekday_name': 'first',
        }
        
        screen_cats = ['social_hours', 'entertainment_hours', 'productivity_hours', 
                      'reading_hours', 'creativity_hours', 'other_hours']
        for cat in screen_cats:
            if cat in filtered.columns:
                agg_dict[cat] = 'sum'
        
        agg_dict_clean = {k: v for k, v in agg_dict.items() if k in filtered.columns}
        
        filtered = filtered.groupby('date', as_index=False).agg(agg_dict_clean)
        
        if 'steps' in filtered.columns and 'total_screen_hours' in filtered.columns:
            filtered['balance_index'] = (
                (filtered['steps'] / 200.0) - (filtered['total_screen_hours'] * 5.0)
            ).clip(0, 100)
        
        if 'total_screen_hours' in filtered.columns:
            filtered['digital_load'] = filtered['total_screen_hours'] * 10.0

    filtered['active_day_flag'] = filtered['has_steps'] & (filtered['steps'] > active_threshold)

    if view_mode == "Intersection (complete days)":
        intersection_mask = filtered['has_steps'] & filtered['has_screen']
        if require_weather and filtered['has_weather'].any():
            intersection_mask = intersection_mask & filtered['has_weather']
        df_plot = filtered.loc[intersection_mask].copy()
        if df_plot.empty:
            df_plot = filtered.copy()
    else:
        df_plot = filtered.copy()

    return filtered, df_plot


@st.cache_data(show_spinner="Loading data...")
def load_data():
    return build_daily_features()


try:
    master_df, events_df, visits_df, diagnostics = load_data()
    data_meta = diagnostics.get('metadata', {})
except Exception as e:
    st.error(f"Error loading data: {e}")
    st.stop()

if master_df.empty:
    st.warning("No data found. Please check data/ folder.")
    st.stop()

PERSON_MAP = split_by_person(master_df)
EVENTS_MAP = split_by_person(events_df) if not events_df.empty else {}
VISITS_MAP = split_by_person(visits_df) if not visits_df.empty else {}

PERSON_MAP['combined'] = master_df.copy()
if not events_df.empty:
    EVENTS_MAP['combined'] = events_df.copy()
if not visits_df.empty:
    VISITS_MAP['combined'] = visits_df.copy()

st.sidebar.title("🧬 Project JA")

st.sidebar.subheader("Person")
persons = sorted([p for p in PERSON_MAP.keys() if p != 'combined']) + ['combined']
person_display = {p: p.capitalize() if p != 'combined' else 'Combined (All)' for p in persons}

selected_person = st.sidebar.selectbox(
    "Select Person", 
    persons,
    format_func=lambda x: person_display[x],
    index=0
)

if st.session_state.prev_person != selected_person:
    st.session_state.prev_person = selected_person
    st.session_state.selected_day = None
    st.session_state.last_timeline_click = None
    st.session_state.last_calendar_click = None
    st.session_state.active_tab = "📅 Daily Story"

person_df = PERSON_MAP.get(selected_person, pd.DataFrame()).copy()
if person_df.empty:
    st.warning("No data for selected person.")
    st.write("Available persons:", [person_display[p] for p in persons])
    st.stop()

st.sidebar.subheader("Time Control")
min_date = person_df['date'].min()
max_date = person_df['date'].max()

if st.sidebar.button("Reset filters"):
    st.session_state.range_mode = "Custom Range"
    st.session_state.date_range = None
    st.session_state.current_week_start = None
    st.session_state.selected_day = None
    st.session_state.last_timeline_click = None
    st.session_state.last_calendar_click = None
    st.rerun()

if st.sidebar.button("Jump to data range"):
    jump_to_range(min_date, max_date)

if st.session_state.date_range:
    start_tmp, end_tmp = st.session_state.date_range
    if start_tmp < min_date or end_tmp > max_date:
        st.session_state.date_range = (min_date, max_date)

mode = st.sidebar.radio("Range Mode", ["Custom Range", "Weekly Playback"], key="range_mode")

preferred_start = datetime.date(2025, 12, 1)
if mode == "Custom Range":
    default_start = preferred_start if min_date <= preferred_start <= max_date else min_date
    default_end = max_date
    if st.session_state.date_range:
        default_start, default_end = st.session_state.date_range

    dates = st.sidebar.date_input(
        "Date Range",
        value=(default_start, default_end),
        min_value=min_date,
        max_value=max_date
    )
    if len(dates) == 2:
        start_d, end_d = dates
    else:
        start_d, end_d = min_date, max_date
    if start_d > end_d:
        start_d, end_d = end_d, start_d
    st.session_state.date_range = (start_d, end_d)
else:
    if st.session_state.current_week_start is None:
        st.session_state.current_week_start = preferred_start if min_date <= preferred_start <= max_date else min_date

    col_prev, col_next = st.sidebar.columns(2)
    if col_prev.button("⬅️ Prev Week"):
        st.session_state.current_week_start -= datetime.timedelta(days=7)
    if col_next.button("Next Week ➡️"):
        st.session_state.current_week_start += datetime.timedelta(days=7)

    if st.session_state.current_week_start < min_date:
        st.session_state.current_week_start = min_date
    if st.session_state.current_week_start > max_date:
        st.session_state.current_week_start = max_date

    start_d = st.session_state.current_week_start
    end_d = min(start_d + datetime.timedelta(days=6), max_date)
    st.session_state.date_range = (start_d, end_d)
    st.sidebar.caption(f"Showing: {start_d} to {end_d}")

st.sidebar.subheader("View Mode")
view_mode = st.sidebar.radio("Data Coverage", ["Union (show all)", "Intersection (complete days)"])
require_weather = False
if view_mode == "Intersection (complete days)" and person_df['has_weather'].any():
    require_weather = st.sidebar.checkbox("Require weather in intersection", value=False)

st.sidebar.subheader("Context Layers")
show_weather = st.sidebar.checkbox("Show weather overlay", value=True)
show_classes = st.sidebar.checkbox("Show class overlay", value=True)

with st.sidebar.expander("Advanced", expanded=False):
    active_threshold = st.slider("Active day threshold (steps)", 0, 20000, 8000)
    min_coverage = st.slider("Min coverage for drill-down", 1, 5, 2)

filtered_df, df_plot = build_views(
    selected_person,
    start_d,
    end_d,
    active_threshold,
    view_mode,
    require_weather,
    person_df
)

if filtered_df.empty:
    st.warning("No data for selected filters.")
    st.write("Available persons:", [person_display[p] for p in persons])
    st.write("Available date range for this person:", min_date, "to", max_date)
    st.stop()

if view_mode == "Intersection (complete days)" and df_plot.equals(filtered_df):
    st.info("No complete days in this range; falling back to union view.")

with st.sidebar.expander("📊 Data Diagnostics", expanded=False):
    st.caption(f"**Filtered Range**: {start_d} to {end_d}")
    st.caption(f"**Total Days**: {filtered_df['date'].nunique()}")

    total_days = filtered_df['date'].nunique()
    def pct(val):
        return f"{(val / total_days * 100):.0f}%" if total_days else "0%"

    coverage_rows = []
    for source, flag in [("Steps", "has_steps"), ("Screen", "has_screen"),
                         ("Weather", "has_weather"), ("Classes", "has_classes"),
                         ("Location", "has_location")]:
        n_days = int(filtered_df[flag].sum())
        coverage_rows.append({"Source": source, "Days": n_days, "Coverage": pct(n_days)})

    st.dataframe(pd.DataFrame(coverage_rows), use_container_width=True, hide_index=True)

    if diagnostics.get('anomalies'):
        st.caption("**Anomalies Detected:**")
        for anomaly in diagnostics['anomalies'][:5]:
            st.caption(f"⚠️ {anomaly}")

tab1, tab2, tab3 = st.tabs(["Daily Story", "Drivers & Comparisons", "Day Drill-down"])

with tab1:
    display_name = person_display[selected_person]
    st.header(f"Daily Story: {display_name}")

    k1, k2, k3, k4 = st.columns(4)
    avg_steps, n_steps = kpi_avg(filtered_df, 'steps', 'has_steps')
    avg_screen, n_screen = kpi_avg(filtered_df, 'total_screen_hours', 'has_screen')
    avg_balance = filtered_df['balance_index'].mean(skipna=True)
    n_balance = int(filtered_df['balance_index'].notna().sum())

    render_kpi(k1, "Avg Steps", f"{avg_steps:,.0f}" if avg_steps is not None else None, f"N={n_steps} days")
    render_kpi(k2, "Avg Screen Time", f"{avg_screen:.1f}h" if avg_screen is not None else None, f"N={n_screen} days")
    render_kpi(k3, "Avg Balance", f"{avg_balance:.1f}/100" if pd.notna(avg_balance) else None, f"N={n_balance} days")

    class_pct = (filtered_df['has_classes'].sum() / len(filtered_df)) * 100 if len(filtered_df) else None
    class_subtext = f"N={int(filtered_df['has_classes'].sum())} days" if class_pct is not None else None
    render_kpi(k4, "Class Load", f"{class_pct:.0f}%" if class_pct is not None else None, class_subtext)

    st.markdown("---")

    st.subheader("Master Timeline")
    st.caption("Bars: screen time by category. Line: steps. Dots: balance. Shading: classes. Blue: precipitation. Click a day to drill down.")

    if not (filtered_df['has_steps'].any() or filtered_df['has_screen'].any()):
        show_empty_state("No steps or screen data in this range.", "timeline_empty", min_date, max_date)
    else:
        missing_days = filtered_df.loc[~(filtered_df['has_steps'] & filtered_df['has_screen']), 'date'].tolist() if view_mode == "Union (show all)" else []
        fig_timeline = viz_overview.plot_master_timeline(
            filtered_df if view_mode == "Union (show all)" else df_plot,
            selected_person,
            show_weather=show_weather,
            show_classes=show_classes,
            missing_days=missing_days
        )
        st.plotly_chart(fig_timeline, use_container_width=True)

    st.markdown("---")
    
    render_weekly_summary(filtered_df, start_d, end_d)
    
    render_goals_tracking(filtered_df)
    
    st.markdown("---")

    st.subheader("Data Coverage Strip")
    st.caption("Each row is a data source (steps, screen, weather, classes, location), each column is a day. Colored cell = data available for that day/source.")
    st.plotly_chart(viz_overview.plot_coverage_strip(filtered_df), use_container_width=True)

    c1, c2 = st.columns(2)

    with c1:
        st.subheader("Weekday Pattern")
        screen_metric = st.selectbox(
            "Screen Metric",
            ["total_screen_hours", "digital_load"],
            format_func=lambda x: "Total Screen Time" if x == "total_screen_hours" else "Digital Load",
            key="weekday_screen_metric"
        )
        st.caption("Average steps vs screen load by weekday.")
        weekday_df = df_plot[df_plot['steps'].notna() & df_plot[screen_metric].notna()]
        if weekday_df.empty:
            show_empty_state("No data for weekday pattern.", "weekday_empty", min_date, max_date)
        else:
            fig_habit = viz_overview.plot_weekday_pattern(weekday_df, screen_metric)
            st.plotly_chart(fig_habit, use_container_width=True)

    with c2:
        st.subheader("Weather Split")
        weather_metric_map = {
            'total_screen_hours': 'steps',
            'digital_load': 'digital_load'
        }
        weather_metric = st.selectbox(
            "Compare metric",
            ["steps", "digital_load", "total_screen_hours"],
            format_func=lambda x: {"steps": "Steps", "digital_load": "Digital Load", "total_screen_hours": "Screen Time"}[x],
            index=0,
            key="weather_metric"
        )
        st.caption("Distribution split by rain vs no rain.")
        weather_df = df_plot[df_plot['has_weather'] & df_plot[weather_metric].notna()]
        counts = weather_df.groupby('rain_flag').size() if not weather_df.empty else pd.Series()
        if weather_df.empty or counts.empty or counts.min() < 5:
            show_empty_state("Too few samples for weather split.", "weather_empty", min_date, max_date)
        else:
            fig_weather = viz_overview.plot_weather_split(weather_df, metric=weather_metric)
            st.plotly_chart(fig_weather, use_container_width=True)

    st.subheader("Screen Composition Shift")
    st.caption("Share of screen categories over time or by weekday. Toggle between % and hours.")
    comp_col1, comp_col2 = st.columns(2)
    with comp_col1:
        comp_mode = st.radio(
            "Mode",
            ["percent", "hours"],
            horizontal=True,
            key="comp_mode",
            format_func=lambda v: "Percent" if v == "percent" else "Hours"
        )
    with comp_col2:
        comp_group = st.radio(
            "Group by",
            ["date", "weekday"],
            horizontal=True,
            key="comp_group",
            format_func=lambda v: "Date" if v == "date" else "Weekday"
        )
    screen_df = df_plot[df_plot['has_screen']]
    if screen_df.empty:
        show_empty_state("No screen data for composition shift.", "comp_empty", min_date, max_date)
    else:
        fig_comp = viz_overview.plot_screen_composition_shift(screen_df, group_by=comp_group, mode=comp_mode)
        st.plotly_chart(fig_comp, use_container_width=True)

with tab2:
    st.header("Drivers & Comparisons")

    drivers_df = df_plot.copy()

    st.subheader("Auto Insights")
    st.caption("Auto-generated statements based on mean differences and correlations.")
    with st.container(border=True):
        insight_list = insights.generate_insights(drivers_df)
        for i in insight_list:
            st.markdown(f"- {i}")

    st.subheader("Drivers Scatter")
    st.caption("Pick any two metrics and color by context segment. Trendline only if N >= 3.")
    metric_candidates = [
        'steps', 'total_screen_hours', 'digital_load', 'balance_index',
        'class_hours', 'temp_mean_c', 'precip_mm', 'social_hours',
        'distance_km', 'time_outside_home_min', 'unique_places'
    ]
    metric_options = get_metric_options(drivers_df, metric_candidates, min_count=1)
    if len(metric_options) < 2:
        drivers_df = filtered_df.copy()
        metric_options = get_metric_options(drivers_df, metric_candidates, min_count=1)
        if len(metric_options) >= 2:
            st.info("Not enough overlap in intersection view; using union data for drivers.")

    if len(metric_options) < 2:
        show_empty_state("Not enough metrics to render scatter plot.", "scatter_empty", min_date, max_date)
    else:
        col_x, col_y, col_c = st.columns(3)
        ordered_metrics = rank_metrics(drivers_df, metric_options)
        x_default = ordered_metrics[0]
        y_default = ordered_metrics[1] if len(ordered_metrics) > 1 else ordered_metrics[0]
        label_fn = lambda v: viz_drivers.METRIC_LABELS.get(v, v.replace('_', ' ').title())
        x_axis = col_x.selectbox("X Axis", metric_options, index=metric_options.index(x_default), format_func=label_fn)
        y_axis = col_y.selectbox("Y Axis", metric_options, index=metric_options.index(y_default), format_func=label_fn)
        color_choice = col_c.selectbox("Color Segment", ["Classes", "Rain", "Weekend"])
        color_map = {
            "Classes": "has_classes",
            "Rain": "rain_flag",
            "Weekend": "weekend_flag"
        }
        scatter_df = drivers_df[[x_axis, y_axis, color_map[color_choice], 'date']].dropna()
        dropped = len(drivers_df) - len(scatter_df)
        st.caption(f"N points used: {len(scatter_df)} | Dropped: {dropped}")
        if scatter_df.empty:
            show_empty_state("No data after removing NaNs.", "scatter_low_n", min_date, max_date)
        else:
            show_trend = len(scatter_df) >= 3
            if not show_trend:
                st.warning("Too few points for trendline; showing scatter only.")
            fig_scatter = viz_drivers.plot_scatter_dynamic(
                scatter_df, x_axis, y_axis, color_map[color_choice], show_trendline=show_trend
            )
            st.plotly_chart(fig_scatter, use_container_width=True)

    st.subheader("Group Comparison")
    st.caption("Compare distributions by segment; switch metric and grouping.")
    comp_col1, comp_col2, comp_col3 = st.columns(3)
    comp_metric_options = get_metric_options(
        drivers_df, ['steps', 'digital_load', 'total_screen_hours', 'balance_index'], min_count=1
    )
    if not comp_metric_options:
        show_empty_state("No metrics available for group comparison.", "group_empty", min_date, max_date)
        metric_choice = None
    else:
        ordered_comp = rank_metrics(drivers_df, comp_metric_options)
        label_fn = lambda v: viz_drivers.METRIC_LABELS.get(v, v.replace('_', ' ').title())
        metric_choice = comp_col1.selectbox(
            "Metric",
            comp_metric_options,
            index=comp_metric_options.index(ordered_comp[0]),
            format_func=label_fn
        )

    group_choice = comp_col2.selectbox(
        "Group",
        ["Classes vs No Classes", "Rain vs No Rain"],
        index=0
    )
    chart_choice = comp_col3.selectbox("Chart", ["violin", "box"], index=0, format_func=lambda v: v.title())
    group_col = 'has_classes' if group_choice.startswith("Classes") else 'rain_flag'

    if metric_choice:
        comp_df = drivers_df[[metric_choice, group_col]].dropna()
        group_counts = comp_df.groupby(group_col).size() if not comp_df.empty else pd.Series()

        if comp_df.empty or group_counts.empty or group_counts.min() < 5:
            st.info("Too few samples; showing mean ± SE instead of distribution.")
            fig_group = viz_drivers.plot_group_comparison_summary(drivers_df, metric_choice, group_col)
            st.plotly_chart(fig_group, use_container_width=True)
        else:
            fig_group = viz_drivers.plot_group_comparison_metric(
                drivers_df, metric_choice, group_col, chart_type=chart_choice
            )
            st.plotly_chart(fig_group, use_container_width=True)

    st.subheader("Correlation Heatmap")
    st.caption("Pairwise correlations with sample size thresholds.")
    corr_candidates = get_metric_options(
        drivers_df,
        ['steps', 'total_screen_hours', 'digital_load', 'balance_index',
         'class_hours', 'temp_mean_c', 'precip_mm', 'distance_km'],
        min_count=3
    )
    corr_defaults = corr_candidates[:6]
    label_fn = lambda v: viz_drivers.METRIC_LABELS.get(v, v.replace('_', ' ').title())
    corr_cols = st.multiselect("Metrics", corr_candidates, default=corr_defaults, format_func=label_fn)
    if len(corr_cols) < 2:
        show_empty_state("Select at least two metrics for correlation.", "corr_empty", min_date, max_date)
    else:
        fig_corr = viz_drivers.plot_correlation_heatmap(drivers_df, corr_cols, min_n=8)
        st.plotly_chart(fig_corr, use_container_width=True)

with tab3:
    st.header("Day Drill-down")
    st.caption("Click a day in the timeline or calendar to update this view.")

    st.subheader("Calendar Heatmap")
    st.caption("Click a day to drill down.")
    cal_metric_options = get_metric_options(
        filtered_df,
        ["steps", "total_screen_hours", "digital_load", "class_hours", "precip_mm", "balance_index"],
        min_count=1
    )
    if not cal_metric_options:
        cal_metric = 'steps'
    else:
        label_fn = lambda v: viz_drivers.METRIC_LABELS.get(v, v.replace('_', ' ').title())
        cal_metric = st.selectbox("Calendar Metric", cal_metric_options, index=0, format_func=label_fn)

    fig_cal = viz_day.plot_calendar_heatmap(filtered_df, metric=cal_metric)
    st.plotly_chart(fig_cal, width='stretch')
    st.caption('Once you have selected a day from below, the <span style="color:#EF4444;font-weight:600;">red border</span> will indicate the <b>selected day</b> in the calendar above.', unsafe_allow_html=True)

    flag_cols = [c for c in ['has_steps', 'has_screen', 'has_classes', 'has_location', 'has_weather'] if c in filtered_df.columns]
    value_cols = [c for c in ['steps', 'total_screen_hours', 'digital_load', 'class_hours', 'distance_km', 'unique_places'] if c in filtered_df.columns]

    has_data_mask = pd.Series(False, index=filtered_df.index)
    if flag_cols:
        has_data_mask |= filtered_df[flag_cols].any(axis=1)
    if value_cols:
        has_data_mask |= filtered_df[value_cols].notna().any(axis=1)

    base_days_df = filtered_df[has_data_mask] if has_data_mask.any() else filtered_df

    coverage_days = []
    if 'coverage_score' in base_days_df.columns:
        coverage_days = base_days_df.loc[base_days_df['coverage_score'] >= min_coverage, 'date'].unique().tolist()

    data_days = base_days_df['date'].unique().tolist()

    event_days = []
    if selected_person in EVENTS_MAP and not EVENTS_MAP[selected_person].empty and 'date' in EVENTS_MAP[selected_person].columns:
        events_person = EVENTS_MAP[selected_person].copy()
        events_person['date_norm'] = pd.to_datetime(events_person['date'], errors='coerce').dt.date
        mask_events_range = (events_person['date_norm'] >= start_d) & (events_person['date_norm'] <= end_d)
        event_days = events_person.loc[mask_events_range, 'date_norm'].dropna().unique().tolist()

    selectable_set = set(coverage_days) if coverage_days else set(data_days)
    selectable_set.update(event_days)

    selectable_days = sorted(selectable_set) if selectable_set else sorted(filtered_df['date'].unique().tolist())

    if not selectable_days:
        st.warning("No days available in this range. Please adjust filters.")
        st.stop()

    if st.session_state.selected_day is None or st.session_state.selected_day not in selectable_days:
        st.session_state.selected_day = selectable_days[0]

    selected_date = st.selectbox(
        "Select Day",
        selectable_days,
        index=selectable_days.index(st.session_state.selected_day),
        format_func=lambda d: d.strftime("%Y-%m-%d")
    )
    if selected_date != st.session_state.selected_day:
        set_selected_day(selected_date)
        st.rerun()

    day_row = filtered_df[filtered_df['date'] == selected_date]

    if day_row.empty:
        st.warning(f"No data for {selected_date}. Selecting nearest valid day...")
        valid_days = filtered_df[filtered_df['coverage_score'] >= min_coverage]['date'].tolist()
        if valid_days:
            selected_date = nearest_valid_day(valid_days, selected_date)
            set_selected_day(selected_date)
            day_row = filtered_df[filtered_df['date'] == selected_date]
            st.info(f"Showing data for {selected_date} instead.")
        else:
            st.stop()

    day_row = day_row.iloc[0]

    st.subheader(f"Deep Dive: {selected_date}")

    dk1, dk2, dk3, dk4 = st.columns(4)
    render_kpi(dk1, "Steps", f"{day_row['steps']:,.0f}" if pd.notna(day_row['steps']) else None)
    render_kpi(dk2, "Screen Time", f"{day_row['total_screen_hours']:.1f}h" if pd.notna(day_row['total_screen_hours']) else None)
    render_kpi(dk3, "Balance", f"{day_row['balance_index']:.1f}/100" if pd.notna(day_row['balance_index']) else None)
    render_kpi(dk4, "Coverage", f"{int(day_row['coverage_score'])}/5")

    if selected_person in EVENTS_MAP and not EVENTS_MAP[selected_person].empty:
        st.subheader("Schedule Timeline")
        fig_sched = viz_day.plot_day_schedule(EVENTS_MAP[selected_person], selected_date)
        st.plotly_chart(fig_sched, use_container_width=True)
    else:
        st.info("No schedule data available for this person.")

    d1, d2 = st.columns(2)

    with d1:
        st.subheader("Steps Context")
        week_start = selected_date - datetime.timedelta(days=3)
        week_end = selected_date + datetime.timedelta(days=3)
        week_df = person_df[(person_df['date'] >= week_start) & (person_df['date'] <= week_end)]
        weekly_avg = week_df['steps'].mean() if not week_df.empty else None

        fig_steps = viz_day.plot_intraday_steps_fallback(
            day_row['steps'], selected_date, weekly_avg
        )
        st.plotly_chart(fig_steps, use_container_width=True)

    with d2:
        st.subheader("Screen Breakdown")
        fig_screen = viz_day.plot_screentime_breakdown(day_row)
        st.plotly_chart(fig_screen, use_container_width=True)

    if selected_person in VISITS_MAP and not VISITS_MAP[selected_person].empty:
        st.subheader("Top Places")
        st.caption("Showing aggregated visit data for the selected date range.")
        person_visits = VISITS_MAP[selected_person]
        range_visits = person_visits[
            (person_visits['date'] >= start_d) & (person_visits['date'] <= end_d)
        ]
        if range_visits.empty:
            range_visits = person_visits

        if not range_visits.empty:
            fig_map = viz_day.plot_top_places_map(range_visits)
            st.plotly_chart(fig_map, use_container_width=True)
        else:
            st.info("No location data in selected range.")
    else:
        st.info("No location data available for this person.")

with st.expander("🛠 Data Diagnostics"):
    st.write("Dataset Shape:", filtered_df.shape)
    st.write("Columns:", list(filtered_df.columns))

    st.markdown("**Coverage by Dataset (selected range)**")
    cov_rows = []
    for label, flag in [
        ("Steps", 'has_steps'),
        ("Screen", 'has_screen'),
        ("Weather", 'has_weather'),
        ("Classes", 'has_classes'),
        ("Location", 'has_location')
    ]:
        flag_days = filtered_df[filtered_df[flag]]
        cov_rows.append({
            "Dataset": label,
            "Days": int(flag_days.shape[0]),
            "Min Date": flag_days['date'].min() if not flag_days.empty else None,
            "Max Date": flag_days['date'].max() if not flag_days.empty else None
        })
    st.dataframe(pd.DataFrame(cov_rows), use_container_width=True, hide_index=True)

    st.markdown("**Missing Days (selected range)**")
    date_range_list = [d.date() for d in pd.date_range(start=start_d, end=end_d)]
    missing_summary = []
    for label, flag in [
        ("Steps", 'has_steps'),
        ("Screen", 'has_screen'),
        ("Weather", 'has_weather'),
        ("Classes", 'has_classes'),
        ("Location", 'has_location')
    ]:
        available = set(filtered_df.loc[filtered_df[flag], 'date'])
        missing = [d for d in date_range_list if d not in available]
        missing_summary.append({
            "Dataset": label,
            "Missing Count": len(missing),
            "Missing Sample": ", ".join([str(d) for d in missing[:10]])
        })
    st.dataframe(pd.DataFrame(missing_summary), use_container_width=True, hide_index=True)

    st.markdown("**Complete Missing Days Lists**")
    for label, flag in [
        ("Steps", 'has_steps'),
        ("Screen", 'has_screen'),
        ("Weather", 'has_weather'),
        ("Classes", 'has_classes'),
        ("Location", 'has_location')
    ]:
        available = set(filtered_df.loc[filtered_df[flag], 'date'])
        missing = [d for d in date_range_list if d not in available]
        if missing:
            st.caption(f"{label}: {len(missing)} missing days")
            st.text(", ".join([str(d) for d in missing[:50]]))


    st.markdown("**Screen Time Consistency**")
    if 'screen_time_delta_hours' in filtered_df.columns:
        delta = filtered_df['screen_time_delta_hours']
        st.write({
            "mean_delta_hours": round(delta.mean(skipna=True), 3),
            "max_abs_delta_hours": round(delta.abs().max(skipna=True), 3),
            "abs_delta_gt_0.25h": int((delta.abs() > 0.25).sum())
        })
    else:
        st.write("No screen time delta data available.")

    st.markdown("**Warnings & Outliers**")
    warnings = []
    for col in ['steps', 'total_screen_hours', 'digital_load', 'distance_km']:
        if col in filtered_df.columns:
            negatives = int((filtered_df[col] < 0).sum())
            warnings.append({"Metric": col, "Negative Values": negatives})
    st.dataframe(pd.DataFrame(warnings), use_container_width=True, hide_index=True)

    def outlier_count(series):
        s = series.dropna()
        if s.empty or s.std() == 0:
            return 0
        z = (s - s.mean()) / s.std()
        return int((z.abs() > 3).sum())

    outliers = []
    for col in ['steps', 'total_screen_hours', 'digital_load']:
        if col in filtered_df.columns:
            outliers.append({"Metric": col, "Outliers (z>3)": outlier_count(filtered_df[col])})
    st.dataframe(pd.DataFrame(outliers), use_container_width=True, hide_index=True)

    st.markdown("**Loaded CSV Files & Columns**")
    file_rows = []
    for key, files in data_meta.get('files', {}).items():
        file_rows.append({
            "Dataset": key,
            "Files": ", ".join([os.path.basename(f) for f in files]),
            "Columns": ", ".join(data_meta.get('columns', {}).get(key, []))
        })
    st.dataframe(pd.DataFrame(file_rows), use_container_width=True, hide_index=True)

    schedule_files = glob.glob(os.path.join('data', 'schedule', '*.ics'))
    if schedule_files:
        st.markdown("**Schedule Files**")
        st.write([os.path.basename(f) for f in schedule_files])

    st.markdown("**Master Columns**")
    st.code(", ".join(sorted(filtered_df.columns)))