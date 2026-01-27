import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils import *
from utils2 import *
import random

def wrapped():

    if 'page_view' not in st.session_state:
        st.session_state.page_view = 'start'
    if 'person' not in st.session_state:
        st.session_state.person = "Maciek"
    if 'year' not in st.session_state:
        st.session_state.year = "All the time"
    if 'active_artist' not in st.session_state:
        st.session_state.active_artist = None
    if 'active_album' not in st.session_state:
        st.session_state.active_album = None
    if 'show_albums' not in st.session_state:
        st.session_state.show_albums = False
    if 'active_songs' not in st.session_state:
        st.session_state.active_songs = None
    if 'show_songs' not in st.session_state:
        st.session_state.show_songs = False
    if 'top_countries' not in st.session_state:
        st.session_state.top_countries = None

    def switch_page():
        st.session_state.page_view = 'results'
        st.session_state.person_selected = st.session_state.person
        st.session_state.year_selected = st.session_state.year
        st.session_state.active_tab = None

    if st.session_state.page_view == 'start':

        st.session_state.active_artist = None
        st.session_state.active_album = None
        st.session_state.show_albums = False
        st.session_state.active_songs = None
        st.session_state.show_songs = False
        st.session_state.top_countries = False

        st.markdown(f"""<div class="main-title">Welcome to your Spotify Wrapped</div>""", unsafe_allow_html=True)
        col1, col2,  = st.columns(2)

        with col1:
            sel_person = st.selectbox("Choose user", ["Maciek", "Ola"], key='person')
            if sel_person == "Ola":
                df = data_ola
                color = colors_ola[3]
            else:
                df = data_maciek
                color = colors_maciek[3]

        df['ts_date'] = pd.to_datetime(df['ts_date'])
        data = df.copy()
        activity = data.groupby("ts_date")['ms_played'].sum()
        data = activity.reset_index() if isinstance(activity, pd.Series) else activity.copy()
        data['ts_date'] = pd.to_datetime(data['ts_date'])
        data['mins'] = (data['ms_played'] / 60000).round(0)
        available_years = sorted(data['ts_date'].dt.year.unique(), reverse=True)

        options = ["All the time"] + available_years

        with col2:
            sel_year = st.selectbox("Year", options, key='year')

        st.write('')
        st.write('')
        st.markdown(f"""
            <div class="main-title" style="text-align: center;">
                Hi <span style='color: {color};'>{sel_person}</span>!
            </div>
            """, unsafe_allow_html=True)
        st.markdown(f"""<div class="big-title" style="text-align: center;">Wrapped is here...</div>""", unsafe_allow_html=True)
        st.markdown(f"""<div class="big-title" style="text-align: center;">Are you ready?</div>""",
                    unsafe_allow_html=True)
        st.write('')
        st.write('')

        if sel_year == "All the time":
            text = 'over the years'
        else:
            text = f'in {sel_year}'

        st.markdown(f"""<div class="main-title" style="text-align: center;">Let's see what you were into {text}</div>""",
                    unsafe_allow_html=True)
        st.write('')
        st.write('')
        _, button, _ = st.columns([1,1,1])
        with button:
            st.button("Generate your wrapped", on_click=switch_page, use_container_width=True, type='secondary')

    else:

        if 'active_tab' not in st.session_state:
            st.session_state.active_tab = None

        sel_person = st.session_state.person_selected
        sel_year = st.session_state.year_selected

        if sel_person == "Ola":
            df = data_ola
            color = colors_ola[3]
        else:
            df = data_maciek
            color = colors_maciek[3]

        df['ts_date'] = pd.to_datetime(df['ts_date'])
        data = df.copy()
        activity = data.groupby("ts_date")['ms_played'].sum()
        data = activity.reset_index() if isinstance(activity, pd.Series) else activity.copy()
        data['ts_date'] = pd.to_datetime(data['ts_date'])
        data['mins'] = (data['ms_played'] / 60000).round(0)

        if sel_year == "All the time":
            filtered_data = data.copy()
            df2 = df.copy()
        else:
            filtered_data = data[data['ts_date'].dt.year == sel_year].copy()
            df2 = df[df['ts_date'].dt.year == sel_year].copy()

        if st.button("← Back"):
            st.session_state.page_view = 'start'
            st.rerun()

        if sel_year == "All the time":
            text2 = 'over the years'
        else:
            text2 = f'in {sel_year}'

        st.markdown(
            f"""<div class="big-title" style="text-align: center;">Let's see how much music you listened {text2}</div>""",
            unsafe_allow_html=True)
        st.write('')
        st.write('')
        total_mins, total_days = get_total_days_mins(filtered_data)
        st.markdown(f"""
                    <div class="main-title" style="text-align: center;">
                        You've listened for <span style='color: {color};'>{total_mins}</span> minutes!
                    </div>
                    """, unsafe_allow_html=True)
        st.markdown(f"""
                    <div class="main-title" style="text-align: center;">
                        Wow that's <span style='color: {color};'>{total_days}</span> full days!
                    </div>
                    """, unsafe_allow_html=True)

        st.write('')
        st.write('')
        st.divider()
        st.markdown(f"""
                    <div class="main-title" style="text-align: center;">
                        Okay, but who do you think was your favourite artist?
                    </div>
                    """, unsafe_allow_html=True)
        st.write('')

        '''
        ARTISTS
        '''

        top4artist = get_top_5_artists_simple(df2, num=4)['master_metadata_album_artist_name'].values

        if 'shuffled_artists' not in st.session_state or sorted(st.session_state.shuffled_artists) != sorted(top4artist):
            random.shuffle(top4artist)
            st.session_state.shuffled_artists = top4artist

        if 'active_artist' not in st.session_state:
            st.session_state.active_artist = None

        cols_artists = st.columns(len(st.session_state.shuffled_artists))

        for i, col in enumerate(cols_artists):
            artist_name = st.session_state.shuffled_artists[i]
            with col:
                if st.button(
                        artist_name,
                        key=f"artist_btn_{i}",
                        use_container_width=True
                ):
                    st.session_state.active_artist = artist_name
                    st.session_state.show_albums = True

        if st.session_state.active_artist is None:
            st.markdown(
                f"""<div class="big-title" style="text-align: center;">Click the button to see if you were right</div>""",
                unsafe_allow_html=True)
        else:
            if st.session_state.active_artist == top4artist[0]:
                st.markdown(f"""
                            <div class="big-title" style="text-align: center;">
                                  You are right! Your favourite artist was <span style='color: {color};'>{st.session_state.active_artist}</span> 
                            </div>
                            """, unsafe_allow_html=True)
            else:
                st.markdown(f"""
                            <div class="big-title" style="text-align: center;">
                                Unfortunately, you were wrong. But let's see the standings
                            </div>
                            """, unsafe_allow_html=True)
            st.write('')
            st.markdown(f"""
                        <div class="big-title" style="text-align: center;">
                            Your favourite artists <span style='color: {color};'>{text2}</span> 
                        </div>
                        """, unsafe_allow_html=True)

            artist_df = get_top_5_artists_simple(df2)
            cols_artists_grid = st.columns(len(artist_df))

            for idx, row in artist_df.reset_index(drop=True).iterrows():
                with cols_artists_grid[idx]:
                    rank = idx + 1
                    artist_name = row['master_metadata_album_artist_name']
                    img_url, _ = get_artist_image_url(artist_name)
                    if not img_url: img_url = "https://via.placeholder.com/50"
                    st.markdown(f"""
                                <div class="album-grid-item">
                                    <img src="{img_url}" class="album-cover">
                                    <div class="album-title-text" title="{artist_name}">{artist_name}</div>
                                    <div style="display: flex; gap: 10px; justify-content: center;">
                                        <div style="font-family: monospace; color: {color}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                                           #{rank}
                                        </div>
                                    </div>
                                </div>
                                """, unsafe_allow_html=True)



        '''
        ALBUMS
        '''
        if st.session_state.show_albums:

            st.write('')
            st.divider()
            st.markdown(f"""
                        <div class="main-title" style="text-align: center;">
                            What about your favourite album?
                        </div>
                        """, unsafe_allow_html=True)
            st.write('')

            top4albums = get_top_5_albums_simple(df2, num=4)['master_metadata_album_album_name'].values

            if 'shuffled_albums' not in st.session_state or sorted(st.session_state.shuffled_albums) != sorted(top4albums):
                random.shuffle(top4albums)
                st.session_state.shuffled_albums = top4albums

            if 'active_album' not in st.session_state:
                st.session_state.active_album = None

            cols_albums = st.columns(len(st.session_state.shuffled_albums))

            for i, col in enumerate(cols_albums):
                album_name = st.session_state.shuffled_albums[i]
                with col:
                    if st.button(
                            album_name,
                            key=f"album_btn_{i}",
                            use_container_width=True
                    ):
                        st.session_state.active_album = album_name
                        st.session_state.show_songs = True

            if st.session_state.active_album is None:
                st.markdown(
                    f"""<div class="big-title" style="text-align: center;">Click the button to see if you were right</div>""",
                    unsafe_allow_html=True)
            else:
                if st.session_state.active_album == top4albums[0]:
                    st.markdown(f"""
                                <div class="big-title" style="text-align: center;">
                                      You are right! Your favourite album was <span style='color: {color};'>{st.session_state.active_album}</span> 
                                </div>
                                """, unsafe_allow_html=True)
                else:
                    st.markdown(f"""
                                <div class="big-title" style="text-align: center;">
                                    Unfortunately, you were wrong. But let's see the standings
                                </div>
                                """, unsafe_allow_html=True)
                st.write('')
                st.markdown(f"""
                            <div class="big-title" style="text-align: center;">
                                Your favourite albums <span style='color: {color};'>{text2}</span> 
                            </div>
                            """, unsafe_allow_html=True)

                album_df = get_top_5_albums_simple(df2)
                cols_albums_grid = st.columns(len(album_df))

                for idx, row in album_df.reset_index(drop=True).iterrows():
                    with cols_albums_grid[idx]:
                        rank = idx + 1
                        album_name = row['master_metadata_album_album_name']
                        img_url, _ = get_artist_image_url(album_name)
                        if not img_url: img_url = "https://via.placeholder.com/50"
                        st.markdown(f"""
                                    <div class="album-grid-item">
                                        <img src="{img_url}" class="album-cover">
                                        <div class="album-title-text" title="{album_name}">{album_name}</div>
                                        <div style="display: flex; gap: 10px; justify-content: center;">
                                            <div style="font-family: monospace; color: {color}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                                               #{rank}
                                            </div>
                                        </div>
                                    </div>
                                    """, unsafe_allow_html=True)



        '''
        SONGS
        '''
        if st.session_state.show_songs:

            st.write('')
            st.divider()
            st.markdown(f"""
                        <div class="main-title" style="text-align: center;">
                            Do you know what was your favourite song?
                        </div>
                        """, unsafe_allow_html=True)
            st.write('')

            top4songs = get_top_5_songs_simple(df2, num=4)['master_metadata_track_name'].values

            if 'shuffled_songs' not in st.session_state or sorted(st.session_state.shuffled_songs) != sorted(top4songs):
                random.shuffle(top4songs)
                st.session_state.shuffled_songs = top4songs

            if 'active_songs' not in st.session_state:
                st.session_state.active_songs = None

            cols_songs = st.columns(len(st.session_state.shuffled_songs))

            for i, col in enumerate(cols_songs):
                song_name = st.session_state.shuffled_songs[i]
                with col:
                    if st.button(
                            song_name,
                            key=f"song_btn_{i}",
                            use_container_width=True
                    ):
                        st.session_state.active_songs = song_name
                        st.session_state.top_countries = True

            if st.session_state.active_songs is None:
                st.markdown(
                    f"""<div class="big-title" style="text-align: center;">Click the button to see if you were right</div>""",
                    unsafe_allow_html=True)
            else:
                if st.session_state.active_songs == top4songs[0]:
                    st.markdown(f"""
                                <div class="big-title" style="text-align: center;">
                                      You are right! Your favourite song was <span style='color: {color};'>{st.session_state.active_songs}</span> 
                                </div>
                                """, unsafe_allow_html=True)
                else:
                    st.markdown(f"""
                                <div class="big-title" style="text-align: center;">
                                    Unfortunately, you were wrong. But let's see the standings
                                </div>
                                """, unsafe_allow_html=True)
                st.write('')
                st.markdown(f"""
                            <div class="big-title" style="text-align: center;">
                                Your favourite songs <span style='color: {color};'>{text2}</span> 
                            </div>
                            """, unsafe_allow_html=True)

                songs_df = get_top_5_songs_simple(df2)
                cols_songs = st.columns(len(songs_df))

                for idx, row in songs_df.reset_index(drop=True).iterrows():
                    with cols_songs[idx]:
                        rank = idx + 1
                        artist_name = row['master_metadata_album_artist_name']
                        song_name = row['master_metadata_track_name']
                        img_url, _ = get_artist_image_url(artist_name)
                        if not img_url: img_url = "https://via.placeholder.com/50"
                        st.markdown(f"""
                                    <div class="album-grid-item">
                                        <img src="{img_url}" class="album-cover">
                                        <div class="album-title-text" title="{artist_name}">{song_name}</div>
                                        <div style="display: flex; gap: 10px; justify-content: center;">
                                            <div style="font-family: monospace; color: {color}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                                               #{rank}
                                            </div>
                                        </div>
                                    </div>
                                    """, unsafe_allow_html=True)


        if st.session_state.top_countries:

            st.write('')
            st.divider()
            st.markdown(f"""
                        <div class="big-title" style="text-align: center;">
                            And let's see which country's music do you listen to the most
                        </div>
                        """, unsafe_allow_html=True)
            st.write('')

            top_country = count_counties(df2)['Country'].values[0]

            st.markdown(f"""
                        <div class="main-title" style="text-align: center;">
                            You listened to the most music from <span style='color: {color};'>{top_country}</span><br> What a surprise...
                        </div>
                        """, unsafe_allow_html=True)