import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils2 import *


def artists_on_the_map():
    st.markdown(
        """
        <div style="background-color: rgba(128, 128, 128, 0.1); padding: 20px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.1);">
            <strong>ARTISTS ON THE MAP:</strong> Explore the global footprint of our music taste. 
            You can use the interactive map to discover where our favorite artists originate from and filter by continent and user, analyze the top countries contributions of each continent. 
            Later on choose specific countries to see local popularity trends and top artists from that region.
        </div>
        """, unsafe_allow_html=True
    )
    st.write(" ")

    title = "Location of listened Artists"
    st.markdown(f"""<div class="big-title">{title}</div>""", unsafe_allow_html=True)

    col1, col2 = st.columns(2)
    with col1:
        sel_person = st.selectbox("Choose user", ["Maciek", "Ola"])

    continent_cords = {
        "Europe": dict(lat=48, lon=24),
        "Asia": dict(lat=35, lon=90),
        "Africa": dict(lat=-8, lon=23),
        "North America": dict(lat=31, lon=-97),
        "South America": dict(lat=-34, lon=-58),
        "Australia/Oceania": dict(lat=-24, lon=148)
    }

    with col2:
        sel_continent = st.selectbox("Choose continent", continent_cords.keys())

    if sel_person == "Ola":
        raw_df = data_ola.copy()
        geo_df = get_artist_loc(data_ola)
        df2 = count_counties(data_ola, sel_continent)
        color = colors_ola[3]
    else:
        raw_df = data_maciek.copy()
        geo_df = get_artist_loc(data_maciek)
        df2 = count_counties(data_maciek, sel_continent)
        color = colors_maciek[3]

    st.plotly_chart(
        plotly_scatter_map(geo_df, mapbox_token, "lat", "lon", continent_cords[sel_continent], color),
        use_container_width=True
    )

    col_slider, = st.columns(1)

    if df2.empty:
        st.warning("No data for this continent.")
        return

    df2_plot = df2.copy()

    if 'Location' not in df2_plot.columns and 'Country' not in df2_plot.columns:
        df2_plot = df2_plot.reset_index()

    if 'Location' in df2_plot.columns:
        df2_plot = df2_plot.rename(columns={'Location': 'Country'})
    elif 'index' in df2_plot.columns:
        df2_plot = df2_plot.rename(columns={'index': 'Country'})

    if 'Country' not in df2_plot.columns:
        first_col = df2_plot.columns[0]
        df2_plot = df2_plot.rename(columns={first_col: 'Country'})

    cols = [c for c in df2_plot.columns if c != 'Country']
    count_col = cols[0] if cols else df2_plot.columns[-1]

    with col_slider:
        sel_num_of_countries = st.slider(
            "Select number of countries",
            min_value=1,
            max_value=max(1, df2_plot.shape[0]),
            value=min(10, df2_plot.shape[0])
        )

    fig_bar = px.bar(
        df2_plot.head(sel_num_of_countries),
        x='Country',
        y=count_col,
        text_auto=True
    )
    fig_bar.update_traces(marker_color=color)
    fig_bar.update_layout(plot_bgcolor='rgba(0,0,0,0)', font=dict(color='white'))
    st.plotly_chart(fig_bar, use_container_width=True)

    st.markdown(f'<div class="big-title">Closer look into the Countries in {sel_continent}</div>', unsafe_allow_html=True)

    col_1, col_2 = st.columns(2)

    available_countries = df2_plot['Country'].head(sel_num_of_countries).tolist()

    with col_1:
        sel_country = st.selectbox("Choose country", available_countries)

    if 'ts_date' in raw_df.columns:
        raw_df['ts_date'] = pd.to_datetime(raw_df['ts_date'])
        available_years = sorted(raw_df['ts_date'].dt.year.unique(), reverse=True)
    else:
        available_years = []

    with col_2:
        sel_year = st.selectbox("Choose year", available_years) if available_years else st.selectbox("Year",
                                                                                                     ["No Data"])

    country_history = pd.DataFrame()

    if sel_country:
        loc_df = get_artist_loc(raw_df, aggregate=False)

        if 'Location' in loc_df.columns:
            artists_in_country_list = loc_df[
                loc_df['Location'] == sel_country
                ]['master_metadata_album_artist_name'].unique()

            country_history = raw_df[
                raw_df['master_metadata_album_artist_name'].isin(artists_in_country_list)
            ]
        else:
            st.error("Problem z plikiem artysci_lokalizacje.csv - brak kolumny Location")

    col_trend, col_top_art = st.columns((1, 1))

    with col_top_art:
        st.markdown(f'<div class="big-title">Top Artists of {sel_year} from {sel_country}</div>',
                    unsafe_allow_html=True)

        if not country_history.empty and sel_year != "No Data":
            yearly_data = country_history[country_history['ts_date'].dt.year == sel_year]

            if not yearly_data.empty:
                top_artists = yearly_data['master_metadata_album_artist_name'].value_counts().head(10).reset_index()
                top_artists.columns = ['Artist', 'Plays']

                fig = px.bar(top_artists, x='Plays', y='Artist', orientation='h', color_discrete_sequence=[color])
                fig.update_layout(yaxis={'categoryorder': 'total ascending'}, plot_bgcolor='rgba(0,0,0,0)',
                                  font=dict(color='white'))
                st.plotly_chart(fig, use_container_width=True)
            else:
                st.info(f"No plays in {sel_year}")
        else:
            st.info("No data available.")

    with col_trend:
        st.markdown(f'<div class="big-title">Popularity Trend for Artists from {sel_country}</div>',
                    unsafe_allow_html=True)
        if not country_history.empty:
            timeline = country_history.set_index('ts_date').resample('ME')['ms_played'].count().reset_index()
            fig = px.line(timeline, x='ts_date', y='ms_played', color_discrete_sequence=[color])
            fig.update_layout(plot_bgcolor='rgba(0,0,0,0)', font=dict(color='white'), yaxis_title="Plays", xaxis_title="Date")
            fig.update_traces(fill='tozeroy')
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No timeline data.")

    st.markdown('</div>', unsafe_allow_html=True)