import streamlit as st
import plotly.express as px
import pandas as pd

def aggregate_daily(df: pd.DataFrame) -> pd.DataFrame:

    df_agg = df.copy()
    
    agg_rules = {
        "kalorie": "sum",
        "bialko": "sum",
        "tluszcze": "sum",
        "weglowodany": "sum"
    }
    
    if "ilosc_krokow" in df_agg.columns:
        agg_rules["ilosc_krokow"] = "max"
    if "godz_na_ucz" in df_agg.columns:
        agg_rules["godz_na_ucz"] = "max"

    daily = (
        df_agg.groupby(["Osoba", "data"], as_index=False)
          .agg(agg_rules)
          .sort_values(["Osoba", "data"])
    )
    return daily

def rysuj(df):
    st.header("📉 Korelacje: Kalorie vs Aktywność")
    
    df_chart = df.copy()

    df_chart['data'] = pd.to_datetime(df_chart['data'], format='%d.%m.%Y', errors='coerce')
    
    cols_to_fix = ['kalorie', 'bialko', 'tluszcze', 'weglowodany', 'godz_na_ucz', 'ilosc_krokow']
    for col in cols_to_fix:
        if col in df_chart.columns:
            if df_chart[col].dtype == 'object':
                df_chart[col] = df_chart[col].astype(str).str.replace(',', '.').astype(float)
            df_chart[col] = df_chart[col].fillna(0)

    daily_df = aggregate_daily(df_chart)

    column_map = {
        'kalorie': 'Kalorie (suma)',
        'bialko': 'Białko (g)',
        'tluszcze': 'Tłuszcze (g)',
        'weglowodany': 'Węglowodany (g)',
        'ilosc_krokow': 'Kroki (max)',
        'godz_na_ucz': 'Nauka (h)'
    }
    
    available_cols = {k: v for k, v in column_map.items() if k in daily_df.columns}
    reverse_map = {v: k for k, v in available_cols.items()}

    colors_map = {
        'Szymon': "#32A9E0",
        'Zosia':  "#F55757",
        'Hubert': "#40D448"
    }

    with st.container():
        st.subheader("Ustawienia wykresu")
        col1, col2, col3 = st.columns(3)

        with col1:
            dostepne_osoby = list(daily_df['Osoba'].unique())
            wybrane_osoby = st.multiselect(
                "Wybierz osoby:",
                options=dostepne_osoby,
                default=dostepne_osoby
            )

        with col2:
            default_x_key = 'ilosc_krokow' if 'ilosc_krokow' in available_cols else list(available_cols.keys())[0]
            default_x_label = available_cols.get(default_x_key, list(available_cols.values())[0])
            try:
                idx_x = list(reverse_map.keys()).index(default_x_label)
            except ValueError:
                idx_x = 0
            label_x = st.selectbox("Oś X (Pozioma):", list(reverse_map.keys()), index=idx_x)
            col_x = reverse_map[label_x]

        with col3:
            default_y_key = 'kalorie'
            default_y_label = available_cols.get(default_y_key, list(available_cols.values())[0])
            try:
                idx_y = list(reverse_map.keys()).index(default_y_label)
            except ValueError:
                idx_y = 0
            label_y = st.selectbox("Oś Y (Pionowa):", list(reverse_map.keys()), index=idx_y)
            col_y = reverse_map[label_y]

        trend = st.checkbox("Pokaż linię trendu", value=True)

    if not wybrane_osoby:
        st.warning("Musisz wybrać przynajmniej jedną osobę.")
        return

    plot_df = daily_df[daily_df['Osoba'].isin(wybrane_osoby)].copy()
    plot_df = plot_df.dropna(subset=[col_x, col_y])
    plot_df = plot_df[(plot_df[col_x] > 0) & (plot_df[col_y] > 0)]

    if plot_df.empty:
        st.info("Brak danych dla wybranych parametrów.")
        return

    fig = px.scatter(
        plot_df,
        x=col_x,
        y=col_y,
        color="Osoba",
        color_discrete_map=colors_map,
        trendline="ols" if trend else None,
        hover_data=['data'],
        title=f"Zależność: {label_x} vs {label_y}",
        height=600,
        opacity=0.8,
        size_max=15
    )
    
    fig.update_layout(
        xaxis_title=label_x,
        yaxis_title=label_y,
        hovermode="closest"
    )

    st.plotly_chart(fig, use_container_width=True)