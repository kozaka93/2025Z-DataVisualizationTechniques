import streamlit as st
import pandas as pd
import os
import plotly.graph_objects as go
import plotly.express as px

st.set_page_config(
    page_title="Analiza Porównawcza", 
    layout="wide")

st.markdown("""
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap');
        
        html, body, [class*="css"] {
            font-family: 'Inter', sans-serif;
        }

        .stApp {
            background-color: #0E1117;
        }

        h1, h2, h3 {
            color: #ffffff;
            font-weight: 800;
            letter-spacing: -1px;
        }
        
        .glass-container {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 20px;
            padding: 20px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            margin-bottom: 20px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .glass-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.5);
            border-color: rgba(255, 255, 255, 0.15);
        }

        div[data-testid="stMetric"] {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            padding: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }
        div[data-testid="stMetric"]:hover {
            background-color: rgba(255, 255, 255, 0.08);
            transform: scale(1.02);
        }
        div[data-testid="stMetricLabel"] { color: #aaaaaa; font-size: 0.9rem; }
        div[data-testid="stMetricValue"] { color: #ffffff; font-weight: 700; }

        .animate-enter {
            animation: slideInUp 0.8s ease-out;
        }
        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .pers-tag {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            margin: 2px;
            font-weight: 600;
            color: white;
        }
        .tag-blue { background: linear-gradient(90deg, #4b6cb7 0%, #182848 100%); }
        .tag-pink { background: linear-gradient(90deg, #ec008c 0%, #fc6767 100%); }
        .tag-gold { background: linear-gradient(90deg, #FDC830 0%, #F37335 100%); }
        
        .stButton button {
            background: #3B5CCC;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            transition: 0.3s;
        }
        .stButton button:hover {
            background: #3B5CCC;
            box-shadow: 0 0 15px rgba(59, 92, 204, 0.6);
            transform: scale(1.02);
        }
    </style>
""", unsafe_allow_html=True)

DATA_DIR = "dane"
name_map = {"Aleksandra": "ola", "Adam": "adam", "Wiktoria": "wika"}
COLOR_MAP = {"Adam": "#3B5CCC", "Aleksandra": "#8B2252", "Wiktoria": "lightpink"}
DAYS_ORDER = ["poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela"]

with st.sidebar:
    st.header("Konfiguracja")
    st.write("Wybierz osoby do analizy:")
    
    check_adam = st.checkbox("Adam", value=True)
    check_ola = st.checkbox("Aleksandra", value=True)
    check_wika = st.checkbox("Wiktoria", value=True)

selected = []
if check_adam: selected.append("Adam")
if check_ola: selected.append("Aleksandra")
if check_wika: selected.append("Wiktoria")

if selected:
    results = [] 
    daily_sleep_data = [] 
    hourly_data = []
    
    for person in selected:
        suffix = name_map[person]
        path_sleep = os.path.join(DATA_DIR, f"{suffix}_sen.csv")
        path_sentiment = os.path.join(DATA_DIR, f"{suffix}_sentyment.csv")
        
        stats = {"Osoba": person}
        df_s = pd.read_csv(path_sleep)
        df_s["duration"] = pd.to_numeric(df_s["duration"], errors="coerce")
        df_s["date"] = pd.to_datetime(df_s["date"], errors="coerce")
        stats["avg_sleep"] = df_s["duration"].mean()
        if "day" in df_s.columns:
            grp = df_s.groupby("day")["duration"].mean().reindex(DAYS_ORDER)
            for d, v in grp.items():
                if pd.notna(v): daily_sleep_data.append({"Osoba": person, "Dzień": d, "Średni sen": v})

        df_m = pd.read_csv(path_sentiment, sep=";")
        df_m["date"] = pd.to_datetime(df_m["date"], errors="coerce")
        df_m["datetime"] = pd.to_datetime(df_m["datetime"], errors="coerce")
        df_m["sentiment"] = pd.to_numeric(df_m["sentiment"], errors="coerce")
        
        if not df_m.empty:
            num_days = df_m["date"].dt.date.nunique()
            stats["avg_msgs"] = len(df_m) / num_days
            stats["avg_sentiment"] = df_m["sentiment"].mean()

            df_m["hour"] = df_m["datetime"].dt.hour
            hourly_counts = df_m.groupby("hour").size().reset_index(name="count")
            hourly_counts["avg_per_hour"] = hourly_counts["count"] / num_days
            full_hours = pd.DataFrame({"hour": range(24)})
            hourly_counts = full_hours.merge(hourly_counts, on="hour", how="left").fillna(0)
            for _, row in hourly_counts.iterrows():
                hourly_data.append({"Osoba": person, "Godzina": int(row["hour"]), "Aktywność": row["avg_per_hour"]})
        else:
            stats["avg_msgs"] = 0; stats["avg_sentiment"] = 0
            
        results.append(stats)
        
    df = pd.DataFrame(results).set_index("Osoba")
    df["display_sleep"] = df["avg_sleep"].round(2)
    df["display_msgs"] = df["avg_msgs"].round(1)
    df["display_sentiment"] = df["avg_sentiment"].round(3)

    st.markdown('<div class="animate-enter"><h1>Dashboard Porównawczy</h1></div>', unsafe_allow_html=True)
    st.markdown("---")

    st.markdown('<div class="animate-enter"><h3>🏆 Liderzy Statystyk</h3></div>', unsafe_allow_html=True)
    top_s = df["avg_sleep"].idxmax()
    top_m = df["avg_msgs"].idxmax()
    top_h = df["avg_sentiment"].idxmax()
    
    c1, c2, c3 = st.columns(3)
    c1.metric("Czas snu", top_s, f"{df.loc[top_s, 'display_sleep']} h/dobę",delta_color="off")
    c2.metric("Ilość wiadomości", top_m, f"{df.loc[top_m, 'display_msgs']} msg/dzień",delta_color="off")
    c3.metric("Sentyment wiadomości", top_h, f"{df.loc[top_h, 'display_sentiment']} sentyment",delta_color="off")

    st.subheader("Profil członków grupy")
    
    categories = ['Długość Snu', 'Liczba Wiadomości', 'Sentyment']
    fig_r = go.Figure()
    
    for p in df.index:
        vals = [
            df.loc[p,"avg_sleep"] / 9,
            df.loc[p,"avg_msgs"] / df["avg_msgs"].max(),
            df.loc[p,"avg_sentiment"] / 0.5
        ]
        
        real_vals = [
            f"{df.loc[p,'display_sleep']}h",
            f"{df.loc[p,'display_msgs']}",
            f"{df.loc[p,'display_sentiment']}"
        ]
        
        fig_r.add_trace(go.Scatterpolar(
            r=vals,
            theta=categories+[categories[0]],
            fill='toself',
            name=p,
            line_color=COLOR_MAP.get(p),
            hovertext=real_vals+[real_vals[0]],
            hovertemplate="<b>%{data.name}</b><br>%{theta}: %{hovertext}<extra></extra>"))
        
    fig_r.update_layout(
        polar=dict(
            radialaxis=dict(visible=True, range=[0, 1], showticklabels=False, layer="below traces"),
            bgcolor="rgba(0,0,0,0)"),
        showlegend=True,
        height=450,
        template="plotly_dark",
        paper_bgcolor="rgba(0,0,0,0)",
        legend=dict(font=dict(size=14)),
        margin=dict(t=40, b=40))
    st.plotly_chart(fig_r, use_container_width=True)
    
    st.markdown("""
    <div style="font-size: 1.1rem; color: #aaa; margin-top: 10px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;">
        <b>Jak czytać ten wykres?</b><br>
        Wykres pokazuje mocne strony każdej osoby. 
        Im punkt jest bliżej krawędzi zewnętrznej, tym wynik jest wyższy.
        <ul>
            <li><b>Sen:</b> Krawędź = 9h snu</li>
            <li><b>Wiadomości:</b> Krawędź = Maksymalna średnia ilość dziennych wiadomości</li>
            <li><b>Sentyment:</b> Krawędź = 0.5 (umiarkowanie pozytywny)</li>
        </ul>
    </div>
    """, unsafe_allow_html=True)
    
    st.subheader("Szczegółowe Porównanie")
    
    df_chart = df.reset_index()
    c_bar1, c_bar2, c_bar3 = st.columns(3)
    
    def create_bar(y_col, title, suffix):
        fig = px.bar(df_chart, x="Osoba", y=y_col, color="Osoba",
                     color_discrete_map=COLOR_MAP, text=y_col)
        fig.update_layout(
            title=dict(text=title, x=0, font=dict(size=14, color="#ddd")),
            template="plotly_dark", showlegend=False,
            paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
            margin=dict(l=10, r=10, t=40, b=10),
            xaxis=dict(title=None, showgrid=False),
            yaxis=dict(showgrid=True, gridcolor='rgba(255,255,255,0.1)'),
            hovermode = False)
        fig.update_traces(texttemplate='%{text}' + suffix, textposition='outside')
        return fig

    with c_bar1: st.plotly_chart(create_bar("display_sleep", "Średni Sen", " h"))
    with c_bar2: st.plotly_chart(create_bar("display_msgs", "Wiadomości / Dzień", ""))
    with c_bar3: st.plotly_chart(create_bar("display_sentiment", "Sentyment (0-1)", ""))

    col_t1, col_t2 = st.columns(2)
    
    with col_t1:
            st.subheader("Aktywność w ciągu doby")
            df_h = pd.DataFrame(hourly_data)
            df_h = df_h.sort_values(by=["Osoba", "Godzina"])
            
            fig_h = px.line(
                df_h, 
                x="Godzina", 
                y="Aktywność", 
                color="Osoba", 
                color_discrete_map=COLOR_MAP, 
                markers=True)
            
            fig_h.update_layout(
                template="plotly_dark", 
                paper_bgcolor="rgba(0,0,0,0)", 
                plot_bgcolor="rgba(0,0,0,0)",
                legend=dict(orientation="h", y=1.2, font=dict(size=14)), 
                height=400,
                xaxis=dict(showgrid=False, title="Godzina"),
                yaxis=dict(showgrid=True, gridcolor='rgba(255,255,255,0.1)', title="Liczba wiadomości"))
            
            fig_h.update_traces(hovertemplate='%{y}<extra></extra>')
            fig_h.add_vrect(x0=0, x1=6, fillcolor="#104E8B", opacity=0.2, line_width=0)

            st.plotly_chart(fig_h, use_container_width=True)
            
    with col_t2:
        st.subheader("Średni czas snu wg dnia tygodnia")
        df_d = pd.DataFrame(daily_sleep_data)
        df_d["Dzień"] = pd.Categorical(df_d["Dzień"], categories=DAYS_ORDER, ordered=True)
        df_d = df_d.sort_values("Dzień")
        fig_l = px.line(df_d, x="Dzień", y="Średni sen", color="Osoba", color_discrete_map=COLOR_MAP, markers=True)
        fig_l.update_layout(
            template="plotly_dark", paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
            height=400,
            showlegend = False,
            xaxis=dict(showgrid=False),
            yaxis=dict(showgrid=True, gridcolor='rgba(255,255,255,0.1)', range=[0, 10.05]))
        
        fig_l.update_traces(hovertemplate='%{y}<extra></extra>')

        st.plotly_chart(fig_l, use_container_width=True)

    st.dataframe(
        df[["display_sleep", "display_msgs", "display_sentiment"]].rename(columns={
            "display_sleep": "Średni sen", 
            "display_msgs": "Liczba wiadomości", 
            "display_sentiment": "Sentyment"}), use_container_width=True)
else:
    st.info("Zaznacz osoby z menu po lewej stronie, aby rozpocząć analizę.")

st.markdown("---")
if st.button("⬅ Wróć do menu głównego"):
    st.switch_page("3_Analiza_szczegółowa.py")
