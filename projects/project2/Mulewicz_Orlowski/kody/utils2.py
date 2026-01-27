import pandas as pd
import streamlit as st
import pickle
import os
import plotly.express as px
import toml

colors_maciek = ['#1d2026', '#172554', '#1e40af', '#3b82f6', '#60a5fa', '#93c5fd']
colors_ola = ['#1d2026', '#2e1065', '#7c3aed', '#c084fc', '#e9d5ff', '#dcd0ff']
colors_maciek_light = ['#60a5fa', '#93c5fd', '#bfdbfe', '#dbeafe', "#008080", "#b2d8d8", "#005b96", "#92d2f9",
                       "#344771"] * 20
colors_ola_light = ['#a78bfa', '#c084fc', '#e9d5ff', '#f3e8ff', "#9F2B68", "#D8BFD8", "#660066", "#800080",
                    "#9f72ca"] * 20

with open('data/dane_ola.pkl', 'rb') as file:
    data_ola = pickle.load(file)

with open('data/dane_maciek.pkl', 'rb') as file:
    data_maciek = pickle.load(file)

try:
    secrets = toml.load(".streamlit/secrets.toml")
    mapbox_token = secrets["MAPBOX_TOKEN"]
except FileNotFoundError:
    print("Nie znaleziono pliku secrets.toml! Upewnij się, że ścieżka jest poprawna.")
    mapbox_token = ""

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STYLE_PATH = os.path.join(BASE_DIR, "style.css")

def shared_tab(data_a, data_b, col, sel_year):
    df_a= data_a[data_a['ts_date'].dt.year == sel_year].copy()
    df_b = data_b[data_b['ts_date'].dt.year == sel_year].copy()
    def filter_time(df):

        clean = df.loc[(df['ms_played'] > 30000) & (df[col[0]].notna()), :]

        grouped = clean.groupby(col)['ms_played'].sum().reset_index()
        grouped['minutes'] = grouped['ms_played'] / 60000
        return grouped.drop(columns=['ms_played'])

    tab_a = filter_time(df_a).rename(columns={'minutes': 'minutes_a'})
    tab_b = filter_time(df_b).rename(columns={'minutes': 'minutes_b'})

    shared = tab_a.merge(tab_b, on=col, how='inner')

    shared['shared_time'] = shared[['minutes_a', 'minutes_b']].min(axis=1)

    res_tab = shared.sort_values('shared_time', ascending=False).head(10)
    return res_tab.round(1)


def plotly_scatter_map(df, map_token, lat, lon, continent_cords, color):

    fig = px.scatter_mapbox(
        df,
        lat=lat,
        lon=lon,
        size_max=15,
        hover_name="Artist",
        hover_data ={
            "lat" : False,
            "lon" : False,
            "Artist" : False
        }
    )
    if continent_cords == dict(lat=35, lon=90):
        zoomed = 2.5
    else:
        zoomed = 3

    fig.update_layout(
        mapbox_style="light",
        hovermode="closest",
        mapbox=dict(
            accesstoken=map_token,
            bearing=0,
            center=continent_cords,
            pitch=90,
            zoom=zoomed,
        ),
        margin={"r": 15, "t": 15, "l": 15, "b": 15},
        height=600
    )

    fig.update_traces(
        marker=dict(color=color)
    )

    return fig

def get_artist_loc(df, aggregate=True):
    unique_artists = df.drop_duplicates(
        subset=["master_metadata_album_artist_name"]
    ).reset_index(drop=True)

    location = pd.read_csv("artysci_lokalizacje.csv")
    df_merged = unique_artists.merge(
        location,
        how="left",
        left_on="master_metadata_album_artist_name",
        right_on="Artist"
    )

    if 'Location' in df_merged.columns:
        df_merged['Location'] = df_merged['Location'].fillna('Unknown')

    if aggregate:
        if 'Location' in df_merged.columns:
            df_grouped = df_merged.groupby(
                ["lat", "lon", "Location"]
            )['Artist'].apply(lambda x: '<br>'.join(x)).reset_index()
        else:
            df_grouped = df_merged.groupby(
                ["lat", "lon"]
            )['Artist'].apply(lambda x: '<br>'.join(x)).reset_index()
            df_grouped['Location'] = 'Unknown'
        return df_grouped

    return df_merged


def count_counties(df, continent = None):

    location = pd.read_csv("artysci_lokalizacje.csv")
    countries = pd.read_csv("data/Countries by continents.csv")
    countries["Continent"] = countries["Continent"].replace("Oceania", "Australia/Oceania")

    unique_artists = df.drop_duplicates(subset=["master_metadata_album_artist_name"]).reset_index(drop=True)
    df_with_loc = unique_artists.merge(location, how="left", left_on="master_metadata_album_artist_name", right_on="Artist")
    df_with_loc_country = df_with_loc.merge(countries, how="left", left_on="Location", right_on="Country")
    if continent:
        df_with_loc_country = df_with_loc_country.loc[df_with_loc_country.Continent == continent, ["Artist", "Country", "Continent"]].reset_index(drop=True)
    df_counted = df_with_loc_country.groupby("Country")["Artist"].count().to_frame().sort_values("Artist", ascending=False).reset_index()

    return df_counted

def plotly_bar_chart(df, color, bars_num):

    df_for_fig = df.head(bars_num)

    fig = px.bar(
        df_for_fig,
        x="Country",
        y="Artist",
    )
    fig.update_layout(
        title = "Number of Artists listened in Each Country",
        yaxis=dict(
            title="Number of Artists",
        )
    )
    fig.update_traces(
        marker=dict(color=color)
    )
    return fig


def get_total_days_mins(data):

    if 'mins' not in data.columns:
        data['mins'] = (data['ms_played'] / 60000)
    total_mins = data['mins'].sum()
    total_days = round(total_mins / (24 * 60))

    return total_mins, total_days

def get_top_5_artists_simple(data, num = 5):

    top = data.groupby(['master_metadata_album_artist_name']).size().reset_index(name='counts').sort_values(by='counts', ascending=False)

    return top.head(num)

def get_top_5_songs_simple(data, num = 5):

    top = data.groupby(['master_metadata_track_name', 'master_metadata_album_artist_name']).size().reset_index(name='counts').sort_values(by='counts', ascending=False)

    return top.head(num)


def get_top_5_albums_simple(data, num=5):

    df = data.groupby(['master_metadata_album_album_name', 'master_metadata_album_artist_name']).size().reset_index(
        name='counts').sort_values(by='counts', ascending=False)

    return df.head(num)