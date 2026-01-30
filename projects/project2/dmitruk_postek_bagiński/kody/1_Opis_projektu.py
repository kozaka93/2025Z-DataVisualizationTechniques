import streamlit as st

st.set_page_config(page_title="Opis projektu", layout="wide")
st.title("Sleep, Mood & Messages")

st.markdown('<div class="animate-enter"><h3>Analiza zależności między snem, sentymentem wiadomości i cechami słuchanej muzyki.</h1></div>', unsafe_allow_html=True)

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
        .tag-pink { background: linear-gradient(90deg, #ec008c  0%, #fc6767 100%); }
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


st.markdown("---")

colA, colB = st.columns(2)

with colA:
    st.markdown('<div class="glass">', unsafe_allow_html=True)
    st.subheader("Cel projektu")
    st.write("""
    Celem aplikacji jest **wizualna analiza** zależności między:
    - **snem** (długość oraz rytm: godzina zaśnięcia i pobudki),
    - **aktywnością w Messengerze** (liczba wiadomości, rozkład godzinowy),
    - oraz **charakterystyką słuchanej muzyki** (metryki audio ze Spotify).
    """)
    st.markdown('</div>', unsafe_allow_html=True)
    st.markdown('<div class="glass">', unsafe_allow_html=True)
    st.subheader("Dane wejściowe")
    st.write("""
    Dane zostały przygotowane jako pliki CSV dla każdego użytkownika.

    **1) Sen**   
    - data snu, godzina zaśnięcia i pobudki, długość snu, dzień tygodnia

    **2) Messenger**
    - treść wiadomości (po czyszczeniu), data i godzina wysłania, dzień tygodnia  
    - **sentyment (0–1) jest wyliczany przez model NLP** (nie jest pobierany z Facebooka)

    
    **3) Spotify**
    - z historii odsłuchań mamy: **data, godzina, utwór i wykonawca**  
    - metryki audio (**energy, valence, danceability, liveness**) **nie występują w surowym eksporcie Spotify**, 
    zostały dopisane z bazy danych z Kaggle'a.
    """)
    st.markdown('</div>', unsafe_allow_html=True)

with colB:
    st.markdown('<div class="glass">', unsafe_allow_html=True)
    st.subheader("Przetwarzanie danych (w skrócie)")
    st.write("""
    - czyszczenie wiadomości (usuwanie linków, puste treści) i parsowanie dat (`datetime`, `date`, `day_num`)
             
    Agregacje:
    - średni sen wg dnia tygodnia
    - liczba wiadomości na dzień
    - średnia aktywność godzinowa (wiadomości / godz.)
    - sentyment: przetwarzany przez model NLP (wynik znormalizowany do skali **0–1**.)
    """)
    st.markdown('</div>', unsafe_allow_html=True)
    st.markdown('<div class="glass">', unsafe_allow_html=True)
    st.subheader("Jak czytać wykresy")
    st.write("""
    - **Muzyka a sen:** słupki = długość snu, linie = metryki muzyczne (np. energia).
    - **Sen a sentyment (dzień tygodnia):** słupki = średni sen, linia = średni sentyment (0–1).
    - **Rytm snu:** osobne wykresy dla godziny zaśnięcia i pobudki w czasie.
    - **Boxploty:** pokazują rozrzut godzin snu w zależności od dnia tygodnia.
    - **Wiadomości:** trend dzienny + **heatmapa godzinowa** aktywności.
    """)
    st.markdown('</div>', unsafe_allow_html=True)

with st.expander("Ograniczenia i uwagi interpretacyjne"):
    
    st.write("""
    - **Sentyment jest wynikiem modelu NLP** i może zawierać błędy (ironia, skróty, brak kontekstu rozmowy).
    - Metryki audio Spotify (**energy, valence, danceability, liveness**) są **dodane z zewnętrznej bazy**  po dopasowaniu utworu i wykonawcy.
    - Puste dni na wykresie „Muzyka a sen” wynikają z tego, że **Spotify obejmuje krótszy zakres dat niż sen**.
    - Braki w metrykach muzycznych są uzupełniane **interpolacją liniową**, żeby móc porównywać je dzień po dniu.
    """)


st.markdown("---")

st.subheader("Autorzy")
st.write("Aleksandra Dmitruk, Wiktoria Postek, Adam Bagiński")

if st.button("➡ Przejdź do dashboardu (osoba)"):
    st.switch_page("3_Analiza_szczegółowa.py")
