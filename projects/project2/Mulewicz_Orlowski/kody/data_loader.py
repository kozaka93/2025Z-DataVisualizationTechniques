import pandas as pd
import glob


def read_json(path: str) -> pd.DataFrame:
    """
    Reads all JSON files from the specified directory path and concatenates them into a single DataFrame.

    Parameters:
    path (str): Path to the directory containing JSON files. Must end with a directory separator ('/').

    Returns:
    pd.DataFrame: A concatenated DataFrame containing data from all found JSON files.
    """
    dataframes = []
    for file in glob.glob(path + '*.json'):
        dataframes.append(pd.read_json(file))
    return pd.concat(dataframes, ignore_index=True)

def split_datetime_column(dataframe: pd.DataFrame, datetime_column: str) -> None:
    """
    Converts the specified column to datetime format and splits it into separate
    date and time columns, appending them to the end of the DataFrame.

    Parameters:
    dataframe (pd.DataFrame): The DataFrame containing the datetime column to be split.
    datetime_column (str): The name of the column containing datetime values to be split.

    Returns:
    None: This function modifies the input DataFrame in place.
    """


    dataframe[datetime_column] = pd.to_datetime(dataframe[datetime_column])

    if dataframe[datetime_column].dt.tz is not None:
        dataframe[datetime_column] = dataframe[datetime_column].dt.tz_convert('Europe/Warsaw')

    dataframe[datetime_column + '_date'] = dataframe[datetime_column].dt.date
    dataframe[datetime_column + '_time'] = dataframe[datetime_column].dt.time

if __name__ == '__main__':

    json = read_json(path='../../spotify_dashboard/Spotify Extended Streaming History/')
    split_datetime_column(dataframe=json, datetime_column='ts')
    json = json.drop(columns=['ip_addr', 'ts'])
    json.to_pickle('data/dane_ola.pkl')

    #in further scripts we use e.g
    # dane_ola = pd.read_pickle("data/dane_ola.pkl")
    # dane_maciek = pd.read_pickle("data/dane_maciek.pkl")