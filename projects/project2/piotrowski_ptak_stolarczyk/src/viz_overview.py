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


def get_screen_categories(df: pd.DataFrame) -> list:
    return [c for c in SCREEN_CATEGORY_ORDER if c in df.columns]


def apply_chart_style(fig: go.Figure, height: int = 360, legend: dict | None = None) -> go.Figure:
    fig.update_layout(
        template='plotly_white',
        height=height,
        margin=dict(l=0, r=0, t=50, b=0),
        legend=(legend if legend is not None else dict(orientation='h', y=1.05, x=0)),
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

    fig = make_subplots(specs=[[{"secondary_y": True}]])

    screen_categories = [c for c in get_screen_categories(df) if df[c].sum(skipna=True) > 0]
    if screen_categories:
        screen_df = df[df.get('has_screen', True)].copy()
        if not screen_df.empty:
            x_vals = _get_date_series(screen_df)
            for cat in screen_categories:
                fig.add_trace(
                    go.Bar(
                        x=x_vals,
                        y=screen_df[cat],
                        name=SCREEN_CATEGORY_LABELS.get(cat, cat),
                        marker_color=SCREEN_CATEGORY_COLORS.get(cat, '#94A3B8'),
                        hovertemplate='%{y:.2f}h<extra></extra>'
                    ),
                    secondary_y=False
                )
    elif 'total_screen_hours' in df.columns:
        screen_df = df[df.get('has_screen', True)].copy()
        if not screen_df.empty:
            x_vals = _get_date_series(screen_df)
            fig.add_trace(
                go.Bar(
                    x=x_vals,
                    y=screen_df['total_screen_hours'],
                    name='Screen Time',
                    marker_color='#94A3B8',
                    hovertemplate='%{y:.2f}h<extra></extra>'
                ),
                secondary_y=False
            )

    if 'steps' in df.columns:
        steps_df = df[df.get('has_steps', True)].copy()
        if not steps_df.empty:
            x_vals = _get_date_series(steps_df)
            fig.add_trace(
                go.Scatter(
                    x=x_vals,
                    y=steps_df['steps'],
                    name='Steps',
                    mode='lines',
                    line=dict(color='#1F2937', width=3),
                    hovertemplate='%{y:,.0f} steps<extra></extra>'
                ),
                secondary_y=True
            )

    balance_legend = None
    if 'balance_index' in df.columns:
        bal_df = df[df['balance_index'].notna()].copy()
        if not bal_df.empty:
            steps_max = df['steps'].max() if 'steps' in df.columns and df['steps'].notna().any() else 1

            def get_balance_color(v):
                if v <= 20:
                    return '#ef4444'
                elif v <= 40:
                    return '#f97316'
                elif v <= 60:
                    return '#fbbf24'
                elif v <= 80:
                    return '#84cc16'
                else:
                    return '#10b981'

            bal_df['marker_color'] = bal_df['balance_index'].apply(get_balance_color)

            fig.add_trace(
                go.Scatter(
                    x=_get_date_series(bal_df),
                    y=np.full(len(bal_df), steps_max * 1.12),
                    mode='markers',
                    name='Balance',
                    marker=dict(size=9, color=bal_df['marker_color'], line=dict(width=1, color='white')),
                    customdata=bal_df[['balance_index', 'marker_color']],
                    hovertemplate='<b>Balance:</b> %{customdata[0]:.1f}/100<br>'
                                  '<span style="color:%{customdata[1]}">●</span> (Steps/200 - Screen*5)<extra></extra>',
                    showlegend=False
                ),
                secondary_y=True
            )

            balance_legend = [
                ('#10b981', '80-100'),
                ('#84cc16', '60-80'),
                ('#fbbf24', '40-60'),
                ('#f97316', '20-40'),
                ('#ef4444', '0-20'),
            ]

    if show_weather and 'precip_mm' in df.columns:
        weather_df = df[df.get('has_weather', True)].copy()
        if not weather_df.empty:
            temps = weather_df['temp_mean_c'] if 'temp_mean_c' in weather_df.columns else np.zeros(len(weather_df))
            sizes = np.clip(4 + weather_df['precip_mm'].fillna(0) * 2, 4, 18)
            fig.add_trace(
                go.Scatter(
                    x=_get_date_series(weather_df),
                    y=np.full(len(weather_df), 0.05),
                    mode='markers',
                    name='Precipitation',
                    marker=dict(size=sizes, color='#3B82F6', opacity=0.7),
                    customdata=np.stack([temps.fillna(np.nan), weather_df['precip_mm'].fillna(0)], axis=-1),
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
                    'xref': 'x', 'yref': 'paper',
                    'x0': x0, 'x1': x1,
                    'y0': 0, 'y1': 1,
                    'fillcolor': f'rgba(251, 191, 36, {intensity:.2f})',
                    'line': {'width': 0},
                    'layer': 'below'
                })
            fig.update_layout(shapes=shapes)

    if missing_days:
        for d in missing_days:
            x0 = pd.to_datetime(d) - pd.Timedelta(hours=12)
            x1 = pd.to_datetime(d) + pd.Timedelta(hours=12)
            fig.add_vrect(
                x0=x0, x1=x1,
                fillcolor='rgba(148, 163, 184, 0.25)',
                line_width=0,
                layer='below'
            )

    if balance_legend:
        for color, label in balance_legend:
            fig.add_trace(
                go.Scatter(
                    x=[None], y=[None], mode='markers',
                    marker=dict(size=8, color=color, line=dict(width=1, color='white')),
                    name=label, showlegend=True,
                    legendgroup='balance',
                    legendgrouptitle_text='Balance Index',
                    hoverinfo='skip'
                ),
                secondary_y=True
            )

    fig.update_layout(
        hovermode='x unified',
        barmode='stack',
        clickmode='event+select',
        height=620,
        margin=dict(t=10, b=50, l=50, r=220),
        legend=dict(
            orientation='v',
            yanchor='top', y=1.0,
            xanchor='left', x=1.02,
            bgcolor='rgba(17, 24, 39, 0.95)',
            bordercolor='rgba(148, 163, 184, 0.3)',
            borderwidth=1,
            font=dict(size=10),
            tracegroupgap=10
        )
    )
    fig.update_xaxes(rangeslider_visible=False, tickformat='%b %d')
    fig.update_yaxes(title_text='Screen Time (hours)', secondary_y=False, rangemode='tozero')
    fig.update_yaxes(title_text='Steps', secondary_y=True, rangemode='tozero')

    fig = apply_chart_style(fig, height=620, legend=fig.layout.legend)
    fig.update_layout(margin=dict(t=10, b=50, l=50, r=220))

    return fig

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
    
    legend_items = [
        ('#e2e8f0', '0 - No Data'),
        ('#bae6fd', '1'),
        ('#7dd3fc', '2'),
        ('#38bdf8', '3'),
        ('#0ea5e9', '4'),
        ('#0369a1', '5 - Complete')
    ]
    
    for color, label in legend_items:
        fig.add_trace(
            go.Scatter(
                x=[None], y=[None],
                mode='markers',
                marker=dict(size=10, color=color, symbol='square'),
                name=label,
                showlegend=True,
                hoverinfo='skip'
            )
        )
    
    fig.update_layout(
        legend=dict(
            orientation='v',
            yanchor='top',
            y=1.0,
            xanchor='left',
            x=1.02,
            bgcolor='rgba(0,0,0,0)',
            borderwidth=0,
            font=dict(size=10)
        ),
        margin=dict(l=0, r=150, t=50, b=0)
    )
    
    return apply_chart_style(fig, height=220, legend=fig.layout.legend)

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

    fig.update_layout(
        title='Weekday Pattern',
        barmode='group',
        margin=dict(t=50, b=0, l=0, r=0)
    )
    fig.update_yaxes(title_text='Screen (hours)', secondary_y=False)
    fig.update_yaxes(title_text='Steps', secondary_y=True)

    return apply_chart_style(fig, height=360)


def plot_weather_split(df: pd.DataFrame, metric: str = 'steps') -> go.Figure:
    if df.empty or 'rain_flag' not in df.columns:
        return _empty_fig('No weather split data.')

    df = df.copy()
    df['rain_group'] = df['rain_flag'].map({True: 'Rain', False: 'No Rain'})
    
    if metric not in df.columns:
        return _empty_fig(f'Metric {metric} not available.')

    plot_df = df[['rain_group', metric]].dropna()
    
    if plot_df.empty:
        return _empty_fig('No data available for weather split.')

    metric_labels = {
        'steps': 'Steps',
        'digital_load': 'Digital Load',
        'total_screen_hours': 'Screen Time (hours)'
    }
    y_label = metric_labels.get(metric, metric)

    fig = px.violin(
        plot_df,
        x='rain_group',
        y=metric,
        color='rain_group',
        box=True,
        points='all',
        color_discrete_sequence=['#60A5FA', '#94A3B8'],
        title='Weather Split',
        labels={'rain_group': 'Weather', metric: y_label}
    )
    fig.update_layout(
        showlegend=False,
        margin=dict(t=50, b=0, l=0, r=0)
    )

    return apply_chart_style(fig, height=360)


def plot_screen_composition_shift(
    df: pd.DataFrame,
    group_by: str = 'date',
    mode: str = 'percent'
) -> go.Figure:
    if df.empty:
        return _empty_fig('No screen composition data.')

    screen_cats = get_screen_categories(df)
    if not screen_cats:
        return _empty_fig('No screen categories available.')

    df = df.copy()

    if group_by == 'weekday':
        if 'day_of_week' not in df.columns:
            df['day_of_week'] = pd.to_datetime(df['date'], errors='coerce').dt.day_name()
        days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        grouped = df.groupby('day_of_week')[screen_cats].mean().reindex(days_order)
        x_vals = grouped.index
    else:
        grouped = df.set_index('date')[screen_cats]
        x_vals = _get_date_series(df)

    if mode == 'percent':
        totals = grouped.sum(axis=1)
        for cat in screen_cats:
            grouped[cat] = (grouped[cat] / totals * 100).fillna(0)
        y_title = 'Share (%)'
        hover_tmpl = '%{y:.1f}%<extra></extra>'
    else:
        y_title = 'Hours (h)'
        hover_tmpl = '%{y:.1f}h<extra></extra>'

    fig = go.Figure()
    for cat in screen_cats:
        fig.add_trace(
            go.Bar(
                x=x_vals,
                y=grouped[cat],
                name=SCREEN_CATEGORY_LABELS.get(cat, cat),
                marker_color=SCREEN_CATEGORY_COLORS.get(cat, '#94A3B8'),
                hovertemplate=hover_tmpl
            )
        )

    fig.update_layout(
        title='Screen Composition Shift',
        barmode='stack',
        yaxis_title=y_title,
        xaxis_title='Weekday' if group_by == 'weekday' else 'Date'
    )

    return apply_chart_style(fig, height=360)

