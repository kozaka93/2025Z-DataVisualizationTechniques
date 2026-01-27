import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from scipy import stats


METRIC_LABELS = {
    "steps": "Steps",
    "digital_load": "Digital Load",
    "total_screen_hours": "Screen Time",
    "balance_index": "Balance Index",
    "class_hours": "Class Hours",
    "temp_mean_c": "Avg Temp (°C)",
    "precip_mm": "Precipitation (mm)",
    "social_hours": "Social Screen",
    "distance_km": "Distance (km)",
    "time_outside_home_min": "Time Outside (min)",
    "unique_places": "Unique Places"
}


def _label(name: str) -> str:
    if name is None:
        return ""
    return METRIC_LABELS.get(name, name.replace('_', ' ').title())


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

    if len(clean_df) > 3000:
        clean_df = clean_df.sample(n=3000, random_state=42)

    is_bool = color_col in clean_df.columns and pd.api.types.is_bool_dtype(clean_df[color_col])
    is_continuous = (color_col in clean_df.columns and
                     pd.api.types.is_numeric_dtype(clean_df[color_col]) and not is_bool)

    fig = px.scatter(
        clean_df,
        x=x_col,
        y=y_col,
        color=color_col if color_col in clean_df.columns else None,
        hover_data=['date'],
        color_continuous_scale='Viridis' if is_continuous else None,
        color_discrete_sequence=["#D7E916", '#0EA5E9', '#F97316', '#22C55E'] if not is_continuous else None,
        title=f"{_label(y_col)} vs {_label(x_col)}",
        trendline='ols' if show_trendline else None,
        labels={
            x_col: _label(x_col),
            y_col: _label(y_col),
            color_col: _label(color_col) if color_col else color_col
        }
    )

    if show_trendline and len(clean_df) >= 3:
        try:
            corr, p_val = stats.pearsonr(clean_df[x_col], clean_df[y_col])
            fig.add_annotation(
                text=f"r = {corr:.3f}\np = {p_val:.3f}\nN = {len(clean_df)}",
                xref="paper", yref="paper",
                x=0.92, y=1.02,
                showarrow=False,
                align="left",
                bgcolor="rgba(15, 23, 42, 0.9)",
                bordercolor="rgba(148, 163, 184, 0.4)",
                borderwidth=1,
                font=dict(color="#e2e8f0", size=11),
                borderpad=6
            )
        except Exception:
            pass

    return apply_chart_style(fig, height=400)


def plot_group_comparison_metric(
    df: pd.DataFrame,
    metric: str,
    group_col: str,
    chart_type: str = 'violin'
) -> go.Figure:
    if df.empty or metric not in df.columns or group_col not in df.columns:
        return _empty_fig('Group comparison data unavailable.')

    clean_df = df[[metric, group_col]].dropna()
    if clean_df.empty:
        return _empty_fig('No data after removing NaNs.')

    if pd.api.types.is_bool_dtype(clean_df[group_col]):
        clean_df[group_col] = clean_df[group_col].map({True: 'Yes', False: 'No'})

    if chart_type == 'violin':
        fig = px.violin(
            clean_df,
            x=group_col,
            y=metric,
            color=group_col,
            box=True,
            points='all',
            title=f"{_label(metric)} by {_label(group_col)}",
            color_discrete_sequence=['#0EA5E9', '#F97316'],
            labels={
                group_col: _label(group_col),
                metric: _label(metric)
            }
        )
    else:
        fig = px.box(
            clean_df,
            x=group_col,
            y=metric,
            color=group_col,
            points='all',
            title=f"{_label(metric)} by {_label(group_col)}",
            color_discrete_sequence=['#0EA5E9', '#F97316'],
            labels={
                group_col: _label(group_col),
                metric: _label(metric)
            }
        )

    fig.update_layout(showlegend=False)

    groups = clean_df[group_col].unique()
    if len(groups) == 2:
        group1 = clean_df[clean_df[group_col] == groups[0]][metric]
        group2 = clean_df[clean_df[group_col] == groups[1]][metric]
        try:
            t_stat, p_val = stats.ttest_ind(group1, group2, nan_policy='omit')
            fig.add_annotation(
                text=f"t-test\np = {p_val:.3f}\nN1={len(group1)}, N2={len(group2)}",
                xref="paper", yref="paper",
                x=0.92, y=1.02,
                showarrow=False,
                align="left",
                bgcolor="rgba(15, 23, 42, 0.9)",
                bordercolor="rgba(148, 163, 184, 0.4)",
                borderwidth=1,
                font=dict(color="#e2e8f0", size=11),
                borderpad=6
            )
        except Exception:
            pass

    return apply_chart_style(fig, height=380)


def plot_group_comparison_summary(
    df: pd.DataFrame,
    metric: str,
    group_col: str
) -> go.Figure:
    if df.empty or metric not in df.columns or group_col not in df.columns:
        return _empty_fig('Group comparison data unavailable.')

    clean_df = df[[metric, group_col]].dropna()
    if clean_df.empty:
        return _empty_fig('No data after removing NaNs.')

    if pd.api.types.is_bool_dtype(clean_df[group_col]):
        clean_df[group_col] = clean_df[group_col].map({True: 'Yes', False: 'No'})

    summary = clean_df.groupby(group_col)[metric].agg(['mean', 'sem', 'count']).reset_index()

    fig = go.Figure()
    fig.add_trace(
        go.Bar(
            x=summary[group_col],
            y=summary['mean'],
            error_y=dict(type='data', array=summary['sem']),
            marker_color=['#0EA5E9', '#F97316'][:len(summary)],
            text=[f"N={int(n)}" for n in summary['count']],
            textposition='outside',
            hovertemplate='Mean: %{y:.2f}<br>SE: %{error_y.array:.2f}<extra></extra>'
        )
    )

    fig.update_layout(
        title=f"{_label(metric)} by {_label(group_col)} (Mean ± SE)",
        yaxis_title=_label(metric),
        showlegend=False
    )

    return apply_chart_style(fig, height=360)


def plot_correlation_heatmap(
    df: pd.DataFrame,
    cols: list,
    min_n: int = 8
) -> go.Figure:
    if df.empty or not cols:
        return _empty_fig('No data for correlation heatmap.')

    available_cols = [c for c in cols if c in df.columns]
    if len(available_cols) < 2:
        return _empty_fig('Need at least 2 metrics for correlation.')

    corr_df = df[available_cols].corr()

    n_matrix = pd.DataFrame(index=available_cols, columns=available_cols, dtype=float)
    for i, col1 in enumerate(available_cols):
        for j, col2 in enumerate(available_cols):
            n_matrix.loc[col1, col2] = df[[col1, col2]].dropna().shape[0]

    mask = n_matrix.astype(float) < min_n
    corr_masked = corr_df.copy()
    corr_masked[mask] = np.nan

    annotations = []
    for i, row in enumerate(available_cols):
        for j, col in enumerate(available_cols):
            n_val = n_matrix.loc[row, col]
            corr_val = corr_masked.loc[row, col]
            if pd.notna(corr_val):
                text = f"{corr_val:.2f}<br>N={int(n_val)}"
            else:
                text = f"N={int(n_val)}"
            annotations.append(
                dict(
                    x=j, y=i,
                    text=text,
                    showarrow=False,
                    font=dict(size=9, color='white' if abs(corr_val) > 0.5 else 'black')
                )
            )

    fig = px.imshow(
        corr_masked,
        x=available_cols,
        y=available_cols,
        color_continuous_scale='RdBu_r',
        zmin=-1,
        zmax=1,
        aspect='equal',
        title=f'Correlation Heatmap (min N={min_n})'
    )

    fig.update_traces(
        hovertemplate='%{x} vs %{y}<br>r = %{z:.3f}<extra></extra>',
        text=None
    )

    tick_labels = [_label(c) for c in available_cols]
    fig.update_xaxes(tickvals=list(range(len(available_cols))), ticktext=tick_labels)
    fig.update_yaxes(tickvals=list(range(len(available_cols))), ticktext=tick_labels)

    fig.update_layout(annotations=annotations)

    n_cols = len(available_cols)
    square_height = max(400, n_cols * 80)
    
    return apply_chart_style(fig, height=square_height)

