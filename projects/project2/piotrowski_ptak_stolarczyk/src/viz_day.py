import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

METRIC_LABELS = {
    'steps': 'Steps',
    'total_screen_hours': 'Screen Time',
    'digital_load': 'Digital Load',
    'class_hours': 'Class Hours',
    'precip_mm': 'Precipitation',
    'balance_index': 'Balance Index'
}


def _label(name: str) -> str:
    if name is None:
        return ""
    return METRIC_LABELS.get(name, str(name).replace('_', ' ').title())

SCREEN_CATEGORY_ORDER = [
    'productivity_hours',
    'education_hours',
    'social_hours',
    'entertainment_hours',
    'other_hours'
]

SCREEN_CATEGORY_LABELS = {
    'productivity_hours': 'Productivity',
    'education_hours': 'Education',
    'social_hours': 'Social',
    'entertainment_hours': 'Entertainment',
    'other_hours': 'Other'
}

SCREEN_CATEGORY_COLORS = {
    'productivity_hours': '#0EA5E9',
    'education_hours': '#22C55E',
    'social_hours': '#F97316',
    'entertainment_hours': '#A855F7',
    'other_hours': '#64748B'
}


def _empty_fig(message: str, height: int = 260) -> go.Figure:
    fig = go.Figure()
    fig.add_annotation(
        text=message,
        showarrow=False,
        font_size=14,
        xref="paper",
        yref="paper",
        x=0.5,
        y=0.5
    )
    fig.update_layout(
        height=height,
        xaxis_visible=False,
        yaxis_visible=False,
        template='plotly_white'
    )
    return fig


def _get_date_series(df: pd.DataFrame) -> pd.Series:
    if 'date_dt' in df.columns:
        return pd.to_datetime(df['date_dt'], errors='coerce')
    return pd.to_datetime(df['date'], errors='coerce')


def apply_chart_style(fig: go.Figure, height: int = 360) -> go.Figure:
    fig.update_layout(
        template='plotly_white',
        height=height,
        margin=dict(l=0, r=0, t=50, b=0),
        legend=dict(orientation='h', y=1.05, x=0),
        font=dict(family='Space Grotesk, Segoe UI, sans-serif'),
    )
    fig.update_xaxes(showgrid=False, zeroline=False)
    fig.update_yaxes(showgrid=True, gridcolor='rgba(15, 23, 42, 0.08)', zeroline=False)
    return fig


def plot_calendar_heatmap(df: pd.DataFrame, metric: str = 'steps') -> go.Figure:
    import numpy as np
    if df.empty:
        return _empty_fig('No data for calendar heatmap.')

    df = df.copy()
    df['date'] = pd.to_datetime(df['date'], errors='coerce')
    df = df[df['date'].notna()]
    if df.empty:
        return _empty_fig('No valid dates.')

    if metric not in df.columns:
        numeric_cols = df.select_dtypes('number').columns
        if 'steps' in df.columns:
            metric = 'steps'
        elif len(numeric_cols) > 0:
            metric = numeric_cols[0]
        else:
            return _empty_fig('No numeric metrics available.')

    df[metric] = df[metric].fillna(0)

    min_date = df['date'].min()
    max_date = df['date'].max()
    start = min_date - pd.Timedelta(days=min_date.weekday())
    end = max_date + pd.Timedelta(days=6 - max_date.weekday())
    all_days = pd.date_range(start, end)
    week = ((all_days - start).days // 7)
    day = all_days.weekday
    grid = pd.DataFrame({'date': all_days, 'week': week, 'day': day})
    grid = grid.merge(df[['date', metric]], on='date', how='left')
    grid[metric] = grid[metric].fillna(0)

    n_weeks = grid['week'].max() + 1
    z = np.zeros((7, n_weeks))
    text = np.empty((7, n_weeks), dtype=object)
    for _, row in grid.iterrows():
        z[row['day'], row['week']] = row[metric]
        text[row['day'], row['week']] = row['date'].strftime('%Y-%m-%d') + f"<br>{_label(metric)}: {row[metric]:.0f}"

    selected_date = None
    import streamlit as st
    if 'selected_day' in st.session_state and st.session_state.selected_day:
        selected_date = pd.to_datetime(st.session_state.selected_day)

    import plotly.graph_objects as go
    fig = go.Figure(data=go.Heatmap(
        z=z,
        x=list(range(n_weeks)),
        y=['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        text=text,
        hoverinfo='text',
        colorscale='Viridis',
        showscale=True,
        colorbar=dict(title=_label(metric))
    ))

    if selected_date is not None:
        sel_idx = grid[grid['date'] == selected_date]
        if not sel_idx.empty:
            d = int(sel_idx.iloc[0]['day'])
            w = int(sel_idx.iloc[0]['week'])
            fig.add_shape(
                type='rect',
                x0=w-0.5, x1=w+0.5, y0=d-0.5, y1=d+0.5,
                line=dict(color='#EF4444', width=2),
                fillcolor='rgba(0,0,0,0)',
                layer='above'
            )

    fig.update_layout(
        title=f"Calendar: {_label(metric)}",
        xaxis=dict(title='Week', showgrid=False, zeroline=False, tickmode='array', tickvals=list(range(n_weeks))),
        yaxis=dict(title='', showgrid=False, zeroline=False, tickvals=list(range(7)), ticktext=['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][::-1], autorange='reversed'),
        height=320,
        margin=dict(l=0, r=0, t=50, b=0),
    )
    return fig


def plot_day_schedule(events_df: pd.DataFrame, date) -> go.Figure:
    if events_df.empty:
        return _empty_fig('No schedule items for this day.', height=220)

    day_events = events_df.copy()
    if 'date' in day_events.columns:
        day_events['date_norm'] = pd.to_datetime(day_events['date'], errors='coerce').dt.date
        day_events = day_events[day_events['date_norm'] == date]
    else:
        day_events = pd.DataFrame()
    
    if day_events.empty:
        return _empty_fig('No schedule items for this day.', height=220)

    day_events['start_dt'] = pd.to_datetime(day_events['start_time'], errors='coerce')
    day_events['end_dt'] = pd.to_datetime(day_events['end_time'], errors='coerce')
    day_events = day_events.dropna(subset=['start_dt', 'end_dt'])
    
    if day_events.empty:
        return _empty_fig('No valid time data.', height=220)

    day_events['start_hour'] = day_events['start_dt'].dt.hour + day_events['start_dt'].dt.minute / 60
    day_events['end_hour'] = day_events['end_dt'].dt.hour + day_events['end_dt'].dt.minute / 60
    
    fig = go.Figure()
    
    colors = ['#3B82F6', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899', '#06B6D4']
    
    for idx, (_, row) in enumerate(day_events.iterrows()):
        color = colors[idx % len(colors)]
        
        fig.add_trace(go.Scatter(
            x=[0, 1, 1, 0, 0],
            y=[row['end_hour'], row['end_hour'], row['start_hour'], row['start_hour'], row['end_hour']],
            fill='toself',
            fillcolor=color,
            line=dict(color=color, width=2),
            mode='lines',
            name=row['event_name'],
            hovertemplate=f"<b>{row['event_name']}</b><br>{row['start_dt'].strftime('%H:%M')} - {row['end_dt'].strftime('%H:%M')}<extra></extra>",
            showlegend=False
        ))
        
        mid_hour = (row['start_hour'] + row['end_hour']) / 2
        fig.add_annotation(
            x=0.5,
            y=mid_hour,
            text=f"<b>{row['event_name']}</b>",
            showarrow=False,
            font=dict(color='white', size=11),
            xref='x',
            yref='y'
        )
    
    hours_range = list(range(7, 21))
    fig.update_layout(
        title=f"Schedule: {date}",
        plot_bgcolor='#000000',
        paper_bgcolor='rgba(0,0,0,0)',
        font=dict(color='white'),
        height=600,
        margin=dict(l=50, r=20, t=50, b=50),
        xaxis=dict(
            visible=False,
            range=[0, 1]
        ),
        yaxis=dict(
            title='Time',
            range=[20, 7],
            tickmode='array',
            tickvals=hours_range,
            ticktext=[f"{h}:00" for h in hours_range],
            gridcolor='#334155',
            gridwidth=1,
            showgrid=True,
            zeroline=False
        )
    )
    
    return fig


def plot_intraday_steps_fallback(daily_steps, date, weekly_avg=None) -> go.Figure:
    labels = ['Selected Day']
    values = [daily_steps]
    if weekly_avg is not None:
        labels.append('Weekly Avg')
        values.append(weekly_avg)

    fig = go.Figure()
    fig.add_trace(
        go.Bar(
            x=labels,
            y=values,
            text=[f"{v:,.0f}" if pd.notna(v) else "—" for v in values],
            textposition='auto',
            marker_color=['#111827', '#94A3B8'][:len(values)],
            hovertemplate='%{y:,.0f} steps<extra></extra>'
        )
    )
    fig.update_layout(
        title=f"Steps on {date}",
        yaxis_title='Steps',
        xaxis_title='Context',
        yaxis_tickformat=',.0f'
    )
    return apply_chart_style(fig, height=260)


def plot_screentime_breakdown(row: pd.Series) -> go.Figure:
    cats = [c for c in SCREEN_CATEGORY_ORDER if c in row.index and pd.notna(row[c])]

    if not cats and 'total_screen_hours' in row.index and pd.notna(row['total_screen_hours']):
        data = pd.DataFrame({
            'Category': ['Total'],
            'Hours': [row['total_screen_hours']]
        })
        color_seq = ['#94A3B8']
    elif cats:
        data = pd.DataFrame({
            'Category': [SCREEN_CATEGORY_LABELS.get(c, c) for c in cats],
            'Hours': [row[c] for c in cats]
        })
        color_seq = [SCREEN_CATEGORY_COLORS.get(c, '#94A3B8') for c in cats]
    else:
        return _empty_fig('No screen time data for this day.')

    fig = px.bar(
        data,
        x='Category',
        y='Hours',
        color='Category',
        text_auto='.1f',
        title='Screen Time Breakdown',
        color_discrete_sequence=color_seq
    )
    fig.update_layout(showlegend=False, xaxis_title='Category', yaxis_title='Hours (h)')
    fig.update_traces(hovertemplate='%{x}: %{y:.2f}h<extra></extra>')

    return apply_chart_style(fig, height=300)


def plot_top_places_map(visits_df: pd.DataFrame) -> go.Figure:
    if visits_df.empty:
        return _empty_fig('No location data available.', height=300)

    needed_cols = ['visit_candidate_place_lat', 'visit_candidate_place_lon']
    if not all(c in visits_df.columns for c in needed_cols):
        return _empty_fig('Location columns are missing.', height=300)

    visits_df = visits_df.dropna(subset=needed_cols)
    if visits_df.empty:
        return _empty_fig('No valid location data.', height=300)

    import streamlit as st
    selected_date = None
    if 'selected_day' in st.session_state and st.session_state.selected_day:
        selected_date = pd.to_datetime(st.session_state.selected_day)

    visits_df = visits_df.copy()
    if 'date' in visits_df.columns:
        visits_df['date'] = pd.to_datetime(visits_df['date'], errors='coerce')
    else:
        visits_df['date'] = pd.NaT

    def was_visited_on_selected(group):
        if selected_date is None:
            return False
        return (group['date'].dt.date == selected_date.date()).any()

    agg_dict = {
        'visits': ('visit_candidate_place_id', 'count') if 'visit_candidate_place_id' in visits_df.columns else ('visit_candidate_place_lat', 'size'),
        'place_type': ('visit_candidate_semantic_type', 'first') if 'visit_candidate_semantic_type' in visits_df.columns else ('visit_candidate_place_lat', lambda x: 'Unknown'),
        'visited_selected': (lambda x: was_visited_on_selected(x.to_frame().join(visits_df, how='left')))
    }

    grouped = visits_df.groupby(needed_cols).apply(
        lambda g: pd.Series({
            'visits': g['visit_candidate_place_id'].count() if 'visit_candidate_place_id' in g.columns else len(g),
            'place_type': g['visit_candidate_semantic_type'].iloc[0] if 'visit_candidate_semantic_type' in g.columns and len(g['visit_candidate_semantic_type']) > 0 else 'Unknown',
            'visited_selected': (selected_date is not None and (g['date'].dt.date == selected_date.date()).any())
        })
    ).reset_index()

    center_lat = grouped['visit_candidate_place_lat'].mean()
    center_lon = grouped['visit_candidate_place_lon'].mean()

    grouped['color_flag'] = grouped['visited_selected'].map(lambda x: 'Selected Day' if x else 'Other Days')
    color_discrete_map = {'Selected Day': '#EF4444', 'Other Days': '#2563EB'}

    if not (grouped['color_flag'] == 'Selected Day').any():
        dummy = grouped.iloc[[0]].copy()
        dummy['color_flag'] = 'Selected Day'
        dummy['visits'] = 0
        dummy['visit_candidate_place_lat'] += 0.0001
        dummy['visit_candidate_place_lon'] += 0.0001
        grouped = pd.concat([grouped, dummy], ignore_index=True)
    if not (grouped['color_flag'] == 'Other Days').any():
        dummy = grouped.iloc[[0]].copy()
        dummy['color_flag'] = 'Other Days'
        dummy['visits'] = 0
        dummy['visit_candidate_place_lat'] += 0.0002
        dummy['visit_candidate_place_lon'] += 0.0002
        grouped = pd.concat([grouped, dummy], ignore_index=True)

    fig = px.scatter_mapbox(
        grouped,
        lat='visit_candidate_place_lat',
        lon='visit_candidate_place_lon',
        size='visits',
        color='color_flag',
        color_discrete_map=color_discrete_map,
        size_max=24,
        zoom=5,
        center=dict(lat=center_lat, lon=center_lon),
        hover_data={'visits': True, 'place_type': True},
        mapbox_style='open-street-map',
        title=None
    )
    fig.update_layout(coloraxis_showscale=False)
    fig.update_layout(legend=dict(title='Day', orientation='h', y=1.02, x=0))
    return apply_chart_style(fig, height=380)


def plot_screentime_weekly_context(df: pd.DataFrame, selected_date, metric: str = 'total_screen_hours') -> go.Figure:
    if df.empty or metric not in df.columns:
        return _empty_fig('No screen time data available.')

    start_date = pd.to_datetime(selected_date) - pd.Timedelta(days=3)
    end_date = pd.to_datetime(selected_date) + pd.Timedelta(days=3)

    df = df.copy()
    df['date_dt'] = pd.to_datetime(df['date'])
    window_df = df[(df['date_dt'] >= start_date) & (df['date_dt'] <= end_date)].copy()

    if window_df.empty:
        return _empty_fig('No data in surrounding week.')

    colors = ['#0EA5E9' if d == pd.to_datetime(selected_date).date() else '#94A3B8'
              for d in window_df['date']]

    fig = go.Figure()
    fig.add_trace(
        go.Bar(
            x=window_df['date'],
            y=window_df[metric],
            marker_color=colors,
            text=window_df[metric].apply(lambda x: f"{x:.1f}h" if pd.notna(x) else "—"),
            textposition='outside',
            hovertemplate='%{x|%b %d}: %{y:.2f}h<extra></extra>'
        )
    )

    fig.update_layout(
        title=f'{metric.replace("_", " ").title()} - Weekly Context',
        yaxis_title='Hours',
        showlegend=False
    )

    return apply_chart_style(fig, height=280)
