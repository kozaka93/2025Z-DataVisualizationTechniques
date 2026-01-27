import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

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
    fig.add_annotation(text=message, showarrow=False, font_size=14)
    fig.update_layout(height=height, xaxis_visible=False, yaxis_visible=False)
    return fig


def _get_date_series(df: pd.DataFrame) -> pd.Series:
    if 'date_dt' in df.columns:
        return pd.to_datetime(df['date_dt'], errors='coerce')
    return pd.to_datetime(df['date'], errors='coerce')


def get_screen_categories(df: pd.DataFrame) -> list:
    return [c for c in SCREEN_CATEGORY_ORDER if c in df.columns]


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


def plot_master_timeline(
    df: pd.DataFrame,
    person_name: str,
    show_weather: bool = True,
    show_classes: bool = True,
    missing_days=None
) -> go.Figure:
    if df.empty or 'date' not in df.columns:
        return _empty_fig('No data for timeline.')

    df = df.sort_values('date').copy()
    date_x = _get_date_series(df)
    screen_categories = [c for c in get_screen_categories(df) if df[c].sum(skipna=True) > 0]

    fig = make_subplots(specs=[[{"secondary_y": True}]])

    if screen_categories:
        screen_df = df[df.get('has_screen', True)].copy()
        screen_x = _get_date_series(screen_df)
        for cat in screen_categories:
            fig.add_trace(
                go.Bar(
                    x=screen_x,
                    y=screen_df[cat],
                    name=SCREEN_CATEGORY_LABELS.get(cat, cat),
                    marker_color=SCREEN_CATEGORY_COLORS.get(cat, '#94A3B8'),
                    hovertemplate='%{y:.2f}h<extra></extra>'
                ),
                secondary_y=False
            )
    elif 'total_screen_hours' in df.columns:
        screen_df = df[df.get('has_screen', True)].copy()
        screen_x = _get_date_series(screen_df)
        fig.add_trace(
            go.Bar(
                x=screen_x,
                y=screen_df['total_screen_hours'],
                name='Screen Time',
                marker_color='#94A3B8',
                hovertemplate='%{y:.2f}h<extra></extra>'
            ),
            secondary_y=False
        )

    if 'steps' in df.columns:
        steps_df = df[df.get('has_steps', True)].copy()
        steps_x = _get_date_series(steps_df)
        fig.add_trace(
            go.Scatter(
                x=steps_x,
                y=steps_df['steps'],
                name='Steps',
                mode='lines',
                line=dict(color='#1F2937', width=3),
                hovertemplate='%{y:,.0f} steps<extra></extra>'
            ),
            secondary_y=True
        )

    if 'balance_index' in df.columns:
        bal_df = df[df['balance_index'].notna()].copy()
        if not bal_df.empty:
            steps_max = df['steps'].max() if 'steps' in df.columns else 1
            fig.add_trace(
                go.Scatter(
                    x=_get_date_series(bal_df),
                    y=np.full(len(bal_df), steps_max * 1.12),
                    mode='markers',
                    name='Balance Index',
                    marker=dict(
                        size=9,
                        color=bal_df['balance_index'],
                        colorscale='RdYlGn',
                        cmin=0,
                        cmax=100,
                        showscale=True,
                        colorbar=dict(title='Balance', len=0.5, y=0.8)
                    ),
                    hovertemplate='Balance: %{marker.color:.1f}/100<extra></extra>'
                ),
                secondary_y=True
            )

    if show_weather and 'precip_mm' in df.columns:
        weather_df = df[df.get('has_weather', True)].copy()
        if not weather_df.empty:
            temp_vals = weather_df['temp_mean_c'] if 'temp_mean_c' in weather_df.columns else np.zeros(len(weather_df))
            marker_sizes = np.clip(4 + weather_df['precip_mm'].fillna(0) * 2, 4, 18)
            fig.add_trace(
                go.Scatter(
                    x=_get_date_series(weather_df),
                    y=np.full(len(weather_df), 0.05),
                    mode='markers',
                    name='Precipitation',
                    marker=dict(size=marker_sizes, color='#3B82F6', opacity=0.7),
                    customdata=np.stack([temp_vals.fillna(np.nan), weather_df['precip_mm'].fillna(0)], axis=-1),
                    hovertemplate='Precip: %{customdata[1]:.1f} mm<br>Temp: %{customdata[0]:.1f} C<extra></extra>'
                ),
                secondary_y=False
            )

    if show_classes and 'class_hours' in df.columns:
        class_df = df[df['class_hours'].notna() & (df['class_hours'] > 0)].copy()
        if not class_df.empty:
            shapes = []
            max_class = class_df['class_hours'].max()
            for row in class_df.itertuples():
                intensity = 0.12 + (row.class_hours / max_class) * 0.2
                x0 = pd.to_datetime(row.date) - pd.Timedelta(hours=12)
                x1 = pd.to_datetime(row.date) + pd.Timedelta(hours=12)
                shapes.append({
                    'type': 'rect',
                    'xref': 'x',
                    'yref': 'paper',
                    'x0': x0,
                    'x1': x1,
                    'y0': 0,
                    'y1': 1,
                    'fillcolor': f'rgba(251, 191, 36, {intensity:.2f})',
                    'line': {'width': 0}
                })
            fig.update_layout(shapes=shapes)

    if missing_days:
        for missing_date in missing_days:
            x0 = pd.to_datetime(missing_date) - pd.Timedelta(hours=12)
            x1 = pd.to_datetime(missing_date) + pd.Timedelta(hours=12)
            fig.add_vrect(
                x0=x0,
                x1=x1,
                fillcolor='rgba(148, 163, 184, 0.25)',
                line_width=0,
                layer='below'
            )

    fig.update_layout(
        title=f"Daily Story: {person_name.capitalize()}",
        hovermode='x unified',
        barmode='stack',
        clickmode='event+select',
        height=520,
        legend=dict(orientation='h', y=1.08, x=0)
    )
    fig.update_xaxes(rangeslider_visible=True, tickformat='%b %d')
    fig.update_yaxes(title_text='Screen Time (hours)', secondary_y=False, rangemode='tozero')
    fig.update_yaxes(title_text='Steps', secondary_y=True, rangemode='tozero')

    return apply_chart_style(fig, height=520)


def plot_coverage_strip(df: pd.DataFrame) -> go.Figure:
    if df.empty:
        return _empty_fig('No coverage data.')

    flags = ['has_steps', 'has_screen', 'has_weather', 'has_classes', 'has_location']
    labels = ['Steps', 'Screen', 'Weather', 'Classes', 'Location']
    flag_df = df[flags].fillna(False).astype(int)
    coverage = df['coverage_score'].fillna(0).astype(int)
    matrix = pd.concat([flag_df, coverage.rename('Coverage')], axis=1).T

    fig = px.imshow(
        matrix,
        x=_get_date_series(df),
        y=labels + ['Coverage'],
        color_continuous_scale=[
            [0.0, '#e2e8f0'],
            [0.2, '#bae6fd'],
            [0.4, '#7dd3fc'],
            [0.6, '#38bdf8'],
            [0.8, '#0ea5e9'],
            [1.0, '#0369a1']
        ],
        aspect='auto',
        title='Data Coverage Strip',
        zmin=0,
        zmax=5
    )
    fig.update_traces(hovertemplate='Date: %{x|%Y-%m-%d}<br>%{y}: %{z}<extra></extra>')
    fig.update_coloraxes(showscale=False)
    return apply_chart_style(fig, height=220)


def plot_weekday_pattern(df: pd.DataFrame, screen_metric: str = 'total_screen_hours') -> go.Figure:
    if df.empty:
        return _empty_fig('No data for weekday pattern.')
    df = df.copy()
    if 'day_of_week' not in df.columns:
        df['day_of_week'] = pd.to_datetime(df['date'], errors='coerce').dt.day_name()

    days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    if 'steps' not in df.columns:
        df['steps'] = np.nan
    if screen_metric not in df.columns:
        df[screen_metric] = np.nan

    grouped = df.groupby('day_of_week').agg(
        steps=('steps', 'mean'),
        screen_metric=(screen_metric, 'mean')
    ).reindex(days_order).reset_index()

    fig = make_subplots(specs=[[{"secondary_y": True}]])

    label = 'Avg Screen Time' if screen_metric == 'total_screen_hours' else 'Avg Digital Load'
    fig.add_trace(
        go.Bar(
            x=grouped['day_of_week'],
            y=grouped['screen_metric'],
            name=label,
            marker_color='#0EA5E9',
            hovertemplate='%{y:.2f}h<extra></extra>'
        ),
        secondary_y=False
    )

    fig.add_trace(
        go.Bar(
            x=grouped['day_of_week'],
            y=grouped['steps'],
            name='Avg Steps',
            marker_color='#111827',
            opacity=0.75,
            hovertemplate='%{y:,.0f} steps<extra></extra>'
        ),
        secondary_y=True
    )

    fig.update_layout(title='Weekday Pattern', barmode='group')
    fig.update_yaxes(title_text='Screen (hours)', secondary_y=False)
    fig.update_yaxes(title_text='Steps', secondary_y=True)

    return apply_chart_style(fig, height=360)


def plot_weather_split(df: pd.DataFrame) -> go.Figure:
    if df.empty or 'rain_flag' not in df.columns:
        return _empty_fig('No weather split data.')

    df = df.copy()
    df['rain_group'] = df['rain_flag'].map({True: 'Rain', False: 'No Rain'})
    melt_cols = [c for c in ['steps', 'digital_load'] if c in df.columns]
    if not melt_cols:
        return _empty_fig('No metrics available for split.')

    data = df[['rain_group'] + melt_cols].melt(
        id_vars='rain_group', var_name='metric', value_name='value'
    )

    fig = px.violin(
        data,
        x='rain_group',
        y='value',
        color='rain_group',
        box=True,
        points='all',
        facet_col='metric',
        color_discrete_sequence=['#60A5FA', '#94A3B8'],
        title='Weather Split'
    )
    fig.update_layout(showlegend=False)
    fig.update_yaxes(matches=None)

    return apply_chart_style(fig, height=360)


def plot_calendar_heatmap(df: pd.DataFrame, metric: str = 'steps') -> go.Figure:
    if df.empty:
        return _empty_fig('No data for calendar heatmap.')

    df = df.copy()
    if 'day_of_week' not in df.columns:
        df['day_of_week'] = pd.to_datetime(df['date'], errors='coerce').dt.day_name()

    if metric not in df.columns:
        numeric_cols = df.select_dtypes('number').columns
        if 'steps' in df.columns:
            metric = 'steps'
        elif len(numeric_cols) > 0:
            metric = numeric_cols[0]
        else:
            return _empty_fig('No numeric metrics available.')

    days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    fig = px.scatter(
        df,
        x=_get_date_series(df),
        y='day_of_week',
        size=metric,
        color=metric,
        size_max=16,
        color_continuous_scale='Viridis',
        category_orders={'day_of_week': days_order[::-1]},
        title=f"Calendar Pattern: {metric}",
        hover_data=[metric]
    )
    fig.update_traces(marker=dict(symbol='square'))
    fig.update_layout(clickmode='event+select')

    return apply_chart_style(fig, height=320)


def plot_day_schedule(events_df: pd.DataFrame, date) -> go.Figure:
    if events_df.empty:
        return _empty_fig('No schedule items for this day.', height=220)

    day_events = events_df[events_df['date'].astype(str) == str(date)].copy()
    if day_events.empty:
        return _empty_fig('No schedule items for this day.', height=220)

    fig = px.timeline(
        day_events,
        x_start='start_time',
        x_end='end_time',
        y='event_name',
        color='event_name',
        title=f"Schedule: {date}",
        color_discrete_sequence=px.colors.qualitative.Set3
    )
    fig.update_yaxes(autorange='reversed')
    fig.update_layout(showlegend=False)

    return apply_chart_style(fig, height=300)


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
            marker_color=['#111827', '#94A3B8'][:len(values)]
        )
    )
    fig.update_layout(title=f"Steps on {date}")
    return apply_chart_style(fig, height=260)


def plot_screentime_breakdown(row: pd.Series) -> go.Figure:
    cats = [c for c in SCREEN_CATEGORY_ORDER if c in row.index]
    if not cats and 'total_screen_hours' in row.index:
        data = pd.DataFrame({'Category': ['Total'], 'Hours': [row['total_screen_hours']]})
    elif cats:
        data = pd.DataFrame({
            'Category': [SCREEN_CATEGORY_LABELS.get(c, c) for c in cats],
            'Hours': [row[c] for c in cats]
        })
    else:
        return _empty_fig('No screen time data for this day.')

    color_seq = [SCREEN_CATEGORY_COLORS.get(c, '#94A3B8') for c in cats] if cats else None
    fig = px.bar(
        data,
        x='Category',
        y='Hours',
        color='Category',
        text_auto='.1f',
        title='Screen Time Breakdown',
        color_discrete_sequence=color_seq
    )
    fig.update_layout(showlegend=False)

    return apply_chart_style(fig, height=300)


def plot_top_places_map(visits_df: pd.DataFrame) -> go.Figure:
    if visits_df.empty:
        return _empty_fig('No location data available.', height=300)

    needed_cols = ['visit_candidate_place_lat', 'visit_candidate_place_lon']
    if not all(c in visits_df.columns for c in needed_cols):
        return _empty_fig('Location columns are missing.', height=300)

    if 'visit_candidate_place_id' in visits_df.columns:
        grouped = visits_df.groupby(needed_cols).agg(
            visits=('visit_candidate_place_id', 'count'),
            place_type=('visit_candidate_semantic_type', 'first')
        ).reset_index()
    elif 'visit_candidate_semantic_type' in visits_df.columns:
        grouped = visits_df.groupby(needed_cols).agg(
            visits=('visit_candidate_place_lat', 'size'),
            place_type=('visit_candidate_semantic_type', 'first')
        ).reset_index()
    else:
        grouped = visits_df.groupby(needed_cols).size().reset_index(name='visits')
        grouped['place_type'] = 'Unknown'

    fig = px.scatter_mapbox(
        grouped,
        lat='visit_candidate_place_lat',
        lon='visit_candidate_place_lon',
        size='visits',
        color='visits',
        size_max=24,
        zoom=11,
        hover_data={'visits': True, 'place_type': True},
        mapbox_style='open-street-map',
        title='Top Places'
    )
    fig.update_layout(coloraxis_showscale=False)
    return apply_chart_style(fig, height=380)


def plot_scatter_dynamic(
    df: pd.DataFrame,
    x_col: str,
    y_col: str,
    color_col=None,
    show_trendline: bool = True
) -> go.Figure:
    if df.empty or x_col not in df.columns or y_col not in df.columns:
        return _empty_fig('Scatter data unavailable.')

    cols = [x_col, y_col, 'date']
    if color_col and color_col in df.columns:
        cols.append(color_col)

    clean_df = df[cols].dropna()
    if clean_df.empty:
        return _empty_fig('Scatter data unavailable.')

    is_bool = color_col in clean_df.columns and pd.api.types.is_bool_dtype(clean_df[color_col])
    is_continuous = color_col in clean_df.columns and pd.api.types.is_numeric_dtype(clean_df[color_col]) and not is_bool

    fig = px.scatter(
        clean_df,
        x=x_col,
        y=y_col,
        color=color_col if color_col in clean_df.columns else None,
        hover_data=['date'],
        color_continuous_scale='Viridis' if is_continuous else None,
        color_discrete_sequence=['#111827', '#0EA5E9', '#F97316', '#22C55E'] if not is_continuous else None,
        title=f"{y_col} vs {x_col}"
    )

    if show_trendline and pd.api.types.is_numeric_dtype(clean_df[x_col]) and pd.api.types.is_numeric_dtype(clean_df[y_col]):
        x_vals = clean_df[x_col].to_numpy()
        y_vals = clean_df[y_col].to_numpy()
        if len(x_vals) > 2:
            slope, intercept = np.polyfit(x_vals, y_vals, 1)
            x_line = np.linspace(x_vals.min(), x_vals.max(), 100)
            y_line = slope * x_line + intercept
            fig.add_trace(
                go.Scatter(
                    x=x_line,
                    y=y_line,
                    mode='lines',
                    name='Trendline',
                    line=dict(color='#475569', dash='dash')
                )
            )
            corr = np.corrcoef(x_vals, y_vals)[0, 1]
            if not np.isnan(corr):
                fig.add_annotation(
                    text=f"r = {corr:.2f}",
                    xref='paper', yref='paper', x=0.98, y=0.02,
                    showarrow=False, font=dict(color='#475569')
                )

    fig.update_layout(showlegend=not is_continuous)
    return apply_chart_style(fig, height=420)


def plot_group_comparison_metric(
    df: pd.DataFrame,
    metric: str,
    group_col: str,
    chart_type: str = 'violin'
) -> go.Figure:
    if df.empty or metric not in df.columns or group_col not in df.columns:
        return _empty_fig('Comparison data unavailable.')

    data = df[[metric, group_col]].dropna()
    if data.empty:
        return _empty_fig('Comparison data unavailable.')

    data[group_col] = data[group_col].map({True: 'Yes', False: 'No'})

    if chart_type == 'box':
        fig = px.box(
            data,
            x=group_col,
            y=metric,
            color=group_col,
            points='all',
            title='Group Comparison',
            color_discrete_sequence=['#111827', '#94A3B8']
        )
    else:
        fig = px.violin(
            data,
            x=group_col,
            y=metric,
            color=group_col,
            box=True,
            points='all',
            title='Group Comparison',
            color_discrete_sequence=['#111827', '#94A3B8']
        )

    fig.update_layout(showlegend=False)
    return apply_chart_style(fig, height=360)


def plot_group_comparison_summary(df: pd.DataFrame, metric: str, group_col: str) -> go.Figure:
    if df.empty or metric not in df.columns or group_col not in df.columns:
        return _empty_fig('Comparison data unavailable.')

    data = df[[metric, group_col]].dropna()
    if data.empty:
        return _empty_fig('Comparison data unavailable.')

    data[group_col] = data[group_col].map({True: 'Yes', False: 'No'})
    summary = data.groupby(group_col)[metric].agg(['mean', 'std', 'count']).reset_index()
    summary['stderr'] = summary['std'] / summary['count'].replace(0, np.nan).pow(0.5)

    fig = go.Figure()
    fig.add_trace(
        go.Bar(
            x=summary[group_col],
            y=summary['mean'],
            error_y=dict(type='data', array=summary['stderr'], visible=True),
            marker_color=['#111827', '#94A3B8'],
            name='Mean'
        )
    )
    fig.update_layout(title='Group Comparison (Mean ± SE)', showlegend=False)
    return apply_chart_style(fig, height=320)


def plot_correlation_heatmap(df: pd.DataFrame, cols: list, min_n: int = 8) -> go.Figure:
    valid_cols = [c for c in cols if c in df.columns]
    if len(valid_cols) < 2:
        return _empty_fig('Not enough metrics for correlation.', height=320)

    unique_cols = list(dict.fromkeys(valid_cols))
    data = df[unique_cols].copy()
    data = data.loc[:, ~data.columns.duplicated()]
    data = data.apply(pd.to_numeric, errors='coerce')
    valid_cols = list(data.columns)

    if len(valid_cols) < 2:
        return _empty_fig('Not enough numeric metrics for correlation.', height=320)

    corr = pd.DataFrame(index=valid_cols, columns=valid_cols, dtype=float)
    n_mat = pd.DataFrame(index=valid_cols, columns=valid_cols, dtype=float)

    for i in valid_cols:
        for j in valid_cols:
            if i == j:
                n = data[i].notna().sum()
                n_mat.loc[i, j] = n
                corr.loc[i, j] = 1.0 if n >= min_n else np.nan
                continue
            pair = data[[i, j]].dropna()
            n = len(pair)
            n_mat.loc[i, j] = n
            if n >= min_n:
                corr.loc[i, j] = pair[i].corr(pair[j])
            else:
                corr.loc[i, j] = np.nan

    fig = px.imshow(
        corr,
        text_auto='.2f',
        aspect='auto',
        color_continuous_scale='RdBu_r',
        title='Correlation Matrix',
        zmin=-1,
        zmax=1
    )
    fig.update_traces(
        customdata=n_mat.values,
        hovertemplate='r: %{z:.2f}<br>N: %{customdata}<extra></extra>'
    )
    return apply_chart_style(fig, height=380)


def plot_screen_composition_shift(
    df: pd.DataFrame,
    group_by: str = 'date',
    mode: str = 'percent'
) -> go.Figure:
    if df.empty:
        return _empty_fig('No data for screen composition.')

    cats = [c for c in SCREEN_CATEGORY_ORDER if c in df.columns]
    if not cats:
        return _empty_fig('No screen categories available.')

    data = df.copy()
    if group_by == 'weekday':
        data['group'] = data.get('day_of_week', pd.to_datetime(data['date'], errors='coerce').dt.day_name())
        group_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    else:
        data['group'] = _get_date_series(data)
        group_order = None

    grouped = data.groupby('group')[cats].sum(min_count=1).reset_index()
    grouped = grouped.melt(id_vars='group', var_name='category', value_name='value')

    if mode == 'percent':
        totals = grouped.groupby('group')['value'].transform('sum').replace(0, np.nan)
        grouped['value'] = (grouped['value'] / totals) * 100
        y_title = 'Share (%)'
    else:
        y_title = 'Hours'

    grouped['category'] = grouped['category'].map(SCREEN_CATEGORY_LABELS)
    color_seq = [SCREEN_CATEGORY_COLORS.get(c, '#94A3B8') for c in SCREEN_CATEGORY_ORDER if c in cats]

    fig = px.bar(
        grouped,
        x='group',
        y='value',
        color='category',
        barmode='stack',
        title='Screen Composition Shift',
        color_discrete_sequence=color_seq
    )
    fig.update_yaxes(title=y_title)
    if group_order:
        fig.update_xaxes(categoryorder='array', categoryarray=group_order)

    return apply_chart_style(fig, height=360)
