import streamlit as st
import pandas as pd
import modules.stacked_bar_chart as stacked_bar_chart
import modules.radar_chart as radar_chart
import modules.heatmap as heatmap
import modules.prediction as prediction
import modules.scatter_plot as scatter_plot

st.set_page_config(
    page_title="Dashboard Żywieniowy",
    page_icon="🍎",
    layout="wide"
)

@st.cache_data
def load_data():
    pliki = [
        ('Hubert', 'dane_hubert.csv'),
        ('Szymon', 'dane_szymon.csv'),
        ('Zosia',  'dane_zosia.csv')
    ]
    
    dataframes = []
    
    for osoba, nazwa_pliku in pliki:
        try:
            temp_df = pd.read_csv(nazwa_pliku, sep=';', decimal=',')
            temp_df['Osoba'] = osoba
            dataframes.append(temp_df)
        except FileNotFoundError:
            st.error(f"Nie znaleziono pliku: '{nazwa_pliku}'. Upewnij się, że jest w folderze aplikacji.")
    
    if dataframes:
        return pd.concat(dataframes, ignore_index=True)
    else:
        return pd.DataFrame()


def main():
    df = load_data()
    
    if df.empty:
        st.warning("Brak danych do wyświetlenia. Sprawdź pliki CSV.")
        return

    st.sidebar.title("Nawigacja")
    
    opcje = {
        "Analiza Spożycia (Bar Chart)": "bar",
        "Wykres Radarowy (Radar)": "radar",
        "Mapa Produktywności (Heatmap)": "heatmap",
        "Kalorie vs aktywność (Scatter Plot)": "scatter",
        "Predyktor ML (K-NN)": "prediction"
    }
    
    wybor = st.sidebar.radio("Wybierz moduł:", list(opcje.keys()))
    wybrany_klucz = opcje[wybor]

    if wybrany_klucz == "bar":
        st.sidebar.subheader("📊 O tym wykresie")
        st.sidebar.info(
            """
            **Analiza Spożycia (Bar Chart)**
            
            Ten widok pozwala śledzić codzienne nawyki żywieniowe na osi czasu.
            
            **Jak czytać:**
            * **Pory Posiłków:** Sprawdź, kiedy jesz najwięcej. Każdy słupek to jeden dzień podzielony na posiłki.
            * **Struktura Kalorii:** Zobacz, z czego składa się Twoja energia (Białko/Tłuszcze/Węgle).
            * Aby wybrać zakres dat, najedź kursorem na wykres i przeciągnij.
            """
        )
    
    elif wybrany_klucz == "radar":
        st.sidebar.subheader("📊 O tym wykresie")
        st.sidebar.info(
            """
            **Wykres Radarowy (Radar)**
            
            Służy do oceny balansu makroskładników w wybranym okresie.
            
            **Jak czytać:**
            * Wykres pokazuje średnie spożycie składników.
            * **Skala (0-100%):** Jest liczona względem maksymalnej wartości w bazie.
            * **Kształt:** Im pełniejszy i bardziej regularny wielokąt, tym bogatsza i bardziej zbilansowana dieta.
            """
        )
        
    elif wybrany_klucz == "heatmap":
        st.sidebar.subheader("📊 O tym wykresie")
        st.sidebar.info(
            """
            **Mapa Produktywności (Heatmap)**
            
            Kalendarz pokazujący skuteczność w realizacji celów (dieta + aktywność).
            
            **Jak czytać:**
            * Każdy kwadrat to jeden dzień.
            * **Kolor:** Im jaśniejszy/ intensywniejszy, tym wyższy wynik punktowy (0-100).
            * Pozwala szybko wyłapać "dobre passy" oraz okresy spadku motywacji.
            """
        )

    elif wybrany_klucz == "scatter":
        st.sidebar.subheader("📊 O tym wykresie")
        st.sidebar.info(
            """
            **Kalorie vs aktywność (Scatter Plot)**
            
            Pozwala wybrać dowolne dwie metryki i zobaczyć ich wzajemne zależności.
            """
        )

    elif wybrany_klucz == "prediction":
        st.sidebar.subheader("🤖 O tym algorytmie")
        st.sidebar.info(
            """
            **Predyktor ML (K-Nearest Neighbors)**
            
            Algorytm uczenia maszynowego, który szuka w bazie danych 5 dni najbardziej podobnych do wprowadzonych parametrów.
            
            **Jak to działa?**
            1. Normalizuje dane (skala 0-1).
            2. Traktuje makroskładniki jako współrzędne w 6-wymiarowej przestrzeni.
            3. Mierzy odległość (Euklidesową) między wpisanym dniem a historią.
            """
        )


    if wybrany_klucz == "bar":
        if 'stacked_bar_chart' in globals() or 'stacked_bar_chart' in locals():
            stacked_bar_chart.rysuj(df)
        else:
            st.error("Brak pliku `stacked_bar_chart.py`.")
        
    elif wybrany_klucz == "radar":
        if 'radar_chart' in globals() or 'radar_chart' in locals():
            radar_chart.rysuj(df)
        else:
            st.error("Brak pliku `radar_chart.py`.")

    elif wybrany_klucz == "heatmap":
        if 'heatmap' in globals() or 'heatmap' in locals():
            heatmap.rysuj(df)
        else:
            st.error("Brak pliku `heatmap.py`.")

    elif wybrany_klucz == "scatter":
        if 'scatter_plot' in globals() or 'scatter_plot' in locals():
            scatter_plot.rysuj(df)
        else:
            st.error("Brak pliku `scatter_plot.py`.")

    elif wybrany_klucz == "prediction":
        if 'prediction' in globals() or 'prediction' in locals():
            prediction.rysuj(df)
        else:
            st.error("Brak pliku `prediction.py`.")
    

if __name__ == "__main__":
    main()