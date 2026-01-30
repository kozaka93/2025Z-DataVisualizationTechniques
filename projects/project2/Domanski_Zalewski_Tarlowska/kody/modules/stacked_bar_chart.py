import streamlit as st
import plotly.express as px
import pandas as pd

def rysuj(df):
    """
    Funkcja generująca moduł Huberta: Stacked Bar Chart.
    Przyjmuje DataFrame załadowany w głównym pliku app.py.
    """
    st.header("⛽ Struktura Paliwa - Analiza Spożycia")
    
    # --- 1. PRZYGOTOWANIE DANYCH ---
    df_chart = df.copy()

    # Nowe mapowanie numerów posiłków na nazwy (z Podwieczorkiem)
    mapa_por = {
        1: 'Śniadanie',
        2: 'II Śniadanie',
        3: 'Obiad',
        4: 'Podwieczorek',  # Zmiana z Lunchu na Podwieczorek
        5: 'Kolacja'
    }
    
    # Mapujemy lub upewniamy się, że kolumna istnieje
    # (nadpisujemy jeśli już była, żeby mieć pewność co do nazw)
    df_chart['Nazwa_Pory'] = df_chart['pora_dnia'].map(mapa_por)

    # Konwersja daty
    df_chart['data'] = pd.to_datetime(df_chart['data'], format='%d.%m.%Y', errors='coerce')
    
    # Naprawa liczb (polskie przecinki)
    cols_to_fix = ['kalorie', 'bialko', 'tluszcze', 'weglowodany']
    for col in cols_to_fix:
        if col in df_chart.columns and df_chart[col].dtype == 'object':
            df_chart[col] = df_chart[col].astype(str).str.replace(',', '.').astype(float)

    # Sortowanie chronologiczne
    df_chart = df_chart.sort_values(by=['data', 'pora_dnia'])

    # --- 2. INTERAKCJA (WIDGETY) ---
    col1, col2, col3 = st.columns(3)

    with col1:
        # WYBÓR OSOBY
        if 'Osoba' in df_chart.columns:
            dostepne_osoby = list(df_chart['Osoba'].unique())
            wybrane_osoby = st.multiselect(
                "Wybierz osoby:", 
                options=dostepne_osoby,
                default=dostepne_osoby
            )
            if wybrane_osoby:
                df_chart = df_chart[df_chart['Osoba'].isin(wybrane_osoby)]
            else:
                st.warning("Musisz wybrać przynajmniej jedną osobę.")
                return
        else:
            st.info("Dane dla jednej osoby.")

    with col2:
        # WYBÓR TRYBU WIDOKU
        tryb_widoku = st.selectbox(
            "Wybierz tryb wykresu:",
            ["Pory Posiłków (Kiedy jem?)", "Struktura Kalorii (Co jem?)"]
        )

    with col3:
        # WYBÓR SKŁADNIKA
        if tryb_widoku == "Pory Posiłków (Kiedy jem?)":
            opcje_metryk = {
                "Kalorie (kcal)": "kalorie",
                "Białko (g)": "bialko",
                "Tłuszcze (g)": "tluszcze",
                "Węglowodany (g)": "weglowodany"
            }
            wybrana_etykieta = st.selectbox("Wybierz wartość:", list(opcje_metryk.keys()))
            wybrana_kolumna = opcje_metryk[wybrana_etykieta]
        else:
            st.write("")
            st.markdown("*W tym trybie osią Y są Kalorie.*")

    # --- 3. RYSOWANIE WYKRESÓW ---

    if tryb_widoku == "Pory Posiłków (Kiedy jem?)":
        # === WIDOK 1: STACKED BAR (POSIŁKI) ===
        fig = px.bar(
            df_chart,
            x="data",
            y=wybrana_kolumna,
            color="Nazwa_Pory",
            facet_row="Osoba" if 'Osoba' in df_chart.columns and len(wybrane_osoby) > 1 else None,
            title=f"Rozkład dzienny: {wybrana_etykieta} w podziale na posiłki",
            labels={
                "data": "Data", 
                wybrana_kolumna: wybrana_etykieta, 
                "Nazwa_Pory": "Posiłek"
            },
            color_discrete_sequence=px.colors.qualitative.Prism,
            height=350 + (250 * (len(wybrane_osoby) - 1)) if 'wybrane_osoby' in locals() and len(wybrane_osoby) > 1 else 500
        )
        
        # Formatowanie osi X (daty po polsku)
        fig.update_xaxes(
            tickformat="%d.%m",  # Format: dzień.miesiąc (np. 05.01)
            dtick="D1"           # Pokazuj każdy dzień (jeśli dużo dni, zmień na 'W1' - tydzień)
        )

    else:
        # === WIDOK 2: STACKED BAR (MAKROSKŁADNIKI -> KALORIE) ===
        df_macro = df_chart.copy()
        df_macro['Białko (kcal)'] = df_macro['bialko'] * 4
        df_macro['Tłuszcze (kcal)'] = df_macro['tluszcze'] * 9
        df_macro['Węglowodany (kcal)'] = df_macro['weglowodany'] * 4
        
        cols_to_sum = ['Białko (kcal)', 'Tłuszcze (kcal)', 'Węglowodany (kcal)']
        df_day = df_macro.groupby(['data', 'Osoba'])[cols_to_sum].sum().reset_index()
        
        df_melted = df_day.melt(
            id_vars=['data', 'Osoba'], 
            value_vars=cols_to_sum,
            var_name='Źródło Energii', 
            value_name='Kcal'
        )
        
        fig = px.bar(
            df_melted,
            x="data",
            y="Kcal",
            color="Źródło Energii",
            facet_row="Osoba" if 'Osoba' in df_chart.columns and len(wybrane_osoby) > 1 else None,
            title="Struktura Kaloryczna Dnia (Źródło Energii)",
            labels={"data": "Data", "Kcal": "Kalorie (kcal)"},
            color_discrete_map={
                "Białko (kcal)": "#3366CC", 
                "Tłuszcze (kcal)": "#FF9900", 
                "Węglowodany (kcal)": "#109618"
            },
            height=350 + (250 * (len(wybrane_osoby) - 1)) if 'wybrane_osoby' in locals() and len(wybrane_osoby) > 1 else 500
        )
        
        fig.update_xaxes(
            tickformat="%d.%m",
            dtick="D1"
        )

    # --- WSPÓLNA KOSMETYKA WYKRESU ---
    fig.update_layout(
        autosize=True,
        bargap=0.1, 
        hovermode="x unified",
        # Powiększenie czcionek
        font=dict(size=20),
        title_font=dict(size=20),
        legend_title_font=dict(size=16),
        xaxis_title_font=dict(size=16),
        yaxis_title_font=dict(size=16)
    )
    
    # Usunięcie prefiksu "Osoba=" z etykiet paneli (facet row annotations)
    fig.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
    
    # Niezależne osie Y (żeby mały i duży jedzący wyglądali dobrze)
    fig.update_yaxes(matches=None)
    
    st.plotly_chart(fig, use_container_width=True)