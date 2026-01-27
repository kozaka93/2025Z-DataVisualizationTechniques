import random
from typing import Any
import lyricsgenius
import matplotlib.pyplot as plt
import plotly.graph_objects as go
import spotipy
from langdetect import detect
from plotly.subplots import make_subplots
from spotipy.oauth2 import SpotifyClientCredentials
from stop_words import get_stop_words
from wordcloud import WordCloud, STOPWORDS

from utils2 import *

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
GENIUS_ACCESS_TOKEN = secrets["GENIUS_ACCESS_TOKEN"]
genius = lyricsgenius.Genius(GENIUS_ACCESS_TOKEN)

def get_artist_timeseries(df, artist_name, year, freq="D"):
    df_year = df[df['ts_date'].dt.year == year].copy()
    df_artist = df_year[df_year['master_metadata_album_artist_name'] == artist_name].copy()
    if df_artist.empty:
        return pd.DataFrame(columns=["date", "minutes"])

    df_artist = df_artist.set_index('ts_date').resample(freq)['ms_played'].sum().reset_index()

    df_artist['minutes'] = df_artist['ms_played'] / 60000
    df_artist['date'] = df_artist['ts_date'].dt.date

    return df_artist[['date', 'minutes']]

def render_shared_artist_timeseries(shared_artists, year, data_ola, data_maciek, freq="D"):
    if shared_artists.empty:
        return

    st.markdown('<div style="height: 16px;"></div>', unsafe_allow_html=True)
    st.markdown('<div class="card">', unsafe_allow_html=True)
    st.markdown(
        f"""<div class="big-title">Listening over time in {year}</div>""",
        unsafe_allow_html=True
    )

    col_artist, col_who = st.columns([3, 2])

    with col_artist:
        selected_artist = st.selectbox(
            "Choose artist from your shared top:",
            shared_artists['master_metadata_album_artist_name'].tolist(),
            key=f"shared_artist_select_{year}"
        )

    with col_who:
        st.write("Whose listening?")
        who_cols = st.columns(2)
        with who_cols[0]:
            show_ola = st.checkbox("Ola", value=True, key=f"show_ola_{year}")
        with who_cols[1]:
            show_maciek = st.checkbox("Maciek", value=True, key=f"show_maciek_{year}")

    ts_ola = get_artist_timeseries(data_ola, selected_artist, year, freq=freq)
    ts_maciek = get_artist_timeseries(data_maciek, selected_artist, year, freq=freq)

    selected_any = show_ola or show_maciek

    if not selected_any:
        st.info("Zaznacz przynajmniej jedną osobę, żeby zobaczyć wykres.")
        return

    if (show_ola and ts_ola.empty) and (show_maciek and ts_maciek.empty):
        st.info("Brak danych o słuchaniu tego artysty w wybranym roku.")
        return

    if not ts_ola.empty:
        ts_ola['minutes_smooth'] = ts_ola['minutes'].rolling(window=7, min_periods=1).mean()

    if not ts_maciek.empty:
        ts_maciek['minutes_smooth'] = ts_maciek['minutes'].rolling(window=7, min_periods=1).mean()
    fig = go.Figure()

    if show_ola and not ts_ola.empty:
        fig.add_trace(
            go.Scatter(
                x=ts_ola['date'],
                y=ts_ola['minutes_smooth'],
                mode="lines",
                name="Ola (7-day Trend)",
                line=dict(
                    color=colors_ola[3],
                    width=3,
                    shape='spline'
                )
            )
        )

    if show_maciek and not ts_maciek.empty:
        fig.add_trace(
            go.Scatter(
                x=ts_maciek['date'],
                y=ts_maciek['minutes_smooth'],
                mode="lines",
                name="Maciek (7-day Trend)",
                line=dict(
                    color=colors_maciek[3],
                    width=3,
                    shape='spline'
                )
            )
        )

    fig.update_layout(
        xaxis_title="Date",
        yaxis_title="Minutes played (7-day Avg)",  # Warto zaznaczyć, że to średnia
        margin={"l": 40, "r": 20, "t": 20, "b": 40},
        hovermode="x unified",
    )

    st.plotly_chart(fig, use_container_width=True)
def artist_in_the_year(data, artist, year):
    pass

def get_available_years(df):
    df['ts_date'] = pd.to_datetime(df['ts_date'])
    data = df.copy()
    activity = data.groupby("ts_date")['ms_played'].sum()
    data = activity.reset_index() if isinstance(activity, pd.Series) else activity.copy()
    data['ts_date'] = pd.to_datetime(data['ts_date'])
    data['mins'] = (data['ms_played'] / 60000).round(0)
    available_years = sorted(data['ts_date'].dt.year.unique(), reverse=True)
    return available_years

def get_lang(lyrics):
        try:
            return detect(lyrics)
        except:
            return "unknown"


@st.cache_data(show_spinner=False)
def download_lyrics_data(artist_song_pairs):
    genius.verbose = False
    genius.remove_section_headers = True

    lyrics_data = []

    progress_bar = st.progress(0)
    status_text = st.empty()

    total = len(artist_song_pairs)

    for i, (artist, song) in enumerate(artist_song_pairs):
        status_text.text(f"Analizuję ({i + 1}/{total}): {artist} - {song}...")
        try:
            song_obj = genius.search_song(song, artist)
            if song_obj and song_obj.lyrics:
                lang_detected = get_lang(song_obj.lyrics)

                lyrics_data.append({
                    "artist": artist,
                    "song": song,
                    "text": song_obj.lyrics,
                    "lang": lang_detected
                })
        except Exception as e:

            pass

        progress_bar.progress((i + 1) / total)

    progress_bar.empty()
    status_text.empty()

    return lyrics_data


def generate_2d_cloud(text_content, colors, max_count):
    if not text_content:
        return None

    my_stopwords = set(STOPWORDS)
    my_stopwords.update(get_stop_words('polish'))
    my_stopwords.update(get_stop_words('spanish'))
    my_stopwords.update(get_stop_words('german'))
    my_stopwords.update(get_stop_words('french'))
    my_stopwords.update(get_stop_words('dutch'))
    my_stopwords.update(get_stop_words('italian'))
    my_stopwords.update(get_stop_words('korean'))
    my_stopwords.update(get_stop_words('russian'))
    my_stopwords.update(get_stop_words('swedish'))

    polish_stopwords = [
        'i', 'w', 'z', 'na', 'do', 'że', 'się', 'o', 'a', 'to', 'jak', 'ja',
        'ty', 'on', 'ona', 'my', 'wy', 'oni', 'one', 'mnie', 'tobie', 'ciebie',
        'nam', 'wam', 'im', 'jego', 'jej', 'ich', 'tym', 'tam', 'tu', 'ten',
        'ta', 'to', 'te', 'tę', 'będę', 'będzie', 'jest', 'są', 'był', 'była',
        'było', 'byli', 'byle', 'nie', 'tak', 'czy', 'ale', 'bo', 'co', 'gdy',
        'lub', 'albo', 'więc', 'dla', 'po', 'nad', 'pod', 'przez', 'przy', 'od',
        'już', 'też', 'tylko', 'jeszcze', 'bardzo', 'może', 'kiedy', 'gdzie'
    ]
    my_stopwords.update(polish_stopwords)

    my_stopwords.update([
        'feat', 'ft', 'verse', 'chorus', 'intro', 'outro',
        'yeah', 'oh', 'la', 'na', 'ooh'
    ])

    def random_color_func(word, font_size, position, orientation,
                          random_state=None, **kwargs):
        return random.choice(colors)

    wc = WordCloud(
        width=1200,
        height=600,
        max_words=max_count,
        stopwords=my_stopwords,
        background_color=None,
        mode="RGBA",
        collocations=False,
        prefer_horizontal=1.0,
        color_func=random_color_func
    ).generate(text_content)

    fig = plt.figure(figsize=(12, 6), dpi=100)
    fig.patch.set_alpha(0.0)

    plt.imshow(wc, interpolation='bilinear')
    plt.axis("off")

    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
    plt.margins(0, 0)
    plt.gca().set_position([0, 0, 1, 1])

    return fig

def get_artist_image_url(artist_name: str) -> tuple[None, None] | tuple[Any | None, Any, Any]:
    if not artist_name:
        return None, None

    sp = spotipy.Spotify(
        auth_manager=SpotifyClientCredentials(
            client_id=st.secrets["SPOTIPY_CLIENT_ID"],
            client_secret=st.secrets["SPOTIPY_CLIENT_SECRET"],
        )
    )

    result = sp.search(q=artist_name, type="artist", limit=1)
    artists = result.get("artists", {}).get("items", [])

    if not artists:
        return None, None

    artist = artists[0]
    images = artist.get("images", [])
    image_url = images[0]["url"] if images else None
    spotify_url = artist["external_urls"]["spotify"]
    return image_url, spotify_url


def get_total_days(data, year):
    if 'mins' not in data.columns:
        data['mins'] = (data['ms_played'] / 60000)
    df_curr = data[data['ts_date'].dt.year == year]
    total_mins = df_curr['mins'].sum()
    total_days = total_mins / (24 * 60)

    return total_days

def group_by_month(data, sel_year):
    full_rng = pd.date_range(f'{sel_year}-01-01', f'{sel_year}-12-31')
    df_year = data[data['ts_date'].dt.year == sel_year].copy()
    df_year['mins'] = (df_year['ms_played'] / 60000).round(0)
    df_grouped = pd.DataFrame(df_year.groupby(df_year['ts_date'].dt.normalize())['mins'].sum())
    df_plot = df_grouped.reindex(full_rng,fill_value=0).reset_index(names='date')
    df_plot['mo'] = df_plot['date'].dt.month
    df_plot['d'] = df_plot['date'].dt.dayofweek
    df_plot['w'] = df_plot['date'].dt.strftime('%W').astype(int)
    df_plot['w'] = df_plot['w'] - df_plot.groupby('mo')['w'].transform('min')
    return df_plot

def get_top_5_artists(data, sel_year, view_mode):
    df = data[data['ts_date'].dt.year == sel_year].copy()
    if view_mode in months:
        month_num = months.index(view_mode) + 1
        df = df[df['ts_date'].dt.month == month_num]
        title = f"Top artists of {sel_year} ({view_mode})"
    else:
        title = f"Top artists of {sel_year}"
    df = df.groupby(['master_metadata_album_artist_name']).size().reset_index(name='counts').sort_values(by='counts', ascending=False)
    return df.head(6), title

def get_top_5_songs(data, sel_year, view_mode, num = 5):
    df = data[data['ts_date'].dt.year == sel_year].copy()
    if view_mode in months:
        month_num = months.index(view_mode) + 1
        df = df[df['ts_date'].dt.month == month_num]
        title = f"Top songs of {sel_year} ({view_mode})"
    else:
        title = f"Top songs of {sel_year}"
    top = df.groupby(['master_metadata_track_name', 'master_metadata_album_artist_name']).size().reset_index(
        name='counts').sort_values(by='counts', ascending=False)
    return top.head(num), title

def get_top_8_albums(data, sel_year, view_mode):
    if view_mode in months:
        month_num = months.index(view_mode) + 1
        data = data[data['ts_date'].dt.month == month_num]
        title = f"Top albums of {sel_year} ({view_mode})"
    else:
        title = f"Top albums of {sel_year}"

    df = data[data['ts_date'].dt.year == sel_year].copy()
    df = df.groupby(['master_metadata_album_album_name', 'master_metadata_album_artist_name']).size().reset_index(
        name='counts').sort_values(by='counts', ascending=False)
    return df.head(12), title

def num_of_artists_listened(data, sel_year):
    df = data[data['ts_date'].dt.year == sel_year].copy()
    df = df.groupby(['master_metadata_album_artist_name']).size().reset_index()
    return df.shape[0]

def get_max_in_the_day(data, sel_year):
    df = data[data['ts_date'].dt.year == sel_year].copy()

    if df.shape[0] == 0:
        return 0
    daily_sum = df.groupby(df['ts_date'].dt.date)['ms_played'].sum()
    daily_sum_df = daily_sum.reset_index(name='total_ms_played').sort_values(by=['total_ms_played'], ascending=False)
    daily_sum_df['hours'] = daily_sum_df['total_ms_played'] / (1000 * 60 * 60)

    return daily_sum_df.iloc[0]['hours']


def chart_sum(data, sel_year, color):
    df = group_by_month(data, sel_year)
    sums = df.groupby('mo')['mins'].sum()
    fig = go.Figure()

    fig.add_trace(go.Scatter(
        x=months,
        y=sums,
        mode='lines+markers',
        line=dict(color=color, width=3),
        marker=dict(size=8)
    ))

    fig.update_layout(
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        font=dict(color="#a0a0a0"),
        legend=dict(
            orientation="h",
            yanchor="bottom", y=1.02,
            xanchor="right", x=1
        ),
        margin=dict(l=20, r=20, t=50, b=20),
        height=400
    )

    fig.update_yaxes(gridcolor='#333', zerolinecolor='#333', rangemode="tozero")
    fig.update_xaxes(gridcolor='#333', tickangle=-45)

    return fig

def draw_chart(data, colors, sel_year, view_mode):
    df_plot = group_by_month(data, sel_year)
    c_scale = [[i / (len(colors) - 1), col] for i, col in enumerate(colors)]
    max_val = data['mins'].max() if not data.empty else 100

    active_days = data[data['mins'] > 0]['mins']
    q20 = active_days.quantile(0.2)
    q40 = active_days.quantile(0.4)
    q60 = active_days.quantile(0.6)
    q80 = active_days.quantile(0.8)

    def get_col(v):
        if v == 0: return colors[0]
        if v <= q20: return colors[1]
        if v <= q40: return colors[2]
        if v <= q60: return colors[3]
        if v <= q80: return colors[4]
        return colors[5]

    target_mo = [months.index(view_mode) + 1] if view_mode != "Full Year" else range(1, 13)
    rows, cols, height = (1, 1, 500) if view_mode != "Full Year" else (2, 6, 500)
    titles = [months[i - 1] for i in target_mo]
    day_labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S']

    fig = make_subplots(rows=rows, cols=cols, subplot_titles=titles, vertical_spacing=0.25, horizontal_spacing=0.015)

    for i, m in enumerate(target_mo):
        d_m = df_plot[df_plot['mo'] == m]
        r, c = (1, 1) if len(target_mo) == 1 else (1 if i < 6 else 2, i + 1 if i < 6 else i - 5)
        xref, yref = f'x{"" if (r - 1) * 6 + c == 1 else (r - 1) * 6 + c}', f'y{"" if (r - 1) * 6 + c == 1 else (r - 1) * 6 + c}'

        hx, hy, ht = [], [], []
        for _, row in d_m.iterrows():
            if row['w'] < 6:
                radius = 0.4
                fig.add_shape(
                    type="circle",
                    x0=row['d'] - radius,
                    y0=row['w'] - radius,
                    x1=row['d'] + radius,
                    y1=row['w'] + radius,
                    fillcolor=get_col(row['mins']),
                    line=dict(width=0),
                    xref=xref,
                    yref=yref,
                    layer="below"
                )
                hx.append(row['d'])
                hy.append(row['w'])
                ht.append(f"<b>{row['date'].strftime('%d %b')}</b><br>{int(row['mins'])} min")

        fig.add_trace(go.Scatter(x=hx, y=hy, mode='markers', marker=dict(size=20, color='rgba(0,0,0,0)'), text=ht,
                                 hoverinfo='text', showlegend=False), row=r, col=c)
        fig.update_xaxes(
            showticklabels=True, tickmode='array', tickvals=[0, 1, 2, 3, 4, 5, 6], ticktext=day_labels, side='top',
            tickfont=dict(size=9, color=colors[5]), range=[-0.5, 6.5], showgrid=False, zeroline=False, row=r, col=c)
        fig.update_yaxes(showticklabels=False, autorange="reversed", range=[-0.5, 5.5], row=r, col=c, showgrid=False,
                         zeroline=False)

    fig.update_layout(
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        font=dict(family="Arial", color="#a0a0a0"),
        height=height,
        margin=dict(t=80, b=20, l=10, r=10),
        showlegend=False
    )
    fig.update_annotations(font_color=colors[5], yshift=30, font_size=14)

    fig.add_trace(go.Scatter(
        x=[None], y=[None],
        mode='markers',
        marker=dict(
            colorscale=c_scale,
            cmin=0,
            cmax=max_val,
            showscale=True,
            colorbar=dict(
                orientation="v",
                title="minutes listened",
                thickness=15,
            )),
        hoverinfo='none',
        showlegend=False
    ))

    return fig