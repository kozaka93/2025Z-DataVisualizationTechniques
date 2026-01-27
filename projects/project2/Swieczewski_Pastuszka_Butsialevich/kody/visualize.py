import json 
from collections import Counter
import numpy as np
from PIL import Image
from wordcloud import WordCloud
import plotly.express as px
import streamlit as st
from pathlib import Path
from plotly.subplots import make_subplots
import plotly.graph_objects as go
import pandas as pd
import datetime
import calendar

user_colors = {
    "piotr": ["#a6e22e", "#66bb6a"],
    "maciek": ["#f39c12", "#e67e22"],
    "zenia": ["#8e44ad", "#9b59b6"]
}

def darken_color(hex_color, factor=0.3):
    hex_color = hex_color.lstrip('#')
    rgb = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    new_rgb = tuple(int(max(0, min(255, c * factor))) for c in rgb)
    return '#{:02x}{:02x}{:02x}'.format(*new_rgb)

def top_panels(user,year,months,dfs):
    df = dfs[user]
    filtered = df[(df['year'] == year) & (df['month'].isin(months))]
    total_hours = filtered['s_played'].sum()
    skip_rate = filtered['skipped'].mean()
    filtered = filtered[filtered['skipped'] == False]
    total_tracks = filtered['track_name'].nunique()
    total_artists = filtered['artist_name'].nunique()
    top_tracks_t = filtered.groupby('track_name')['h_played'].sum().sort_values(ascending=False).head(10).reset_index()
    top_tracks_n = filtered['track_name'].value_counts().head(10).reset_index()
    top_artists_t = filtered.groupby('artist_name')['h_played'].sum().sort_values(ascending=False).head(10).reset_index()
    top_artists_n = filtered['artist_name'].value_counts().head(10).reset_index()

    return {
        'total_hours': total_hours, 'skip_rate': skip_rate,
        'total_tracks': total_tracks, 'total_artists': total_artists,
        'top_tracks_t': top_tracks_t, 'top_artists_t': top_artists_t,
        'top_tracks_n': top_tracks_n, 'top_artists_n': top_artists_n
    }

def top_panels_graphs(user, year, months, dfs):
    data = top_panels(user, year, months, dfs)
    nutshell = (data['total_hours'], data['total_tracks'], data['total_artists'], data['skip_rate'])
    colors = user_colors[user]

    top_tracks_fig = make_subplots(rows=1, cols=2, subplot_titles=("Wg czasu (godz.)", "Wg liczby odtworzeń"), horizontal_spacing=0.5)
    top_tracks_fig.add_trace(go.Bar(y=data['top_tracks_t']['track_name'], x=data['top_tracks_t']['h_played'], orientation='h', marker=dict(color=colors[0]), name="Czas"), row=1, col=1)
    top_tracks_fig.add_trace(go.Bar(y=data['top_tracks_n']['track_name'], x=data['top_tracks_n']['count'], orientation='h', marker=dict(color=colors[0]), name="Odtworzenia"), row=1, col=2)

    top_artists_fig = make_subplots(rows=1, cols=2, subplot_titles=("Wg czasu (godz.)", "Wg liczby odtworzeń"), horizontal_spacing=0.15)
    top_artists_fig.add_trace(go.Bar(y=data['top_artists_t']['artist_name'], x=data['top_artists_t']['h_played'], orientation='h', marker=dict(color=colors[0]), name="Czas"), row=1, col=1)
    top_artists_fig.add_trace(go.Bar(y=data['top_artists_n']['artist_name'], x=data['top_artists_n']['count'], orientation='h', marker=dict(color=colors[0]), name="Odtworzenia"), row=1, col=2)

    figs_data = [top_tracks_fig, top_artists_fig]
    for fig in figs_data:
        fig.update_layout(template="plotly_dark", plot_bgcolor='rgba(0,0,0,0)', paper_bgcolor='rgba(0,0,0,0)', font=dict(color=colors[1]), showlegend=False, height=500, margin=dict(l=50, r=50, t=80, b=50))
        fig.update_yaxes(autorange="reversed", side="right", tickfont=dict(color = colors[0], size = 14))
        fig.update_xaxes(title_font=dict(color=colors[0]), tickfont=dict(color=colors[0]))

    return {"nutshell": nutshell, "top_tracks_fig": top_tracks_fig, "top_artists_fig": top_artists_fig}

def plot_monthly_heatmap(user, year, months, dfs):
    c_bright = user_colors[user][0] 
    c_mid = user_colors[user][1]
    c_dark = darken_color(c_mid, factor=0.4)
    bg_color = '#161920'

    df = dfs[user]
    date_col = 'ts' if 'ts' in df.columns else 'endTime'
    df_year = df[(df['year'] == year) & (df['month'].isin(months))].copy()
    df_year['date_only'] = df_year[date_col].dt.date
    daily_stats = df_year.groupby('date_only')['s_played'].sum().reset_index()
    daily_stats['hours'] = daily_stats['s_played'] / 3600
    data_map = dict(zip(daily_stats['date_only'], daily_stats['hours']))

    MIESIACE = ["", "Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec",
                "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień"]
    
    DNI_TYGODNIA = ["Pn", "Wt", "Śr", "Cz", "Pt", "So", "Nd"]

    fig = make_subplots(
        rows=3, cols=4,
        subplot_titles=[MIESIACE[i] for i in range(1, 13)],
        vertical_spacing=0.08,
        horizontal_spacing=0.03
    )
    
    max_val = daily_stats['hours'].max() if not daily_stats.empty else 10

    for month in range(1, 13):
        row = (month - 1) // 4 + 1
        col = (month - 1) % 4 + 1
        
        month_matrix = calendar.monthcalendar(year, month)
        
        xs = []
        ys = []
        colors = []
        custom_datas = []
        
        for w_idx, week in enumerate(month_matrix):
            for d_idx, day in enumerate(week):
                if day != 0:
                    current_date = datetime.date(year, month, day)
                    hours = data_map.get(current_date, 0)
                    if month not in months: 
                        hours = 0
                    
                    if hours == 0:
                        fill_color = bg_color
                    else:
                        ratio = min(hours / (max_val * 0.7), 1.0)
                        if ratio < 0.1: fill_color = c_dark
                        else: fill_color = c_mid if ratio < 0.6 else c_bright

                    xs.append(w_idx)
                    ys.append(d_idx) 
                    colors.append(fill_color)
                    custom_datas.append(current_date.strftime('%Y-%m-%d'))

        fig.add_trace(
            go.Scatter(
                x=xs,
                y=ys,
                mode='markers',
                marker=dict(
                    symbol='square',
                    size=20,
                    color=colors,
                    line=dict(width=1, color='#0E1117')
                ),
                customdata=custom_datas,
                hoverinfo='text',
                hovertext=[f"{cd}<br> {h:.2f} h" for cd, h in zip(custom_datas, [data_map.get(pd.to_datetime(d).date(),0) for d in custom_datas])]
            ),
            row=row, col=col
        )
        
        fig.update_xaxes(
            showgrid=False, zeroline=False, showticklabels=False, 
            range=[-0.5, 5.5],
            row=row, col=col
        )
        
        fig.update_yaxes(
            showgrid=False, zeroline=False,
            tickmode='array',
            tickvals=[0, 1, 2, 3, 4, 5, 6],
            ticktext=DNI_TYGODNIA,
            tickfont=dict(size=9, color=user_colors[user][1]),
            showticklabels=True, 
            autorange="reversed", 
            row=row, col=col
        )

    fig.update_layout(
        height=750,
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        margin=dict(t=60, b=20, l=40, r=20),
        showlegend=False,
    )
    
    fig.update_annotations(font=dict(size=12, color=user_colors[user][1]))

    return fig


def plot_daily_timeline(user, df, selected_date, selected_artists=None):
    target_date = pd.to_datetime(selected_date).date()
    day_df = df[df['ts'].dt.date == target_date].copy()
    
    if day_df.empty:
        return None

    day_df['end_ts'] = day_df['ts'] + pd.to_timedelta(day_df['s_played'], unit='s')
    
    if selected_artists:
        day_df = day_df[day_df['artist_name'].isin(selected_artists)]
        
    if day_df.empty:
        return None
    
    day_df['duration_text'] = day_df['s_played'].apply(lambda x: f"{int(x//60)}:{int(x%60):02d}")

    u_color_main = user_colors[user][0]
    
    fig = px.timeline(
        day_df, 
        x_start="ts", 
        x_end="end_ts", 
        y="artist_name",
        color="artist_name", 
        color_discrete_sequence=[u_color_main] * len(day_df['artist_name'].unique()),
        
        
        hover_data={
            "ts": "|%H:%M",         
            "track_name": True,     
            "duration_text": True,  
            "s_played": False,      
            "end_ts": False,        
            "artist_name": False    
        },

        labels={
            "ts": "Godzina",                
            "track_name": "Utwór",
            "duration_text": "Czas trwania" 
        }
    )

    fig.update_yaxes(autorange="reversed", title="")
    fig.update_xaxes(title="Godzina", tickformat="%H:%M")
    
    fig.update_layout(
        template="plotly_dark",
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        font=dict(color=user_colors[user][1]),
        showlegend=False,
        height=max(400, len(day_df['artist_name'].unique()) * 30),
        title=f"Przebieg dnia: {selected_date}"
    )
    
    return fig


def generate_user_wordcloud(user, dfs, year, months, mask_path="assets/headphone.png"):
    df = dfs[user]
    filtered = df[(df['year'] == year) & (df['month'].isin(months))]
    BASE_DIR = Path(__file__).parent.parent
    json_path = BASE_DIR / "assets" / f"{user}.json"
    if not json_path.exists(): 
        return WordCloud(background_color=None, mode="RGBA").generate_from_frequencies({"": 1})
    with open(json_path, "r", encoding="utf-8") as f: 
        freq_dict = json.load(f)
    merged_freqs = Counter()
    for _, row in filtered.iterrows():
        key = f"{row['artist_name']}_{row['track_name']}"
        merged_freqs.update(freq_dict.get(key, {}))
    merged_freqs = {w: c for w, c in merged_freqs.items() if len(w) > 3}
    try:
        mask_img = Image.open(BASE_DIR / mask_path)
        if mask_img.mode == 'RGBA': mask_array = np.array(mask_img.split()[-1]); mask = np.where(mask_array > 0, 0, 255).astype(np.uint8)
        else: mask = np.where(np.array(mask_img.convert('L')) < 128, 0, 255).astype(np.uint8)
    except: 
        mask = None
    wc = WordCloud(mask=mask, mode="RGBA", background_color=None, max_words=3000, min_font_size=10, max_font_size=80, scale=2, color_func=lambda *args, **kwargs: np.random.choice(user_colors[user]))
    wc.generate_from_frequencies(merged_freqs)
    return wc