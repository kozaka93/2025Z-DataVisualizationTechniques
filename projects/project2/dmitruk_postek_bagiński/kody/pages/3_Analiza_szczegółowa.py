import streamlit as st
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from matplotlib.colors import LinearSegmentedColormap
from wordcloud import WordCloud


st.set_page_config(page_title="Sleep, Mood & Messages", layout="wide")
st.markdown("""
    <style>
            
    div[data-baseweb="tab-list"] {
        gap: 20px;
    }
    div[data-baseweb="tab-highlight"] {
        background-color: #8B2252 !important;
    }
    button[data-baseweb="tab"][aria-selected="true"] {
        color: #8B2252 !important;
    }

    span[data-baseweb="tag"] {
        background-color: #8B2252 !important;
        color: white !important;
    }
    
    div[data-baseweb="select"] > div:focus-within {
        border-color: #8B2252 !important;
    }
            
    .animate-enter {
        animation: slideInUp 0.8s ease-out;
    }
    @keyframes slideInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    div[data-baseweb="radio"] div[role="radiogroup"] div[aria-checked="true"] {
        background-color: #8B2252 !important;
    }
            
    button[data-baseweb="tab"]:hover {
        color: lightpink !important;
    }
    </style>
    """, unsafe_allow_html=True)


DATA_DIR = "dane"

PLOTLY_LAYOUT = dict(
    template="plotly_dark",
    paper_bgcolor="rgba(0,0,0,0)",
    plot_bgcolor="rgba(0,0,0,0)",
    margin=dict(l=50, r=40, t=70, b=50),
    font=dict(size=13),
    hovermode="x unified",
    xaxis=dict(showgrid=False),
    yaxis=dict(gridcolor="rgba(255,255,255,0.08)", zeroline=False)
)

st.sidebar.title("Ustawienia")
selected_person = st.sidebar.selectbox("Wybierz osobę:", ["Aleksandra", "Adam", "Wiktoria"])

name_map = {
    "Aleksandra": "ola",
    "Adam": "adam",
    "Wiktoria": "wika"
}
file_suffix = name_map[selected_person]


PATH_SLEEP = os.path.join(DATA_DIR, f"{file_suffix}_sen.csv")
PATH_SENTIMENT = os.path.join(DATA_DIR, f"{file_suffix}_sentyment.csv")
PATH_SPOTIFY_HIST = os.path.join(DATA_DIR, f"{file_suffix}_muzyka.csv")
PATH_SPOTIFY_EMP = os.path.join(DATA_DIR, f"{file_suffix}_muzyka_bez.csv")



st.title(f"Oglądasz wykresy dla: {selected_person}")
st.markdown("---")

tab1, tab2, tab3 = st.tabs(["Muzyka a sen","Analiza snu","Przegląd wiadomości"])

with tab1:
    if os.path.exists(PATH_SLEEP) and os.path.exists(PATH_SPOTIFY_HIST) and os.path.exists(PATH_SPOTIFY_EMP):

        sen = pd.read_csv(PATH_SLEEP, header = 0, sep = ",")
        muzyka = pd.read_csv(PATH_SPOTIFY_HIST, sep = ";")
        muzyka_emp = pd.read_csv(PATH_SPOTIFY_EMP, sep = ";")

        muzyka.date = pd.to_datetime(muzyka.date) 
        sen =  sen.loc[(sen['date'] >= '2025-11-17') & (sen['date'] <= '2026-01-10')]
        sen.date = pd.to_datetime(sen.date)
        energy = muzyka.groupby("date")[["energy","liveness","danceability","valence"]].mean().reset_index()
        energy["date"] = pd.to_datetime(energy["date"])
        start_time = energy['date'].tolist()[0]
        end_time = energy['date'].tolist()[-1]

        time_list = pd.date_range(start_time, end_time, freq='1d')
        energy = energy.set_index('date').reindex(time_list)
        energy = energy.interpolate(method="linear").reset_index(names="date")

        to_plot = pd.merge(sen, energy, on = "date", how='left')

        st.markdown('<div class="animate-enter"><h2>Czy metryki słuchanej przez nas muzyki zależały od tego ile spaliśmy?</h1></div>', unsafe_allow_html=True)
        metrics_available = ["energy","liveness","valence","danceability"]

        name_map = {
            "energy": "Energia",
            "liveness": "Żywiołowość",
            "valence": "Wesołość",
            "danceability": "Taneczność"
        }

        reverse_map = {v: k for k, v in name_map.items()}
    
        selected_metrics = st.multiselect(
            "Wybierz metryki muzyczne:",
            options=list(name_map.values()), 
            default=["Energia"]
        ) 

        fig = make_subplots(specs=[[{"secondary_y": True}]])

        fig.add_trace(
            go.Bar(
                x=to_plot['date'],
                y=to_plot['duration'],
                name="Czas trwania (Bar)",
                marker_color='lightpink',
                opacity=0.9
            ),
            secondary_y=False,
        )

        colors = ["#8B2252", "#DC9316", "#2E8B57", "#3B5CCC"] 
        for i, metric in enumerate(selected_metrics):
            column_key = reverse_map[metric]
            fig.add_trace(
                go.Scatter(
                    x=to_plot['date'], 
                    y=to_plot[column_key], 
                    name=metric,
                    line=dict(color=colors[i % len(colors)], width=3, shape='spline')
                ),
                secondary_y=True,
            )

        fig.update_xaxes(title_text="Data")
        fig.update_yaxes(title_text="Czas trwania snu", secondary_y=False)
        fig.update_yaxes(title_text="Wartość metryki", secondary_y=True, griddash='dot', gridcolor="#580741")
        fig.update_layout(title_text="Korelacja snu i metryk muzycznych", **PLOTLY_LAYOUT, legend=dict(
        font=dict(size=16)))

        with st.expander("Uwaga co do prezentowanych danych"):
            st.write("""
               Ze względu na ograniczoną ilość piosenek, dla których dostępne są metryki, dla niektóych dni pojawiły się braki. 
                     Braki te są uzupełniane za pomocą interpolacji liniowej.
            """)

        st.plotly_chart(fig, use_container_width=True)

        st.divider() 
        st.markdown('<div class="animate-enter"><h2>Jakich zespołów słuchamy najczęściej przed pójściem spać i tuż po obudzeniu?</h1></div>', unsafe_allow_html=True)

        col1, col2 = st.columns(2)

        muzyka_emp =  muzyka_emp.loc[muzyka_emp['date'] >= '2025-01-01'].reset_index(drop=True)

        min_wake_up_time = pd.to_datetime(sen.woke_up).min().hour
        go_sleep = pd.to_datetime(sen.went_to_bed).dt.hour.reset_index()
        min_go_to_bed_time = go_sleep.loc[go_sleep.went_to_bed > 4]["went_to_bed"].min()
        max_wake_up_time = pd.to_datetime(sen.woke_up).max().hour
        max_go_to_bed_time = go_sleep.loc[go_sleep.went_to_bed < 10]["went_to_bed"].max()
        
        length_before = (max_go_to_bed_time - min_go_to_bed_time) % 24 + 1
        result_before = [(min_go_to_bed_time + i) % 24 for i in range(length_before)]
        length_after = (max_wake_up_time - min_wake_up_time) % 24 + 1
        result_after = [(min_wake_up_time + i) % 24 for i in range(length_after)]
        
        muzyka_przed_snem = muzyka_emp.loc[muzyka_emp['hour'].isin(result_before)].reset_index(drop=True)
        muzyka_po_snie = muzyka_emp.loc[muzyka_emp['hour'].isin(result_after)].reset_index(drop=True)
        
        artysci_przed_snem = muzyka_przed_snem.groupby("artist_name_clean").size().sort_values(ascending=False).head(30)
        artysci_po_snie = muzyka_po_snie.groupby("artist_name_clean").size().sort_values(ascending=False).head(30)

        with col1:
            st.write("**Przed snem**")
            if not artysci_przed_snem.empty:
                wc_przed = WordCloud(
                    width=600, height=400, 
                    background_color=None, mode="RGBA", colormap='PuRd'
                ).generate_from_frequencies(artysci_przed_snem)
                
                fig_wc1, ax1 = plt.subplots(facecolor='none')
                ax1.set_facecolor('none')
                ax1.imshow(wc_przed, interpolation='bilinear')
                ax1.axis("off")
                st.pyplot(fig_wc1)
            else:
                st.warning("Brak danych dla godzin wieczornych.")

        with col2:
            st.write("**Po obudzeniu**")
            if not artysci_po_snie.empty:
                wc_po = WordCloud(
                    width=600, height=400, 
                    background_color=None, mode="RGBA", colormap='GnBu'
                ).generate_from_frequencies(artysci_po_snie)
                
                fig_wc2, ax2 = plt.subplots(facecolor='none')
                ax1.set_facecolor('none')
                ax2.imshow(wc_po, interpolation='bilinear')
                ax2.axis("off")
                st.pyplot(fig_wc2)
            else:
                st.warning("Brak danych dla godzin porannych.")
    
    else:
        st.info(f"Brak danych snu dla użytkownika: {selected_person} (Szukano pliku: {PATH_SLEEP})")


with tab2:
    if os.path.exists(PATH_SENTIMENT):
        sen = pd.read_csv(PATH_SLEEP)
        sent = pd.read_csv(PATH_SENTIMENT, sep=";")
        
        sen["date"] = pd.to_datetime(sen["date"], errors="coerce")
        sen["duration"] = pd.to_numeric(sen["duration"], errors="coerce")
        sent["date"] = pd.to_datetime(sent["date"], errors="coerce")
        sent["sentiment"] = pd.to_numeric(sent["sentiment"], errors="coerce")          
        order = ["poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela"]

        sleep_weekly = sen.groupby("day", as_index=False).agg(
            avg_sleep=("duration", "mean")
        )
        sleep_weekly["day"] = pd.Categorical(sleep_weekly["day"], categories=order, ordered=True)
        sleep_weekly = sleep_weekly.sort_values("day")

        daynum_to_pl = {
            0: "poniedziałek",
            1: "wtorek",
            2: "środa",
            3: "czwartek",
            4: "piątek",
            5: "sobota",
            6: "niedziela",
            }

        sent["day_name"] = sent["day_num"].map(daynum_to_pl)
        sent_weekly = sent.groupby("day_name", as_index=False).agg(
            avg_sentiment=("sentiment", "mean"))
        sent_weekly["day_name"] = pd.Categorical(sent_weekly["day_name"], categories=order, ordered=True)
        sent_weekly = sent_weekly.sort_values("day_name")

        weekly = pd.merge(
            sleep_weekly,
            sent_weekly,
            left_on="day",
            right_on="day_name",
            how="left")  

        st.markdown('<div class="animate-enter"><h2>Czy długość snu wpływa na sentyment naszych wiadomości?</h1></div>', unsafe_allow_html=True)
 
        fig = make_subplots(specs=[[{"secondary_y": True}]])
        fig.add_trace(
            go.Bar(
                x=weekly["day"].astype(str),
                y=weekly["avg_sleep"],
                name="Średnia długość snu (godz.)",
                marker=dict(color="lightpink", line=dict(width=0)),
                opacity=0.9,
            ),
            secondary_y=False,
        )

        fig.add_trace(
            go.Scatter(
                x=weekly["day"].astype(str),
                y=weekly["avg_sentiment"],
                name="Średni sentyment (0–1)",
                mode="lines+markers",
                line=dict(width=3, color="#8B2252"),
                marker=dict(size=8, color="#8B2252"),
            ),
            secondary_y=True,
        )

        fig.update_xaxes(title_text="Dzień tygodnia")
        fig.update_yaxes(title_text="Średnia długość snu (godz.)", secondary_y=False)
        fig.update_yaxes(title_text="Średni sentyment (0 - 1)", range = [0,1], secondary_y=True, griddash='dot', gridcolor="#580741")


        fig.update_layout(
            title="Sen a sentyment według dnia",
            legend=dict(
            orientation="v",
            yanchor="middle",
            y=0.5,
            xanchor="left",
            x=1.02            
        ),
            **PLOTLY_LAYOUT
        )
        fig.update_layout(legend=dict(
        font=dict(size=16)))

        st.plotly_chart(fig, use_container_width=True)

        st.markdown("---")
        st.markdown('<div class="animate-enter"><h2>Rytm snu: O której godzinie zasypiamy i wstajemy?</h1></div>', unsafe_allow_html=True)

        def time_to_minutes(t):
            t = str(t)
            if t in ("nan", "NaT", "None"):
                return None
            parts = t.split(":")
            h = int(parts[0])
            m = int(parts[1])
            return h * 60 + m

        def minutes_to_hhmm(x):
            if pd.isna(x):
                return ""
            x = int(x) % (24 * 60)
            return f"{x//60:02d}:{x%60:02d}"
        
        sen["bed_min"] = sen["went_to_bed"].apply(time_to_minutes)            
        sen["wake_min"] = sen["woke_up"].apply(time_to_minutes)

      
        sen["bed_min_adj"] = sen["bed_min"]
        mask_after_midnight = sen["bed_min_adj"].notna() & (sen["bed_min_adj"] < 12 * 60)
        sen.loc[mask_after_midnight, "bed_min_adj"] = sen.loc[mask_after_midnight, "bed_min_adj"] + 24 * 60

        bed_ticks = list(range(20 * 60, 28 * 60 + 1, 60))  

        fig_bed_time = go.Figure()
        fig_bed_time.add_trace(
            go.Scatter(
                x=sen["date"],
                y=sen["bed_min_adj"],
                mode="lines+markers",
                name="Pójście spać",
                customdata=sen["bed_min_adj"].apply(minutes_to_hhmm),
                hovertemplate="Data: %{x|%Y-%m-%d}<br>Pójście spać: %{customdata}<extra></extra>",
                line=dict(width=3, color="#3B5CCC" ),
                marker=dict(size=6, color="#3B5CCC"),
            )
        )

        fig_bed_time.update_xaxes(title_text="Data")
        fig_bed_time.update_yaxes(
            title_text="Godzina",
            range=[20 * 60, 28 * 60],
            tickmode="array",
            tickvals=bed_ticks,
            ticktext=[minutes_to_hhmm(v) for v in bed_ticks],
        )

        fig_bed_time.update_layout(
            title="Godzina zaśnięcia 🌙",
            height=320,
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig_bed_time, use_container_width=True)

        wake_ticks = list(range(4 * 60, 12 * 60 + 1, 60)) 

        fig_wake_time = go.Figure()
        fig_wake_time.add_trace(
            go.Scatter(
                x=sen["date"],
                y=sen["wake_min"],
                mode="lines+markers",
                name="Pobudka",
                customdata=sen["wake_min"].apply(minutes_to_hhmm),
                hovertemplate="Data: %{x|%Y-%m-%d}<br>Pobudka: %{customdata}<extra></extra>",
                line=dict(width=3, color="#C51B7D" ),
                marker=dict(size=6, color="#C51B7D"),
            )
        )

        fig_wake_time.update_xaxes(title_text="Data")
        fig_wake_time.update_yaxes(
            title_text="Godzina",
            range=[4 * 60, 12 * 60],
            tickmode="array",
            tickvals=wake_ticks,
            ticktext=[minutes_to_hhmm(v) for v in wake_ticks],
        )

        fig_wake_time.update_layout(
            title="Godzina pobudki ☀️",
            height=320,
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig_wake_time, use_container_width=True)

        st.markdown('<div class="animate-enter"><h2>Rozkład godzin według dnia tygodnia</h1></div>', unsafe_allow_html=True)
        
        fig_bed = go.Figure(
            data=go.Box(
                x=sen["day"].astype(str),
                y=sen["bed_min_adj"],
                name="Pójście spać",
                boxpoints="outliers"
            )
        )
        fig_bed.update_traces(
        fillcolor="rgba(124,92,255,0.35)",
        line=dict(color="#3B5CCC", width=2),
        marker=dict(color="#3B5CCC", size=5, opacity=0.6)
    )
        fig_bed.update_layout(showlegend=False, **PLOTLY_LAYOUT)

        fig_bed.update_xaxes(title_text="Dzień tygodnia")
        fig_bed.update_yaxes(
            title_text="Godzina zaśnięcia 🌙",
            tickmode="array",
            tickvals=bed_ticks,
            ticktext=[minutes_to_hhmm(v) for v in bed_ticks],
        )

        fig_bed.update_layout(
            title="Godziny zasypiania według dnia tygodnia",
            height=380,
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig_bed, use_container_width=True)

        wake_ticks = list(range(4 * 60, 13 * 60 + 1, 60)) 

        fig_wake = go.Figure(
            data=go.Box(
                x=sen["day"].astype(str),
                y=sen["wake_min"],
                name="Pobudka",
                boxpoints="outliers"                
            )
        )
        fig_wake.update_traces(
        fillcolor="rgba(197,27,125,0.28)",
        line=dict(color="#C51B7D", width=2),
        marker=dict(color="#C51B7D", size=5, opacity=0.6)
    )
        fig_wake.update_layout(showlegend=False, **PLOTLY_LAYOUT)

        fig_wake.update_xaxes(title_text="Dzień tygodnia")
        fig_wake.update_yaxes(
            title_text="Godzina pobudki ☀️",
            tickmode="array",
            tickvals=wake_ticks,
            ticktext=[minutes_to_hhmm(v) for v in wake_ticks],
        )

        fig_wake.update_layout(
            title="Godzina wstawania według dnia tygodnia",
            height=380,
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig_wake, use_container_width=True)

    else:
        st.info(f"Brak danych sentymentu dla użytkownika: {selected_person} (Szukano pliku: {PATH_SENTIMENT})")


with tab3:
    if os.path.exists(PATH_SPOTIFY_HIST):
        sen = pd.read_csv(PATH_SLEEP)
        sent = pd.read_csv(PATH_SENTIMENT, sep=";")

        sen["date"] = pd.to_datetime(sen["date"], errors="coerce")  
        sen["duration"] = pd.to_numeric(sen["duration"], errors="coerce")
        sent["date"] = pd.to_datetime(sent["date"], errors="coerce")
        sent["sentiment"] = pd.to_numeric(sent["sentiment"], errors="coerce")
        sent["datetime"] = pd.to_datetime(sent["datetime"], errors="coerce")
        sent["hour"] = sent["datetime"].dt.hour
          
        order = ["poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela"]
        daynum_to_pl = {
            0: "poniedziałek", 1: "wtorek", 2: "środa",
            3: "czwartek", 4: "piątek", 5: "sobota", 6: "niedziela"
        }
        pl_to_daynum = {v: k for k, v in daynum_to_pl.items()}

        st.markdown('<div class="animate-enter"><h2>Liczba wiadomości dziennie</h1></div>', unsafe_allow_html=True)

        daily_counts = sent.groupby(sent["date"].dt.date).size().reset_index(name="msg_count")
        daily_counts["date"] = pd.to_datetime(daily_counts["date"])
        daily_counts = daily_counts.sort_values("date")

        fig = go.Figure()
        fig.add_trace(
            go.Scatter(
                x=daily_counts["date"],
                y=daily_counts["msg_count"],
                mode="lines+markers",
                name="Wiadomości",
                line=dict(width=3, color="#3B5CCC" ),
                marker=dict(size=6, color="#3B5CCC"),
            )
        )        

        fig.update_xaxes(title_text="Data", tickformat="%d.%m")
        fig.update_yaxes(title_text="Liczba wiadomości")
        fig.update_layout(
            title="Liczba wiadomości dla każdego dnia",
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig, use_container_width=True)      
        st.markdown('<div class="animate-enter"><h2>Przegląd wiadomości — wybierz dzień tygodnia</h1></div>', unsafe_allow_html=True)

        selected_day = st.selectbox(
            "Wybierz dzień tygodnia:",
            list(pl_to_daynum.keys())
        )

        sent_day = sent[sent["day_num"] == pl_to_daynum[selected_day]]

        if sent_day.empty:
            st.info("Brak wiadomości dla wybranego dnia.")
        else:
            col1, col2, col3 = st.columns(3)

            total_messages = len(sent_day)
            number_of_days = sent_day["date"].dt.date.nunique()
            avg_messages_per_day = total_messages / number_of_days

            col1.metric("Średni sentyment", f"{sent_day['sentiment'].mean():.2f}")
            col2.metric("Łączna liczba wiadomości", total_messages)
            col3.metric("Średnio wiadomości na dzień", f"{avg_messages_per_day:.1f}")         


        st.markdown('<div class="animate-enter"><h3>Heatmapa aktywności w ciągu wybranego dnia tygodnia</h1></div>', unsafe_allow_html=True)
    
        per_date_hour = (
            sent_day
            .groupby([sent_day["date"].dt.date, "hour"])
            .size()
            .reset_index(name="count")
        )

        hourly_avg = per_date_hour.groupby("hour", as_index=False)["count"].mean()

        all_hours = pd.DataFrame({"hour": list(range(24))})
        hourly_avg = all_hours.merge(hourly_avg, on="hour", how="left").fillna({"count": 0})

        max_hour = int(hourly_avg.loc[hourly_avg["count"].idxmax(),"hour"])
        min_hour = int(hourly_avg.loc[hourly_avg["count"].idxmin(),"hour"])

        colA, colB = st.columns(2)
        colA.metric("Najwięcej (średnio) o godzinie",f"{max_hour:02d}:00")
        colB.metric("Najmniej (średnio) o godzinie",f"{min_hour:02d}:00")

        heat_z = [hourly_avg["count"].tolist()] 

        fig = go.Figure(
            data=go.Heatmap(
                z=heat_z,
                x=[f"{h:02d}" for h in range(24)],
                y=[selected_day],
                zmin=0,
                zmax=hourly_avg["count"].max(),     
                hoverongaps=False,
                colorscale = [[0.0, "lightpink"], [1.0, "#27408B"]],
                colorbar=dict(title="Śr. wiadomości / godz."),
            )
        )

        fig.update_xaxes(title_text="Godzina (0–23)",tickmode="array",tickvals=[f"{h:02d}" for h in range(0,24,2)])
        fig.update_yaxes(title_text="")
        fig.update_layout(
            title=f"Średnia liczba wiadomości w ciągu dnia — {selected_day}",
            height=350,
            **PLOTLY_LAYOUT
        )

        st.plotly_chart(fig, use_container_width=True)

    else:
        st.info(f"Brak danych sentymentu dla użytkownika: {selected_person} (Szukano pliku: {PATH_SPOTIFY_HIST})")