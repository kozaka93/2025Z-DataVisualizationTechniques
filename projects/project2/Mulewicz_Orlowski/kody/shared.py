import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils import *
from utils2 import *

def shared():
    st.markdown(
        """
        <div style="background-color: rgba(128, 128, 128, 0.1); padding: 20px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.1);">
            <strong>SHARED:</strong> Welcome to the shared music dashboard which analysis the similarities and differences between us. 
            Use the filters below to control the view for the WHOLE PAGE. 
            Scroll down to discover <strong>Shared Section</strong>, 
            where <span style="color: #c084fc;"><strong>Pink (Ola)</strong></span> and <span style="color: #3b82f6;"><strong>Blue (Maciek)</strong></span> 
            tags show who listened more. On this page you can explore the listening trends over time, top shared artists, and the albums that defined our year.
        </div>
        """, unsafe_allow_html=True
    )
    st.write(" ")

    col_year, col_legend = st.columns([1, 5])
    with col_year:

        data_ola['ts_date'] = pd.to_datetime(data_ola['ts_date'])
        data_maciek['ts_date'] = pd.to_datetime(data_maciek['ts_date'])
        available_years = sorted(data_ola['ts_date'].dt.year.unique(), reverse=True)
        year = st.selectbox("Year", available_years)

    with col_legend:

        color_ola = colors_ola[3]
        color_maciek = colors_maciek[3]

        st.markdown(f"""
            <div style=" display: flex; align-items: center; justify-content: flex-end; gap: 25px; height: 100%; padding-top: 28px; ">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <div style="width: 12px; height: 12px; background-color: {color_ola};"></div>
                    <span style="font-weight: 600; color: #fff; font-size: 1rem;">Minutes played: Ola</span>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <div style="width: 12px; height: 12px; background-color: {color_maciek};"></div>
                    <span style="font-weight: 600; color: #fff; font-size: 1rem;">Minutes played: Maciek</span>
                </div>
            </div>
            """, unsafe_allow_html=True)

    tab_type = [['master_metadata_album_artist_name', 'master_metadata_track_name'],
                ['master_metadata_album_artist_name', 'master_metadata_album_album_name'],
                ['master_metadata_album_artist_name']]

    shared_artists = shared_tab(data_ola, data_maciek, tab_type[2], year)
    title = f"Top shared artists of {year}"
    st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

    cols = st.columns(5)

    for i, (idx, row) in enumerate(shared_artists.iterrows()):

        artist_name = row['master_metadata_album_artist_name']
        cover_url, _ = get_artist_image_url(artist_name)
        if not cover_url: cover_url = "https://via.placeholder.com/150"

        with cols[i % 5]:

            mins_a = row['minutes_a']
            mins_b = row['minutes_b']
            color_ola = colors_ola[3]
            color_maciek = colors_maciek[3]

            st.markdown(f"""
              <div class="album-grid-item">
                  <img src="{cover_url}" class="album-cover">
                  <div class="album-title-text" title="{artist_name}">{artist_name}</div>
                  <div style="display: flex; gap: 10px; justify-content: center;">
                      <div style="font-family: monospace; color: {color_ola}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                          {mins_a}
                      </div>
                      <div style="font-family: monospace; color: {color_maciek}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                          {mins_b}
                      </div>
                  </div>
              </div>
              """, unsafe_allow_html=True)

    render_shared_artist_timeseries(
        shared_artists=shared_artists,
        year=year,
        data_ola=data_ola,
        data_maciek=data_maciek,
        freq="D")

    st.markdown('<div style="height: 8px;"></div>', unsafe_allow_html=True)
    bottom_left, bottom_right = st.columns(2)

    for i in range(2):

        shared_df = shared_tab(data_ola, data_maciek, tab_type[i], year)

        if i == 0:
            current_col = bottom_left
            title = f"Top shared songs of {year}"
        else:
            current_col = bottom_right
            title = f"Top shared albums of {year}"

        with current_col:
            st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

        for index, row in shared_df.reset_index(drop=True).iterrows():
            rank = index + 1

            if i == 0:
                current_col = bottom_left
            else:
                current_col = bottom_right

            with current_col:
                mins_a = row['minutes_a']
                mins_b = row['minutes_b']

                if tab_type[i] == ['master_metadata_album_artist_name', 'master_metadata_track_name']:
                    title = row['master_metadata_track_name']
                    artist = row['master_metadata_album_artist_name']
                elif tab_type[i] == ['master_metadata_album_artist_name']:
                    title = row['master_metadata_album_artist_name']
                    artist = ""
                else:
                    title = row['master_metadata_album_album_name']
                    artist = row['master_metadata_album_artist_name']

                rank_color = "#fff"
                color_ola = colors_ola[3]
                color_maciek = colors_maciek[3]

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
                      <div style="display: flex; gap: 10px;">
                          <div style="font-family: monospace; color: {color_ola}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                              {mins_a}
                          </div>
                          <div style="font-family: monospace; color: {color_maciek}; font-size: 0.9rem; background: #262730; padding: 2px 8px; border-radius: 6px;">
                              {mins_b}
                          </div>
                      </div>    
                  </div>
                  """, unsafe_allow_html=True)

