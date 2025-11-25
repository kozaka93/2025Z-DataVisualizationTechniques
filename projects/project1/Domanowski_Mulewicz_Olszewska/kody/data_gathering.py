import pandas as pd

# Sources
# https://github.com/ip2location/ip2location-iata-icao?tab=readme-ov-file
# add more...

df = pd.read_csv("iata-icao.csv")
df.to_pickle("iata-icao_airports.pkl")

df = pd.read_csv("airports.csv")
df.to_pickle("airports.pkl")

df = pd.read_csv("flights_dataset.csv")
df.to_pickle("flights.pkl")
