import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import calendar
from datetime import datetime

MONTH_PL = {
    1: "Styczeń", 2: "Luty", 3: "Marzec", 4: "Kwiecień",
    5: "Maj", 6: "Czerwiec", 7: "Lipiec", 8: "Sierpień",
    9: "Wrzesień", 10: "Październik", 11: "Listopad", 12: "Grudzień"
}

DARK_PAPER = "#0E1117"
DARK_PLOT  = "#0B0F14"
DARK_GRID  = "#1B2330"

PERSON_TARGETS = {
    "Hubert": dict(kcal=3100, protein=160, fat=90, carbs=420, study_h=4.0, steps=8000),
    "Szymon": dict(kcal=3200, protein=150, fat=120, carbs=400, study_h=5.0, steps=8000),
    "Zosia":  dict(kcal=2000, protein=120, fat=60,  carbs=200, study_h=4.0, steps=8000),
}

CAPS = {
    "kcal":  1.10, 
    "protein": 1.20,
    "fat":   1.20,
    "carbs": 1.20,
    "steps": 1.50,
    "study": 1.50,
}
BONUSES = {
    "kcal":  0.05, 
    "protein": 0.10,
    "fat":   0.10,
    "carbs": 0.10,
    "steps": 0.30, 
    "study": 0.30,
}

WEIGHTS = dict(
    kcal=0.20,
    protein=0.15,
    fat=0.10,
    carbs=0.10,
    steps=0.25,
    study=0.20
)



def preprocess_data(df_input: pd.DataFrame, person_name: str) -> pd.DataFrame:
    """Przetwarza dane wejściowe z app.py na format wymagany przez heatmapę."""

    df = df_input[df_input['Osoba'] == person_name].copy()
    
    df["data"] = pd.to_datetime(df["data"], format='%d.%m.%Y', errors='coerce')
    if df["data"].dt.year.min() > 2050: 
         df["data"] = pd.to_datetime(df["data"], format='%Y-%m-%d', errors='coerce')

    rename_map = {
        "kalorie": "kcal",
        "bialko": "protein",
        "tluszcze": "fat",
        "weglowodany": "carbs",
        "godz_na_ucz": "study_h",
        "ilosc_krokow": "steps",
    }
    df = df.rename(columns=rename_map)

    cols_numeric = ["kcal", "protein", "fat", "carbs", "steps", "study_h"]
    for c in cols_numeric:
        if c in df.columns:
            if df[c].dtype == 'object':
                df[c] = df[c].astype(str).str.replace(',', '.').astype(float)
        else:
            df[c] = 0.0 

    df["study_h"] = df["study_h"].clip(lower=0)

    daily = (
        df.groupby("data", as_index=False)
          .agg(
              kcal=("kcal", "sum"),
              protein=("protein", "sum"),
              fat=("fat", "sum"),
              carbs=("carbs", "sum"),
              steps=("steps", "max"), 
              study_h=("study_h", "max"),
          )
          .sort_values("data")
    )
    
    daily[cols_numeric] = daily[cols_numeric].fillna(0)
    return daily

def score_target_bonus(actual: pd.Series, target: float, cap: float, bonus_max: float) -> pd.Series:
    if target <= 0:
        return pd.Series(np.nan, index=actual.index)

    r = (actual / target).astype(float)
    r = np.clip(r, 0.0, np.inf)

    below = np.clip(r, 0.0, 1.0)

    if cap <= 1.0 or bonus_max <= 0.0:
        above = np.ones_like(r)
    else:
        bonus_progress = np.clip((r - 1.0) / (cap - 1.0), 0.0, 1.0)
        above = 1.0 + bonus_max * bonus_progress

    return pd.Series(np.where(r < 1.0, below, above), index=actual.index)

def compute_productivity(daily: pd.DataFrame, targets: dict) -> pd.DataFrame:
    out = daily.copy()

    out["kcal_score"]    = score_target_bonus(out["kcal"],    targets["kcal"],    CAPS["kcal"],    BONUSES["kcal"])
    out["protein_score"] = score_target_bonus(out["protein"], targets["protein"], CAPS["protein"], BONUSES["protein"])
    out["fat_score"]     = score_target_bonus(out["fat"],     targets["fat"],     CAPS["fat"],     BONUSES["fat"])
    out["carbs_score"]   = score_target_bonus(out["carbs"],   targets["carbs"],   CAPS["carbs"],   BONUSES["carbs"])
    out["steps_score"]   = score_target_bonus(out["steps"],   targets["steps"],   CAPS["steps"],   BONUSES["steps"])
    out["study_score"]   = score_target_bonus(out["study_h"], targets["study_h"], CAPS["study"],   BONUSES["study"])

    w_sum = float(sum(WEIGHTS.values()))
    w = {k: v / w_sum for k, v in WEIGHTS.items()}

    raw = (
        w["kcal"]    * out["kcal_score"] +
        w["protein"] * out["protein_score"] +
        w["fat"]     * out["fat_score"] +
        w["carbs"]   * out["carbs_score"] +
        w["steps"]   * out["steps_score"] +
        w["study"]   * out["study_score"]
    )

    max_possible = (
        w["kcal"]    * (1.0 + BONUSES["kcal"]) +
        w["protein"] * (1.0 + BONUSES["protein"]) +
        w["fat"]     * (1.0 + BONUSES["fat"]) +
        w["carbs"]   * (1.0 + BONUSES["carbs"]) +
        w["steps"]   * (1.0 + BONUSES["steps"]) +
        w["study"]   * (1.0 + BONUSES["study"])
    )
    max_possible = max(max_possible, 1e-9)

    out["productivity_100"] = (100.0 * raw / max_possible).round(1)
    return out

def month_matrix(df: pd.DataFrame, year: int, month: int, targets: dict):
    month_df = df[(df["data"].dt.year == year) & (df["data"].dt.month == month)].copy()

    n_days = calendar.monthrange(year, month)[1]
    all_dates = pd.date_range(datetime(year, month, 1), periods=n_days, freq="D")
    base = pd.DataFrame({"data": all_dates}).merge(month_df, on="data", how="left")

    base["dow"] = base["data"].dt.weekday  
    first_dow = datetime(year, month, 1).weekday()
    base["week_of_month"] = ((base["data"].dt.day + first_dow - 1) // 7) + 1

    base.loc[base["week_of_month"] >= 6, "week_of_month"] = 5

    weeks = [1, 2, 3, 4, 5]
    z = np.full((len(weeks), 7), np.nan, dtype=float)
    hover = np.full((len(weeks), 7), "", dtype=object)

    for _, r in base.iterrows():
        w = int(r["week_of_month"])
        d = int(r["dow"])
        if w in weeks:
            wi = weeks.index(w)
            di = d
            
            date_str = r["data"].strftime("%Y-%m-%d")
            prod = r.get("productivity_100", np.nan)

            if pd.isna(prod):
                hover[wi, di] = f"<b>{date_str}</b><br>Brak danych"
                continue

            hover[wi, di] = (
                f"<b>{date_str}</b><br>"
                f"Produktywność: <b>{prod:.1f}</b>/100<br><br>"
                f"<b>Rzeczywiste</b><br>"
                f"Kcal: {r.get('kcal',0):.0f} | B: {r.get('protein',0):.0f}g | T: {r.get('fat',0):.0f}g | W: {r.get('carbs',0):.0f}g<br>"
                f"Kroki: {r.get('steps',0):.0f} | Nauka: {r.get('study_h',0):.2f} h<br><br>"
            )

            z[wi, di] = prod

    return z, hover

def calendar_two_months_subplot(df: pd.DataFrame, dec_ym: tuple, jan_ym: tuple, targets: dict):
    (y_dec, m_dec) = dec_ym
    (y_jan, m_jan) = jan_ym

    z_dec, h_dec = month_matrix(df, y_dec, m_dec, targets)
    z_jan, h_jan = month_matrix(df, y_jan, m_jan, targets)

    x_labels = ["Pon", "Wt", "Śr", "Czw", "Pt", "Sob", "Nd"]
    y_labels = [f"Tydz. {w}" for w in [1, 2, 3, 4, 5]]

    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=(f"{MONTH_PL[m_dec]} {y_dec}", f"{MONTH_PL[m_jan]} {y_jan}"),
        horizontal_spacing=0.06
    )

    fig.add_trace(
        go.Heatmap(
            z=z_dec, x=x_labels, y=y_labels, text=h_dec, hoverinfo="text",
            xgap=2, ygap=2, coloraxis="coloraxis"
        ),
        row=1, col=1
    )
    fig.add_trace(
        go.Heatmap(
            z=z_jan, x=x_labels, y=y_labels, text=h_jan, hoverinfo="text",
            xgap=2, ygap=2, coloraxis="coloraxis"
        ),
        row=1, col=2
    )

    fig.update_layout(
        template="plotly_dark",
        height=460,
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        font=dict(color="white"),
        margin=dict(l=10, r=10, t=80, b=10),
        coloraxis=dict(
            colorscale="Plasma",
            cmin=0, cmax=100,
            colorbar=dict(title="Prod. / 100", len=0.85, y=0.5)
        ),
    )

    for ann in fig.layout.annotations:
        ann.y = 1.15
        ann.yanchor = "top"
        ann.font = dict(size=16)

    for c in [1, 2]:
        fig.update_xaxes(
            side="top", showgrid=False, zeroline=False, linecolor=DARK_GRID,
            mirror=True, tickfont=dict(size=12), ticklabelposition="outside top",
            ticks="", row=1, col=c
        )
        fig.update_yaxes(
            autorange="reversed", showgrid=False, zeroline=False, linecolor=DARK_GRID,
            mirror=True, tickfont=dict(size=12), row=1, col=c
        )

    return fig


def rysuj(df_all_people):
    st.header("📆 Kalendarz Produktywności")

    dostepne_osoby = list(df_all_people['Osoba'].unique()) if 'Osoba' in df_all_people.columns else []
    
    osoby_z_celami = [os for os in dostepne_osoby if os in PERSON_TARGETS]
    
    if not osoby_z_celami:
        st.warning("Brak zdefiniowanych celów dla wykrytych osób w danych.")
        return

    col_sel, col_empty = st.columns([1, 3])
    with col_sel:
        person = st.selectbox("Wybierz osobę do analizy:", osoby_z_celami)

    daily = preprocess_data(df_all_people, person)
    targets = PERSON_TARGETS[person]
    
    df_result = compute_productivity(daily, targets)

    col_left, col_right = st.columns([1, 3], gap="large")

    with col_left:
        st.subheader(f"Cele: {person}")
        st.write(
            f"- **Kcal:** {targets['kcal']}\n"
            f"- **Białko:** {targets['protein']} g\n"
            f"- **Tłuszcze:** {targets['fat']} g\n"
            f"- **Węglowodany:** {targets['carbs']} g\n"
            f"- **Nauka:** {targets['study_h']} h\n"
            f"- **Kroki:** {targets['steps']}"
        )

        with st.expander("Jak liczony jest wynik?"):
            st.markdown(
                """
                **Punktacja:**
                - Cel osiągnięty = 100%
                - Poniżej celu = % realizacji
                - Powyżej celu = Bonus (limitowany)
                
                **Wagi składowych:**
                - Kroki: 25%
                - Kcal: 20%
                - Nauka: 20%
                - Białko: 15%
                - Tłuszcze/Węgle: po 10%
                """
            )

    with col_right:
        dfv = df_result.dropna(subset=["data"]).copy()
        dfv["year"] = dfv["data"].dt.year
        dfv["month"] = dfv["data"].dt.month
        
        ym_unique = dfv[["year", "month"]].drop_duplicates().sort_values(["year", "month"]).to_numpy()

        if len(ym_unique) < 2:
            st.warning("Za mało danych, aby wyświetlić widok dwumiesięczny.")
            st.dataframe(df_result)
        else:
            last_two = ym_unique[-2:]
            dec_ym = (int(last_two[0][0]), int(last_two[0][1]))
            jan_ym = (int(last_two[1][0]), int(last_two[1][1]))

            fig = calendar_two_months_subplot(df_result, dec_ym, jan_ym, targets)
            st.plotly_chart(fig, use_container_width=True)
