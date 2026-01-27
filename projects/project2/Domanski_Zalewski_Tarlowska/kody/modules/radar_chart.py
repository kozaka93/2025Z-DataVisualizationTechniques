import streamlit as st
import pandas as pd
import plotly.graph_objects as go

def rysuj(df):
    st.header("🌐 Wykres Radarowy - Analiza Makroskładników")

    df_chart = df.copy()

    cols_to_fix = ['bialko', 'tluszcze', 'weglowodany', 'cukry', 'blonnik', 'sol']
    for col in cols_to_fix:
        if col in df_chart.columns and df_chart[col].dtype == 'object':
            df_chart[col] = df_chart[col].astype(str).str.replace(',', '.').astype(float)
    
    for col in cols_to_fix:
        if col not in df_chart.columns:
            df_chart[col] = 0

    df_chart['data'] = pd.to_datetime(df_chart['data'], format='%d.%m.%Y', errors='coerce')

    col1, col2 = st.columns(2)

    with col1:
        dostepne_osoby = list(df_chart['Osoba'].unique()) if 'Osoba' in df_chart.columns else []
        selected_people = st.multiselect(
            "Wybierz osoby:",
            options=dostepne_osoby,
            default=dostepne_osoby
        )

    with col2:
        min_date = df_chart['data'].min().date()
        max_date = df_chart['data'].max().date()
        
        date_range = st.date_input(
            "Wybierz zakres dat:",
            value=(min_date, max_date),
            min_value=min_date,
            max_value=max_date
        )

    if not selected_people:
        st.warning("Wybierz przynajmniej jedną osobę.")
        return
    
    if len(date_range) != 2:
        st.info("Wybierz pełny zakres dat (od - do).")
        return

    start_date, end_date = pd.to_datetime(date_range[0]), pd.to_datetime(date_range[1])

    categories = cols_to_fix
    labels_map = {
        'bialko': 'Białko', 
        'tluszcze': 'Tłuszcze', 
        'weglowodany': 'Węgle', 
        'cukry': 'Cukry', 
        'blonnik': 'Błonnik', 
        'sol': 'Sól'
    }
    labels = [labels_map[c] for c in categories]


    colors_map = {
        'Szymon': "#32A9E0",
        'Zosia':  "#F55757",
        'Hubert': "#40D448",
        'Inny':   '#BA68C8'
    }
    
    max_values = {}
    for cat in categories:
        daily_sums = df_chart.groupby(['data', 'Osoba'])[cat].sum()
        max_val = daily_sums.max()
        max_values[cat] = max_val if max_val > 0 else 1

    labels_with_scales = []
    for i in range(len(categories)):
        category = categories[i]
        max_value = max_values[category]
        new_label = f"<b>{labels[i]}</b><br><span style='font-size:13px; color:#a0a0a0'>Max: {max_value:.0f}g</span>"
        labels_with_scales.append(new_label)

    fig = go.Figure()

    for person in selected_people:
        person_df = df_chart[
            (df_chart['Osoba'] == person) & 
            (df_chart['data'] >= start_date) & 
            (df_chart['data'] <= end_date)
        ]

        if not person_df.empty:
            daily_totals = person_df.groupby('data')[categories].sum()
            avg_values = daily_totals.mean()

            scaled_values = [(avg_values[cat] / max_values[cat]) * 100 for cat in categories]
            
            hover_text = [f"{labels[i]}: {avg_values[categories[i]]:.1f}g" for i in range(len(categories))]

            r_vec = scaled_values + [scaled_values[0]]
            theta_vec = labels_with_scales + [labels_with_scales[0]]
            hover_vec = hover_text + [hover_text[0]]
            
            color = colors_map.get(person, '#B0BEC5')

            fig.add_trace(go.Scatterpolar(
                r=r_vec,
                theta=theta_vec,
                fill='toself',
                name=person,
                text=hover_vec,
                hoverinfo='name+text',
                fillcolor=f"rgba{tuple(int(color.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (0.3,)}",
                line=dict(color=color, width=3)
            ))

    fig.update_layout(
        height=650,
        margin=dict(l=110, r=110, t=60, b=40),
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        
        polar=dict(
            bgcolor="rgba(255, 255, 255, 0.05)", 
            
            radialaxis=dict(
                visible=True,
                range=[0, 100],
                ticksuffix="%",
                gridcolor="#444444",
                showline=False,
                tickfont=dict(size=16, color="#888888"),
            ),
            angularaxis=dict(
                gridcolor="#444444",
                linecolor="#666666",
                tickfont=dict(size=18, color="#E0E0E0"),
                ticks="outside",
                ticklen=25,
                tickcolor="rgba(0,0,0,0)"
            )
        ),
        showlegend=True,
        legend=dict(
            font=dict(size=14, color="#E0E0E0"),
            orientation="h",
            yanchor="bottom",
            y=1.05,
            xanchor="center",
            x=0.5,
            bgcolor="rgba(0,0,0,0)"
        ),
        hoverlabel=dict(
            bgcolor="black",
            bordercolor="#333333",
            font=dict(
                color="white",
                size=14
            ),
            namelength=-1
        ),
        title={
            'text': f"Średnie spożycie makroskładników",
            'y': 1.0,
            'x': 0.5,
            'xanchor': 'center',
            'font': dict(size=20, color="white")
        }
    )

    st.plotly_chart(fig, use_container_width=True)