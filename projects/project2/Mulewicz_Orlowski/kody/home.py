import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils import *
from utils2 import *

def home():
    st.markdown(
        """
        <div style="background-color: rgba(128, 128, 128, 0.1); padding: 20px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.1);">
            <strong>HOME:</strong> This page was created to work as a basic analysis tool. 
            You can choose the user, year and the view (filter on one specific month or full year) which are applied for the WHOLE PAGE. 
            Scroll down to discover our top artists, albums, songs and time spent on the app. 
            You can also learn our listening habits (the minutes listened per day throughout the month/year) and top words of our favourite songs.
        </div>
        """, unsafe_allow_html=True
    )
    st.write(" ")
    col1, col2, col3 = st.columns(3)
    with col1:
            sel_person = st.selectbox("Choose user", ["Maciek", "Ola"])
            if sel_person == "Ola":
                df = data_ola
                colors = colors_ola
                colors_light = colors_ola_light
            else:
                df = data_maciek
                colors = colors_maciek
                colors_light = colors_maciek_light

    df['ts_date'] = pd.to_datetime(df['ts_date'])
    data = df.copy()
    activity = data.groupby("ts_date")['ms_played'].sum()
    data = activity.reset_index() if isinstance(activity, pd.Series) else activity.copy()
    data['ts_date'] = pd.to_datetime(data['ts_date'])
    data['mins'] = (data['ms_played'] / 60000).round(0)
    available_years = sorted(data['ts_date'].dt.year.unique(), reverse=True)
    with col2:
        sel_year = st.selectbox("Year", available_years)
    with col3:
        view_mode = st.selectbox("View", ["Full Year"] + months)

    col_1, col_2= st.columns((2,3))
    art1, art2 = st.columns([1, 1.5], gap="large")

    title = f"Music Activity Calendar of {sel_year} ({sel_person})"
    st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

    st.plotly_chart(draw_chart(data, colors, sel_year, view_mode), use_container_width=True)

    with col_1:
          top_artists_df, title = get_top_5_artists(df, sel_year, view_mode)
          st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

          rank_color = colors[3]
          for idx, row in top_artists_df.reset_index(drop=True).iterrows():
              rank = idx + 1
              artist_name = row['master_metadata_album_artist_name']
              count = row['counts']
              img_url, spotify_link = get_artist_image_url(artist_name)
              if not img_url: img_url = "https://via.placeholder.com/50"
              html_code = f"""
                    <a href="{spotify_link}" target="_blank" style="text-decoration: none;">
                        <div class="artist-row">
                            <span style="font-size: 1.2rem; font-weight: bold; color: {rank_color}; width: 30px;">#{rank}</span>
                            <img src="{img_url}" class="artist-img">
                            <div class="artist-info">
                                <p class="artist-name">{artist_name}</p>
                                <p class="artist-stats">{count} odtworzeń</p>
                            </div>
                            <div class="spotify-icon">➤</div>
                        </div>
                    </a>
                    """
              st.markdown(html_code, unsafe_allow_html=True)



    with col_2:
          top_albums_df, title = get_top_8_albums(df, sel_year, view_mode)
          st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

          cols = st.columns(4)

          for i, (idx, row) in enumerate(top_albums_df.iterrows()):
              album_name = row['master_metadata_album_album_name']
              artist_name = row['master_metadata_album_artist_name']
              cover_url, _ = get_artist_image_url(artist_name)
              if not cover_url: cover_url = "https://via.placeholder.com/150"

              with cols[i % 4]:
                  st.markdown(f"""
                        <div class="album-grid-item">
                            <img src="{cover_url}" class="album-cover">
                            <div class="album-title-text" title="{album_name}">{album_name}</div>
                            <div class="album-artist-text">{artist_name}</div>
                        </div>
                        """, unsafe_allow_html=True)

    bottom_left, bottom_right = st.columns((2,3))
    with bottom_left:
        fig = chart_sum(data, sel_year, colors[3])
        title = f"Minutes Listened per Month in {sel_year}"
        st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

        st.plotly_chart(fig, use_container_width=True)

    with bottom_right:
        top_songs, title = get_top_5_songs(df, sel_year, view_mode)
        st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

        for index, row in top_songs.reset_index(drop=True).iterrows():
                rank = index + 1
                title = row['master_metadata_track_name']
                artist = row['master_metadata_album_artist_name']
                plays = row['counts']

                rank_color = colors[3]

                st.markdown(f"""
                <div style="
                    background-color: #11141d;
                    border-radius: 10px;
                    padding: 10px 15px;
                    margin-bottom: 8px;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                ">
                    <div style="display: flex; align-items: center; gap: 15px;">
                        <span style="font-size: 1.2rem; font-weight: bold; color: {rank_color}; width: 30px;">#{rank}</span>
                        <div>
                            <div style="color: white; font-weight: 600; font-size: 0.95rem;">{title}</div>
                            <div style="color: #8f9bb3; font-size: 0.8rem;">{artist}</div>
                        </div>
                    </div>
                    <div style="font-family: monospace; color: {colors[3]}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                        {plays}
                    </div>
                </div>
                """, unsafe_allow_html=True)

    st.markdown(f"""<div class="big-title">Word Cloud for top songs by language in {sel_year} ({sel_person})</div>""", unsafe_allow_html=True)

    LIMIT_PIOSENEK = 60

    df_top_data, _ = get_top_5_songs(df, sel_year, view_mode, num=LIMIT_PIOSENEK)

    top_songs_list = list(
        zip(df_top_data['master_metadata_album_artist_name'], df_top_data['master_metadata_track_name']))

    full_lyrics_data = download_lyrics_data(top_songs_list)

    if full_lyrics_data:
        available_langs = sorted(list(set([item['lang'] for item in full_lyrics_data])))
        col1, col2 = st.columns(2)

        with col1:
            selected_lang = st.selectbox("Choose language:", available_langs)
        with col2:
            words_limit = st.slider("Choose number of Words:", min_value=10, max_value=200, value=50, step=10)
        songs_in_lang = [item for item in full_lyrics_data if item['lang'] == selected_lang]
        top_5_in_lang = songs_in_lang[:5]

        st.caption(f"Based on {len(top_5_in_lang)} most popular '{selected_lang}' artists:")
        st.caption(", ".join([f"{item['artist']} - {item['song']}" for item in top_5_in_lang]))
        combined_text = " ".join([item['text'] for item in top_5_in_lang])

        fig = generate_2d_cloud(combined_text, colors, words_limit)
        if fig:
            st.pyplot(fig)


