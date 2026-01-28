import streamlit as st
import requests
from PIL import Image
from io import BytesIO
from visualize import top_panels_graphs, generate_user_wordcloud, user_colors, plot_monthly_heatmap, plot_daily_timeline
from process import *
import pandas as pd

#config stronki 
st.set_page_config(page_title="Spotify Dashboard", layout="wide", initial_sidebar_state="expanded")

dfs = process()
user = st.sidebar.selectbox("Użytkownik", list(name.capitalize() for name in dfs.keys())).lower()
year = st.sidebar.selectbox("Rok", reversed(sorted(dfs[user]['year'].unique())))
u_color = user_colors[user][0]

st.markdown(f"""
<style>
[data-testid="stAppViewContainer"], header, .css-ffhzg2, .css-1v3fvcr, [data-testid="stSidebar"] {{
    background-color: #0E1117 !important; color: {u_color} !important;
}}
[data-testid="stSidebar"] span, [data-testid="stSidebar"] div, .block-container {{
    color: {u_color} !important;
}}
[data-baseweb="select"] > div, [data-baseweb="select"] input, .css-1f6slb0 {{
    background-color: #0E1117 !important; color: {u_color} !important; border-color: {u_color} !important;
}}
</style>
""", unsafe_allow_html=True)

MONTHS_PL = {1: "Styczeń", 2: "Luty", 3: "Marzec", 4: "Kwiecień", 5: "Maj", 6: "Czerwiec", 7: "Lipiec", 8: "Sierpień", 9: "Wrzesień", 10: "Październik", 11: "Listopad", 12: "Grudzień"}
months = [m for m in sorted(dfs[user]['month'].unique()) if st.sidebar.checkbox(MONTHS_PL[m], value=True, key=f"m_{m}_{user}")]

def metric_card(c, label, value, color=u_color):
    c.markdown(f"""
    <div style="background-color:#0E1117; color:{color}; padding:20px; border-radius:10px; text-align:center; font-family:sans-serif; margin-bottom:10px;">
        <div style="font-size:32px; font-weight:bold;">{value}</div>
        <div style="font-size:16px;">{label}</div>
    </div>
    """, unsafe_allow_html=True)

panel_data = top_panels_graphs(user, year, months, dfs)
total_hours, total_tracks, total_artists, skip_rate = panel_data["nutshell"]
top_tracks_fig, top_artists_fig = panel_data["top_tracks_fig"], panel_data["top_artists_fig"]

filtered_df = dfs[user][(dfs[user]['year'] == year) & (dfs[user]['month'].isin(months))]
listened = filtered_df[(filtered_df['skipped'] == False) & (filtered_df['s_played'] > 90)]

if not listened.empty:
    total_tracks = listened['spotify_track_uri'].nunique()
    total_artists = listened.drop_duplicates(subset=['spotify_track_uri'])['artist_name'].nunique()
    total_hours = round(listened['s_played'].sum() / 3600, 1)
else:
    total_tracks = 0; total_artists = 0; total_hours = 0
skip_rate = filtered_df['skipped'].mean() if not filtered_df.empty else 0

if not filtered_df.empty:
    top_track = filtered_df.groupby(['track_name', 'artist_name'])['s_played'].sum().sort_values(ascending=False).head(1).reset_index().iloc[0]
    track_name, artist_name = top_track["track_name"], top_track["artist_name"]
else:
    track_name, artist_name = "Brak", "Brak"

GENIUS_ACCESS_TOKEN = ""
def genius_search(song_title, artist_name):
    try:
        return requests.get("https://api.genius.com/search", headers={"Authorization": f"Bearer {GENIUS_ACCESS_TOKEN}"}, params={"q": f"{song_title} {artist_name}"}).json()
    except: return {}
def get_genius_artwork(song_title, artist_name):
    hits = genius_search(song_title, artist_name).get("response", {}).get("hits", [])
    return hits[0]["result"].get("song_art_image_url") if hits else None

def get_deezer_artist_image(artist_name):
    try: return requests.get(f"https://api.deezer.com/search/artist?q={requests.utils.quote(artist_name)}").json()["data"][0]["picture_xl"]
    except: 
        return None

def get_deezer_album_cover(track_name, artist_name):
    try: 
        data = requests.get(f"https://api.deezer.com/search?q={requests.utils.quote(track_name + ' ' + artist_name)}").json()
        return data["data"][0].get("album", {}).get("cover_xl") if data.get("data") else None
    except: 
        return None

def fetch_image_from_url(url):
    try: 
        return Image.open(BytesIO(requests.get(url).content))
    except: 
        return None

cover_art_url = get_genius_artwork(track_name, artist_name) or get_deezer_album_cover(track_name, artist_name)
artist_img_url = get_deezer_artist_image(artist_name)

metrics_col, album_col, artist_col = st.columns([3, 1, 1])
with metrics_col:
    st.markdown(f"<h2 style='color:{u_color};'>W skrócie:</h2>", unsafe_allow_html=True)
    cols = st.columns(4)
    metric_card(cols[0], "Godziny łącznie", total_hours)
    metric_card(cols[1], "Liczba utworów", total_tracks)
    metric_card(cols[2], "Liczba artystów", total_artists)
    metric_card(cols[3], "Udział przewiniętych", f"{skip_rate*100:.1f}%")

col1, col2, col3 = st.columns(3)
with col2: st.image(generate_user_wordcloud(user, dfs, year, months).to_array())

with album_col:
    if cover_art_url:
        img = fetch_image_from_url(cover_art_url)
        if img: st.image(img, caption=f"Album: {track_name}", width=250)
with artist_col:
    if artist_img_url:
        img = fetch_image_from_url(artist_img_url)
        if img: st.image(img, caption=f"Artist: {artist_name}", width=250)

st.subheader("Najlepsze utwory")
st.plotly_chart(top_tracks_fig, use_container_width=True)
st.subheader("Najlepsi artyści")
st.plotly_chart(top_artists_fig, use_container_width=True)

st.markdown("---")

calendar_fig = plot_monthly_heatmap(user, year, months, dfs)
st.subheader("Mapa aktywności w wybranych miesiącach")
st.caption("Kliknij w kwadrat z dniem, aby zobaczyć szczegóły.")

event = st.plotly_chart(
    calendar_fig, 
    use_container_width=True, 
    on_select="rerun",
    key="calendar_chart"
)

selected_date = None

if event and isinstance(event, dict) and "selection" in event:
    selection = event["selection"]
    if "points" in selection and len(selection["points"]) > 0:
        point = selection["points"][0]
        if "customdata" in point:
            selected_date = point["customdata"]

if selected_date:
    st.markdown("---")
    st.header(f"Przebieg dnia: {selected_date}")
    
    target_date = pd.to_datetime(selected_date).date()
    mask = dfs[user]['ts'].dt.date == target_date
    day_df = dfs[user][mask]
    
    if not day_df.empty:
        available_artists = sorted(day_df['artist_name'].unique())
        selected_artists = st.multiselect("Filtruj artystów:", options=available_artists, default=None)
        timeline_fig = plot_daily_timeline(user, dfs[user], selected_date, selected_artists)
        if timeline_fig: 
            st.plotly_chart(timeline_fig, use_container_width=True)
        else: 
            st.info("Zaznacz artystę.")
    else:
        st.warning(f"Brak danych dla {selected_date}.")