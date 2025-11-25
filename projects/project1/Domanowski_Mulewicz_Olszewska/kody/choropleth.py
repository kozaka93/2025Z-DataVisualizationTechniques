import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np


try:
    airports = pd.read_csv("iata-icao.csv")
    flights = pd.read_csv("flights_dataset.csv")
    countries_continents = pd.read_csv("countries_continent_codes.csv")
except FileNotFoundError as e:
    print(f"BŁĄD: Nie znaleziono pliku: {e.filename}")
    print("Upewnij się, że pliki .csv (iata-icao.csv, flights_dataset.csv, countries_continent_codes.csv) znajdują się w tym samym folderze co skrypt.")
    exit()


from_WAW = flights.loc[flights["Airport_code"] == "WAW", ["Airport_code", "Destination_code", 'Flights_per_day']]
from_WAW = from_WAW.rename(columns={"Destination_code": "iata"})
df = pd.merge(from_WAW, airports, how='inner', on="iata")

df = pd.merge(
    df,
    countries_continents,
    how='inner',
    left_on='country_code',
    right_on='Two_Letter_Country_Code'
)

filter_condition = (df['Continent_Name'] == 'Europe') | (df['Two_Letter_Country_Code'] == 'TR')
df_filtered = df[filter_condition].copy()

df_filtered['Flights_per_day_int'] = df_filtered['Flights_per_day'].astype(str).str.split('-').str[-1].astype(int)


flights_sum_df = df_filtered.groupby('Three_Letter_Country_Code')['Flights_per_day_int'].sum().reset_index()


all_countries_df = countries_continents[['Three_Letter_Country_Code', 'Continent_Name', 'Two_Letter_Country_Code']].drop_duplicates()


choropleth_df = pd.merge(
    all_countries_df,
    flights_sum_df,
    on='Three_Letter_Country_Code',
    how='left'
)


is_target_region = (choropleth_df['Continent_Name'] == 'Europe') | (choropleth_df['Two_Letter_Country_Code'] == 'TR')


values = choropleth_df['Flights_per_day_int'].fillna(0)


conditions = [
    ~is_target_region,
    is_target_region & (values >= 30),
    is_target_region & (values >= 20) & (values < 30),
    is_target_region & (values >= 10) & (values < 20),
    is_target_region & (values < 10)
]

choices = [
    "No flights /"+
    " Not in Europe",
    "[30-40]",
    "[20-30)",
    "[10-20)",
    "[0-10)"
]
choropleth_df['flight_bin'] = np.select(conditions, choices, default="ERROR")


color_map = {
    "No flights / Not in Europe": "#636363",
    "[0-10)": "#CCE5FF",
    "[10-20)": "#66B2FF",
    "[20-30)": "#007FFF",
    "[30-40]": "#0059B3",
}
category_order = ["[30-40]", "[20-30)", "[10-20)", "[0-10)", "No flights / Not in Europe"]

fig = px.choropleth(
    choropleth_df,
    locations='Three_Letter_Country_Code',
    color='flight_bin',
    locationmode='ISO-3',
    color_discrete_map=color_map,
    category_orders={'flight_bin': category_order}
)

waw_lat, waw_lon = 52.1657, 20.9671
fig.update_layout(
    geo=dict(
        bgcolor='black',
        landcolor='gray',
        subunitcolor='gray',
        center=dict(lat=waw_lat, lon=waw_lon),
        projection=dict(
            type='mercator',
            scale=5.3
        )
    ),
    paper_bgcolor='black',
    font=dict(color='white'),
    title=dict(
        text="Europe, direct from Warsaw",
        x=0.5,
        xanchor="center",
        font=dict(size=28, family="poppins", color="white")
    ),
    legend_title_text="Flights per day",
    legend_title_font=dict(size=16, family="poppins", color="white"),
    legend_font=dict(size=14, family="poppins", color="white"),
    legend=dict(
        x=1.02,
        y=0.5,
        xanchor="left",
        yanchor="middle",
        traceorder="normal",
        bgcolor="black",
        bordercolor="white"
    )
)

waw_lat, waw_lon = 52.1657, 20.9671
fig.add_trace(go.Scattergeo(
    lon=[waw_lon],
    lat=[waw_lat],
    mode='markers+text',
    text=["<b>WAW</b>"],
    textposition="bottom center",
    marker=dict(
        size=15,
        color="red",
        symbol="circle",
        line=dict(width=2)
    ),
    textfont=dict(size=15, color="red", family="poppins"),
    name="Warsaw (WAW)",
    showlegend=False
))

fig.show()