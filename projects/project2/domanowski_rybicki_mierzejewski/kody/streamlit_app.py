import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np

st.set_page_config(page_title="Dashboard", page_icon="X", layout="wide", initial_sidebar_state="expanded")

with open('kody/styles.css', 'r') as f:
    st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)

THEME = {
    "colors": ['#00FFFF', '#FF00FF', '#00FF00', '#f59e0b', '#8b5cf6'],
    "bg": '#1a1a1a', "grid": 'rgba(255, 255, 255, 0.05)', "paper_bg": 'rgba(0,0,0,0)'
}
LEGEND_STYLE = dict(bgcolor='rgba(26,26,26,0.8)', bordercolor='#2a2a2a', borderwidth=1, font=dict(color='#cccccc'))

@st.cache_data
def load_data():
    df = pd.read_csv('kody/dane_grudzien_2025.csv')
    df['Data'] = pd.to_datetime(df['Data'])
    df['Srednie_Samopoczucie'] = (df['Samopoczucie_Rano'] + df['Samopoczucie_Popoludnie'] + df['Samopoczucie_Wieczor']) / 3
    return df

df = load_data()
ALL_PERSONS = df['Osoba'].unique().tolist()
MIN_DATE, MAX_DATE = df['Data'].min().date(), df['Data'].max().date()

def divider():
    st.markdown('<div class="divider"></div>', unsafe_allow_html=True)

def apply_chart_layout(fig, height=400, y_range=None, x_title='', y_title='', show_legend=True):
    layout = dict(
        paper_bgcolor=THEME['paper_bg'], plot_bgcolor=THEME['bg'], font=dict(color='#888888'),
        xaxis=dict(gridcolor=THEME['grid'], showgrid=True, title=x_title),
        yaxis=dict(gridcolor=THEME['grid'], showgrid=True, title=y_title, range=y_range),
        margin=dict(l=0, r=0, t=20, b=0), height=height, showlegend=show_legend
    )
    if show_legend:
        layout['legend'] = LEGEND_STYLE
    fig.update_layout(**layout)
    return fig

def get_color_map():
    return {p: THEME['colors'][i] for i, p in enumerate(ALL_PERSONS)}

def hex_to_rgba(hex_color, alpha=0.3):
    hex_color = hex_color.lstrip('#')
    r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    return f'rgba({r}, {g}, {b}, {alpha})'

                                                             
ACTIVITY_COLORS = {
    'Projekt': '#FF9999',                  
    'Praca': '#FFB366',                       
    'Zakupy': '#FFDD99',                      
    'Rozrywka': '#99DDFF',                  
    'Relaks': '#C4B5FD',                      
    'Sport': '#86EFAC',                      
    'Swieta': '#FBCFE8'                     
}

def calc_delta(value, baseline, suffix='', invert=False):
    diff = value - baseline
    return f"+{diff:.1f}{suffix}" if diff > 0 else f"{diff:.1f}{suffix}"

def render_metric(label, value, baseline, suffix='', invert=False):
    delta = calc_delta(value, baseline, suffix, invert)
    st.metric(label=label, value=f"{value:.1f}{suffix}", delta=delta, delta_color="inverse" if invert else "normal", help=f"Wartość optymalna: {baseline}{suffix}")

def render_filters(page_key, show_date_highlight=False, show_trendline=False):
    cols = st.columns([2, 2, 1] if show_trendline else [2, 2, 1])
    with cols[0]:
        persons = st.multiselect("Wybierz osoby", options=ALL_PERSONS, default=ALL_PERSONS, key=f"persons_{page_key}")
    with cols[1]:
        label = "Podświetl zakres dat" if show_date_highlight else "Zakres dat"
        dates = st.slider(label, min_value=MIN_DATE, max_value=MAX_DATE, value=(MIN_DATE, MAX_DATE), format="DD/MM", key=f"dates_{page_key}")
    if show_trendline:
        with cols[2]:
            trend = st.checkbox("Linia trendu", value=False, key=f"trend_{page_key}")
        return persons, dates, trend
    return persons, dates

def filter_df(persons, date_range):
    return df[(df['Osoba'].isin(persons)) & (df['Data'].dt.date >= date_range[0]) & (df['Data'].dt.date <= date_range[1])]

def add_trendline(fig, x_data, y_data, name='Trend', color='rgba(255,255,255,0.6)'):
    if len(x_data) >= 2:
        z = np.polyfit(x_data, y_data, 1)
        p = np.poly1d(z)
        x_trend = np.linspace(x_data.min(), x_data.max(), 50)
        fig.add_trace(go.Scatter(x=x_trend, y=p(x_trend), mode='lines', name=name, line=dict(color=color, dash='dash', width=2), opacity=0.5))

page = st.radio("Nawigacja", ["Przegląd", "Statystyki", "Samopoczucie", "Sen", "Aktywności"], horizontal=True, label_visibility="collapsed")
divider()

PAGE_HEADERS = {
    "Przegląd": ("# Grudzień Studneta IADu", "*Troje studentów IADu postanowiło udowodnić, że można analizować własne życie równie dokładnie jak datasety na zajęciach. Dzięki temu mamy wgląd w to jak spędzaliśmy czas i co można w naszym życiu poprawić.*"),
    "Statystyki": ("# Statystyki indywidualne", "*Kto śpi najdłużej? Kto ma najwięcej screen time'u? Jak wypadamy na tle innych? Dane mówią same za siebie.*"),
    "Samopoczucie": ("# Samopoczucie", "Bartek twiedzi, że jego samopoczucie rośnie wraz z ilością gum kofeinowych od Ani Lewandowskiej. Krzysiek to trup rano, ale wieczorem ożywa. Julek? Zawsze zadowolony."),
    "Sen": ("# Sen", "*Krzysiek odkrył, że 12h przed ekranem to prosta droga do bezsennych nocy. Bartek mówi, że to normalne dla studenta IADu. Julek ma 3h screen time i śpi jak niemowlę.*"),
    "Aktywności": ("# Aktywności", "*Projekty i nauka = maksymalny stres. Hobby i inne = minimum stresu. Święta? To kompletny spokój dla wszystkich.*")
}

if page == "Przegląd":
    st.markdown(PAGE_HEADERS[page][0])
    st.markdown(PAGE_HEADERS[page][1])
    divider()
    
    selected_persons, date_range = render_filters(page)
    filtered_df = filter_df(selected_persons, date_range)
    
    if filtered_df.empty:
        st.warning("Brak danych dla wybranych filtrów.")
    else:
        st.markdown("### Kluczowe Wskaźniki")
        st.caption("Średnie wartości kluczowych wskaźników dla aktualnie wybranych filtrów. Przyjęliśmy, że optymalny sen to 7h, optymalny screen time to 6h, optymalny stres to 5/10, a optymalne samopoczucie to 5/10")
        
        col1, col2, col3, col4 = st.columns(4)
        with col1: render_metric("SAMOPOCZUCIE", filtered_df['Srednie_Samopoczucie'].mean(), 5)
        with col2: render_metric("SEN", filtered_df['Dlugosc_snu_h'].mean(), 7, 'h')
        with col3: render_metric("STRES", filtered_df['Poziom_stresu_1_10'].mean(), 5, invert=True)
        with col4: render_metric("SCREEN TIME", filtered_df['Screen_Time_h'].mean(), 6, 'h', invert=True)
        
        st.markdown(""); st.markdown("")
        col_left, col_right = st.columns(2)
        
        with col_left:
            st.markdown("### Kalendarz Nastrojów")
            st.caption("Mapa cieplna nastroju: Im bardziej różowo, tym gorsze samopoczucie. Im bardziej jasno, tym lepsze samopoczucie.")
            
                                      
            heatmap_data = df[df['Osoba'].isin(selected_persons)].copy()
            heatmap_data['Day'] = heatmap_data['Data'].dt.day
            heatmap_data['DateLabel'] = heatmap_data['Data'].dt.strftime('%d.%m.%Y')
            
            start_day = date_range[0].day
            end_day = date_range[1].day
            heatmap_data.loc[~((heatmap_data['Day'] >= start_day) & (heatmap_data['Day'] <= end_day)), 'Srednie_Samopoczucie'] = np.nan
            
                                                     
            heatmap_matrix = heatmap_data.pivot_table(index='Osoba', columns='Day', values='Srednie_Samopoczucie', aggfunc='mean')
            heatmap_matrix = heatmap_matrix.reindex(columns=range(1, 32))
            
            date_labels = [f"{d}.12.2025" for d in range(1, 32)]
            
            fig = px.imshow(
                heatmap_matrix,
                labels=dict(x="Data", y="Osoba", color="Samopoczucie"),
                x=date_labels,
                y=heatmap_matrix.index,
                color_continuous_scale=[[0, '#c51b8a'], [0.5, '#fa9fb5'], [1, '#fde0dd']],
                range_color=[1, 10],
                aspect="auto"
            )
            fig.update_traces(xgap=1, ygap=1)
            fig.update_layout(
                margin=dict(t=0, l=0, r=0, b=0),
                xaxis=dict(tickangle=45, tickmode='array', tickvals=[f"{d}.12.2025" for d in range(1, 32, 5)])
            )
            st.plotly_chart(apply_chart_layout(fig, height=300, x_title='Data', y_title='Osoba', show_legend=False), use_container_width=True)
        
        with col_right:
            st.markdown("### Aktywność a Stres")
            st.caption("Aktywności według średniego poziomu stresu. Zawsze ładnie uszeregowane, by wnioski nasuwały się same.")
            
                                                       
            all_activities = df['Glowna_aktywnosc'].unique()
            activity_data = filtered_df.groupby('Glowna_aktywnosc')['Poziom_stresu_1_10'].mean().reindex(all_activities, fill_value=0).reset_index()
            activity_data = activity_data.sort_values('Poziom_stresu_1_10')
            
            fig = px.bar(activity_data, x='Poziom_stresu_1_10', y='Glowna_aktywnosc', orientation='h', color='Glowna_aktywnosc', color_discrete_map=ACTIVITY_COLORS, template='plotly_dark')
            fig.update_layout(showlegend=False, xaxis=dict(range=[0, 10]))
            st.plotly_chart(apply_chart_layout(fig, height=300, x_title='Średni stres', y_title='Aktywność', show_legend=False), use_container_width=True)

elif page == "Statystyki":
    st.markdown(PAGE_HEADERS[page][0])
    st.markdown(PAGE_HEADERS[page][1])
    divider()
    
    selected_persons, date_range = render_filters(page)
    filtered_df = filter_df(selected_persons, date_range)
    
    if filtered_df.empty or len(selected_persons) == 0:
        st.warning("Wybierz przynajmniej jedną osobę.")
    else:
                                
        categories = ['Samopoczucie', 'Sen', 'Jakość snu', 'Stres', 'Screen Time']
        
        st.markdown("### Holistyczne spojrzenie na metryki")
        st.caption("Porównanie naszych metryk. Dzięki temu jak wyglądają wykresy możemy łatwo wywnioskować nasze problemy lub mocne strony.")
        fig_radar = go.Figure()
        
        for idx, person in enumerate(selected_persons):
            person_df = filtered_df[filtered_df['Osoba'] == person]
            if not person_df.empty:
                                                            
                samopoczucie = person_df['Srednie_Samopoczucie'].mean()
                sen = min(person_df['Dlugosc_snu_h'].mean() / 10 * 10, 10)                                 
                jakosc_snu = person_df['Jakosc_snu_1_10'].mean()
                stres = person_df['Poziom_stresu_1_10'].mean()                       
                screen_time = min(person_df['Screen_Time_h'].mean(), 10)                       
                
                values = [samopoczucie, sen, jakosc_snu, stres, screen_time]
                values.append(values[0])                     
                
                color = get_color_map()[person]
                
                fig_radar.add_trace(go.Scatterpolar(
                    r=values,
                    theta=categories + [categories[0]],
                    fill='toself',
                    fillcolor=color.replace(')', ', 0.15)').replace('rgb', 'rgba') if 'rgb' in color else f'rgba{tuple(list(int(color.lstrip("#")[i:i+2], 16) for i in (0, 2, 4)) + [0.15])}',
                    name=person,
                    line=dict(color=color, width=3),
                    marker=dict(size=8, color=color)
                ))
        
        fig_radar.update_layout(
            polar=dict(
                radialaxis=dict(
                    visible=True,
                    range=[0, 10],
                    gridcolor='rgba(255, 255, 255, 0.1)',
                    linecolor='rgba(255, 255, 255, 0.2)',
                    tickfont=dict(color='#888888', size=10),
                ),
                angularaxis=dict(
                    gridcolor='rgba(255, 255, 255, 0.1)',
                    linecolor='rgba(255, 255, 255, 0.2)',
                    tickfont=dict(color='#cccccc', size=14),
                ),
                bgcolor=THEME['bg']
            ),
            paper_bgcolor=THEME['paper_bg'],
            font=dict(color='#888888'),
            showlegend=True,
            legend=LEGEND_STYLE,
            height=550,
            margin=dict(l=80, r=80, t=40, b=40)
        )
        
        st.plotly_chart(fig_radar, use_container_width=True)
        
        st.markdown(""); divider(); st.markdown("")
        
                                                          
        st.markdown("### Porównanie średnich metryk")
        st.caption("To inne spojrzenie na wyniki, również maksymalnie obrazowo.")
        
        metrics_data = []
        for person in selected_persons:
            person_df = filtered_df[filtered_df['Osoba'] == person]
            if not person_df.empty:
                metrics_data.append({
                    'Osoba': person,
                    'Sen (h)': person_df['Dlugosc_snu_h'].mean(),
                    'Jakość snu': person_df['Jakosc_snu_1_10'].mean(),
                    'Samopoczucie': person_df['Srednie_Samopoczucie'].mean(),
                    'Screen Time (h)': person_df['Screen_Time_h'].mean(),
                    'Stres': person_df['Poziom_stresu_1_10'].mean()
                })
        
        if metrics_data:
            metrics_df = pd.DataFrame(metrics_data)
            metrics_melted = metrics_df.melt(id_vars=['Osoba'], var_name='Metryka', value_name='Wartość')
            
            fig_bars = px.bar(
                metrics_melted, 
                x='Metryka', 
                y='Wartość', 
                color='Osoba',
                barmode='group',
                color_discrete_map=get_color_map(),
                template='plotly_dark'
            )
            fig_bars.update_traces(texttemplate='%{y:.1f}', textposition='outside', textfont_size=10)
            st.plotly_chart(apply_chart_layout(fig_bars, height=400, y_range=[0, 11], x_title='Metryka', y_title='Średnia wartość'), use_container_width=True)

elif page == "Samopoczucie":
    st.markdown(PAGE_HEADERS[page][0])
    st.markdown(PAGE_HEADERS[page][1])
    divider()
    
    selected_persons, date_range = render_filters(page, show_date_highlight=True)
    person_filtered_df = df[df['Osoba'].isin(selected_persons)]
    
    if person_filtered_df.empty:
        st.warning("Wybierz przynajmniej jedną osobę.")
    else:
        st.markdown("### Nasze samopoczucie na przestrzeni czasu")
        st.caption("Tutaj łatwo zaobserwować jak zmieniało się nasze samopoczucie w czasie.")
        fig = go.Figure()
        for person in selected_persons:
            person_data = person_filtered_df[person_filtered_df['Osoba'] == person].sort_values('Data')
            color = get_color_map()[person]
            
                                  
            fig.add_trace(go.Scatter(x=person_data['Data'], y=person_data['Srednie_Samopoczucie'], mode='lines+markers', name=person, line=dict(color=color, width=3), marker=dict(size=10)))
        
                                                    
        fig.add_vrect(x0=pd.Timestamp(date_range[0]), x1=pd.Timestamp(date_range[1]), fillcolor="rgba(255, 255, 255, 0.05)", layer="below", line_width=0)
        
                                              
        fig.add_vrect(x0=pd.Timestamp('2025-12-01'), x1=pd.Timestamp(date_range[0]), fillcolor="rgba(0, 0, 0, 0.7)", layer="above", line_width=0)
        fig.add_vrect(x0=pd.Timestamp(date_range[1]), x1=pd.Timestamp('2025-12-31'), fillcolor="rgba(0, 0, 0, 0.7)", layer="above", line_width=0)
        
                                            
        fig.update_layout(xaxis=dict(range=[pd.Timestamp('2025-12-01'), pd.Timestamp('2025-12-31')]), hovermode='x unified')
        st.plotly_chart(apply_chart_layout(fig, height=500, y_range=[0, 10.5], y_title='Średnie samopoczucie (1-10)'), use_container_width=True)
        
        st.markdown(""); divider(); st.markdown("")
        st.markdown("## Samopoczucie w zależności od pory dnia")
        st.caption("Tutaj zobaczymy jak zmieniało się nasze samopoczucie w zależności od pory dnia.")
        
        df_melted = person_filtered_df.melt(id_vars=['Data', 'Osoba'], value_vars=['Samopoczucie_Rano', 'Samopoczucie_Popoludnie', 'Samopoczucie_Wieczor'], var_name='Pora_Dnia', value_name='Ocena')
        df_melted['Pora_Dnia'] = df_melted['Pora_Dnia'].str.replace('Samopoczucie_', '')
        df_melted_filtered = df_melted[(df_melted['Data'].dt.date >= date_range[0]) & (df_melted['Data'].dt.date <= date_range[1])]
        
        if not df_melted_filtered.empty:
            pora_labels = {'Rano': 'Rano', 'Popoludnie': 'Południe', 'Wieczor': 'Wieczór'}
            
            df_melted_filtered = df_melted_filtered.copy()
            df_melted_filtered['Pora_Label'] = df_melted_filtered['Pora_Dnia'].map(pora_labels)
            
            fig_violin = go.Figure()
            
            for person in selected_persons:
                person_data = df_melted_filtered[df_melted_filtered['Osoba'] == person]
                color = get_color_map()[person]
                
                fig_violin.add_trace(go.Violin(
                    x=person_data['Pora_Label'],
                    y=person_data['Ocena'],
                    name=person,
                    line=dict(color=color, width=2),
                    fillcolor=hex_to_rgba(color, 0.5),
                    box_visible=True,
                    meanline_visible=True,
                    points=False
                ))
            
            fig_violin.update_layout(violinmode='group')
            st.plotly_chart(apply_chart_layout(fig_violin, height=500, y_range=[-2, 14], y_title='Ocena samopoczucia'), use_container_width=True)

elif page == "Sen":
    st.markdown(PAGE_HEADERS[page][0])
    st.markdown(PAGE_HEADERS[page][1])
    divider()
    
    selected_persons, date_range, show_trendline = render_filters(page, show_trendline=True)
    filtered_df = filter_df(selected_persons, date_range)
    
    if filtered_df.empty:
        st.warning("Brak danych dla wybranych filtrów.")
    else:
        st.markdown("### Sen a screen time")
        st.caption("Relacja między czasem przed ekranem a jakością snu. Bez większych odkryć. Im więcej czasu przed ekranem, tym gorsza jakość snu.")
        fig = px.scatter(filtered_df, x='Screen_Time_h', y='Jakosc_snu_1_10', color='Osoba', size='Poziom_stresu_1_10', color_discrete_map=get_color_map(), template='plotly_dark', opacity=0.8)
        if show_trendline:
            add_trendline(fig, filtered_df['Screen_Time_h'], filtered_df['Jakosc_snu_1_10'])
        fig.update_layout(xaxis=dict(range=[0, 13]))
        st.plotly_chart(apply_chart_layout(fig, height=500, y_range=[0, 10.5], x_title='Screen Time (godziny)', y_title='Jakość snu (1-10)'), use_container_width=True)
        
        st.markdown(""); divider(); st.markdown("")
        st.markdown("## Długość snu w czasie")
        st.caption("Ten wykres bardzo ładnie pokazuje jak zmieniała się długość snu w poszczególnych dniach,w odniesieniu do zalecanych norm (linie przerywane). Dzięki temu widzimym, czy nasz sen jest regenerujący i czy odpoczywamy tyle ile powinniśmy.")
        
                                                                       
        person_filtered_df = df[df['Osoba'].isin(selected_persons)]
        
        fig_sleep = go.Figure()
        for person in selected_persons:
            person_data = person_filtered_df[person_filtered_df['Osoba'] == person].sort_values('Data')
            color = get_color_map()[person]
            
                                  
            fig_sleep.add_trace(go.Scatter(
                x=person_data['Data'],
                y=person_data['Dlugosc_snu_h'],
                mode='lines+markers',
                name=person,
                line=dict(color=color, width=3),
                marker=dict(size=10)
            ))
        
                                                    
        fig_sleep.add_vrect(x0=pd.Timestamp(date_range[0]), x1=pd.Timestamp(date_range[1]), fillcolor="rgba(255, 255, 255, 0.05)", layer="below", line_width=0)
        
                                              
        fig_sleep.add_vrect(x0=pd.Timestamp('2025-12-01'), x1=pd.Timestamp(date_range[0]), fillcolor="rgba(0, 0, 0, 0.7)", layer="above", line_width=0)
        fig_sleep.add_vrect(x0=pd.Timestamp(date_range[1]), x1=pd.Timestamp('2025-12-31'), fillcolor="rgba(0, 0, 0, 0.7)", layer="above", line_width=0)
        
                                                   
        fig_sleep.add_hline(y=7, line_dash="dash", line_color="rgba(255,255,255,0.3)", annotation_text="7h min.")
        fig_sleep.add_hline(y=8, line_dash="dash", line_color="rgba(255,255,255,0.3)", annotation_text="8h zalecane")
        
                                            
        fig_sleep.update_layout(xaxis=dict(range=[pd.Timestamp('2025-12-01'), pd.Timestamp('2025-12-31')], tickformat='%d.%m.%Y'))
        
        st.plotly_chart(apply_chart_layout(fig_sleep, height=400, y_range=[3, 12], x_title='Data', y_title='Godziny snu'), use_container_width=True)

elif page == "Aktywności":
    st.markdown(PAGE_HEADERS[page][0])
    st.markdown(PAGE_HEADERS[page][1])
    divider()
    
    selected_persons, date_range = render_filters(page)
    filtered_df = filter_df(selected_persons, date_range)
    
    if filtered_df.empty:
        st.warning("Brak danych dla wybranych filtrów.")
    else:
        st.markdown("### Rozkład Stresu według Aktywności")
        st.caption("Szczegółowy rozkład poziomu stresu dla poszczególnych aktywności. Wnioski są ponownie proste do przewidzenia, lecz utwierdza nas to w przekonaniu, że warto regularnie uprawiać sport i dobrze się regenerować.")
                                                                                   
                                                                                               
        activity_order = df.groupby('Glowna_aktywnosc')['Poziom_stresu_1_10'].median().sort_values(ascending=False).index.tolist()
        
                                                                                                  
        fig = px.box(filtered_df, x='Glowna_aktywnosc', y='Poziom_stresu_1_10', color='Glowna_aktywnosc', color_discrete_map=ACTIVITY_COLORS, template='plotly_dark', category_orders={'Glowna_aktywnosc': activity_order})
        
                                                                                       
                                                                         
        fig.update_xaxes(
            categoryorder='array', 
            categoryarray=activity_order, 
            tickangle=0,
            range=[-0.5, len(activity_order) - 0.5]
        )
        
        st.plotly_chart(apply_chart_layout(fig, height=500, y_range=[0, 10.5], x_title='Aktywność', y_title='Poziom stresu (1-10)', show_legend=False), use_container_width=True)
        
        st.markdown(""); divider(); st.markdown("")
        st.markdown("## Liczba dni z daną aktywnością")
        st.caption("Tutaj widzimy podsumowanie ile dni spędziliśmy na danej aktywności w analizowanym okresie.")
        
                                                     
                                                            
        all_activities = df['Glowna_aktywnosc'].unique()
        activity_counts = filtered_df.groupby('Glowna_aktywnosc').size().reindex(all_activities, fill_value=0).reset_index(name='Liczba')
        activity_counts = activity_counts.sort_values('Liczba', ascending=True)
        
        fig_bar = px.bar(
            activity_counts,
            x='Liczba',
            y='Glowna_aktywnosc',
            orientation='h',
            color='Glowna_aktywnosc',
            color_discrete_map=ACTIVITY_COLORS,
            template='plotly_dark'
        )
        fig_bar.update_traces(texttemplate='%{x}', textposition='outside', textfont_size=12)
        
                                                                                         
        global_max = df.groupby('Glowna_aktywnosc').size().max()
        fig_bar.update_layout(showlegend=False, xaxis=dict(range=[0, global_max + 2]))
        st.plotly_chart(apply_chart_layout(fig_bar, height=400, x_title='Liczba dni', y_title='Aktywność', show_legend=False), use_container_width=True)
