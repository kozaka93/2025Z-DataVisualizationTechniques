import streamlit as st
import pandas as pd
import numpy as np
import os

def clean_data_for_ml(df):
    
    df_clean = df.copy()
    
    features = ['bialko', 'tluszcze', 'weglowodany', 'cukry', 'blonnik', 'sol']
    
    
    df_clean['data'] = pd.to_datetime(df_clean['data'], format='%d.%m.%Y', errors='coerce')
    
  
    for col in features:
        if col in df_clean.columns:
            if df_clean[col].dtype == 'object':
                df_clean[col] = df_clean[col].astype(str).str.replace(',', '.').astype(float)
            df_clean[col] = df_clean[col].fillna(0.0)
        else:
            df_clean[col] = 0.0
            
    
    df_clean = df_clean.dropna(subset=['Osoba'])
    
   
    df_daily = df_clean.groupby(['Osoba', 'data'])[features].sum().reset_index()
    
    
    df_daily['suma_makro'] = df_daily[features].sum(axis=1)
    
   
    df_daily = df_daily[df_daily['suma_makro'] > 10] 
    
    
    limits = {
        'bialko': 1000, 
        'tluszcze': 1000,
        'weglowodany': 2000,
        'cukry': 1000,
        'blonnik': 300,
        'sol': 100
    }
    
    for col, limit in limits.items():
        df_daily = df_daily[df_daily[col] < limit]

    
    return df_daily[features], df_daily['Osoba'], df_daily.index

def min_max_scale(X):
    
    min_val = np.min(X, axis=0)
    max_val = np.max(X, axis=0)
    range_val = max_val - min_val
    range_val[range_val == 0] = 1 
    
    X_scaled = (X - min_val) / range_val
    return X_scaled, min_val, range_val

def predict_knn(X_train, y_train, x_input, k=5):
  
   
    distances = np.sqrt(np.sum((X_train - x_input)**2, axis=1))
    
    
    k_indices = np.argsort(distances)[:k]
    
    k_nearest_labels = y_train[k_indices]
    k_nearest_distances = distances[k_indices]
    
    
    weights = 1 / (k_nearest_distances + 1e-5)
    
    unique_labels = np.unique(k_nearest_labels)
    weighted_votes = {}
    
    for label in unique_labels:
        weighted_votes[label] = np.sum(weights[k_nearest_labels == label])
        
    prediction = max(weighted_votes, key=weighted_votes.get)
    
    
    best_match_idx = k_indices[0] 
    best_match_dist = k_nearest_distances[0]
    
    similarity = 100 / (1 + best_match_dist)
    
    return prediction, k_nearest_labels, similarity, best_match_idx

def rysuj(df):
    st.header("✨ Predyktor Osobowości Żywieniowej")

    X_raw, y_raw, original_indices = clean_data_for_ml(df)
    
    if len(X_raw) < 5:
        st.error(f"Za mało danych po agregacji ({len(X_raw)} pełnych dni). Sprawdź pliki CSV.")
        return

    X_np = X_raw.to_numpy()
    y_np = y_raw.to_numpy()
    
    X_scaled, min_val, range_val = min_max_scale(X_np)

    defaults = X_raw.mean()

    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Makroskładniki (Suma Dnia):")
        bialko = st.slider("Białko (g)", 0, 300, int(defaults['bialko']))
        tluszcze = st.slider("Tłuszcze (g)", 0, 200, int(defaults['tluszcze']))
        wegle = st.slider("Węglowodany (g)", 0, 600, int(defaults['weglowodany']))
        
    with col2:
        st.write("") 
        st.write("") 
        cukry = st.slider("Cukry (g)", 0, 200, int(defaults['cukry']))
        blonnik = st.slider("Błonnik (g)", 0, 100, int(defaults['blonnik']))
        sol = st.slider("Sól (g)", 0.0, 20.0, float(defaults['sol']), step=0.1)

    if st.button("Kim dzisiaj jesteś? (Oblicz)", type="primary"):
        
        input_vector = np.array([[bialko, tluszcze, wegle, cukry, blonnik, sol]])
        input_scaled = (input_vector - min_val) / range_val
        
        prediction, neighbors, similarity, best_idx_train = predict_knn(X_scaled, y_np, input_scaled, k=5)
        
        st.divider()
        r1, r2 = st.columns([1, 2])
        
        with r1:
            st.markdown("### Wynik:")
            
            avatars = {
                "Hubert": "kody/avatars/hubert.png",
                "Szymon": "kody/avatars/szymon.png",
                "Zosia":  "kody/avatars/zosia.png"
            }
            image_path = avatars.get(prediction)
            
            st.image(image_path, width=150, caption=prediction)
            
            st.metric(label="Twój bliźniak żywieniowy:", value=prediction)
        
        with r2:
            st.markdown(f"### Poziom dopasowania: **{similarity:.1f}%**")
            st.progress(int(min(similarity, 100)))
            
            st.write("Twoi najbliżsi sąsiedzi (dni z bazy):")
            
            neighbors_df = pd.DataFrame(neighbors, columns=["Osoba"])
            counts = neighbors_df['Osoba'].value_counts()
            
            for person, count in counts.items():
                st.write(f"- **{person}**: {count} razy w top 5")

            if similarity > 80:
                st.success("To bardzo typowy dzień dla tej osoby!")
            elif similarity > 50:
                st.info("Widać podobieństwa w diecie.")
            else:
                st.warning("Wynik niejednoznaczny - Twoje wybory są dość unikalne.")