import pandas as pd
import plotly.graph_objects as go
import plotly.io as pio
import os

def generuj_rzeke(osoba_name):
    sciezki = {
        "Krzysiek": "Dane_Krzysiek.csv",
        "Łukasz": "Dane_Lukasz.csv",
        "Gustaw": "Dane_Gustaw.csv"}
    sciezka = sciezki.get(osoba_name)
    if not sciezka or not os.path.exists(sciezka):
        return "<h1>Brak pliku danych</h1>"
    
    df = pd.read_csv(sciezka)
    df['Date'] = pd.to_datetime(df['Date'])
    df = df.sort_values('Date')
    
    df['Sen'] = df['Sleep_time[s]'] / 3600
    df['Komputer'] = df['Comp_time[s]'] / 3600
    df['Telefon'] = df['Phone_time[s]'] / 3600
    df['Inne'] = (24 - (df['Sen'] + df['Komputer'] + df['Telefon'])).clip(lower=0)
    
    fig = go.Figure()
    
    kolory = ['rgba(135, 206, 250, 0.6)', 'rgba(255, 182, 193, 0.6)', 
              'rgba(152, 251, 152, 0.6)', 'rgba(250, 250, 250, 0.8)']
    kategorie = ['Sen', 'Komputer', 'Telefon', 'Inne']
    for i, kat in enumerate(kategorie):
        fig.add_trace(go.Scatter(x=df['Date'], y=df[kat],name=kat,stackgroup='one',line_shape='spline',
            fillcolor=kolory[i],line=dict(width=1.5, color='rgba(255,255,255,0.9)'),
            hoverinfo='x+y+name',hovertemplate='<b>%{x|%d.%m}</b><br>%{name}: %{y:.2f}h<extra></extra>'))
    daty = df['Date'].tolist()
    klatki = []
    for k in range(len(daty) - 3):
        klatki.append(go.Frame(layout=dict(xaxis=dict(range=[daty[k], daty[k+3]])),name=f"k{k}"))
    fig.frames = klatki

    fig.update_layout(
        xaxis=dict(range=[daty[0], daty[3]], type="date", tickformat="%d.%m", dtick="D1", fixedrange=True),
        yaxis=dict(range=[0, 24.1], fixedrange=True, dtick=4, title="Godziny"),
        updatemenus=[dict(
            type="buttons", direction="left", x=0, y=1.15,
            buttons=[
                dict(label="START", method="animate", args=[None, {
                    "frame": {"duration": 1015, "redraw": False},
                    "fromcurrent": True,
                    "mode": "immediate",
                    "transition": {"duration": 1000, "easing": "linear"}
                }]),
                dict(label="PAUZA", method="animate", args=[[None], {"frame": {"duration": 0}, "mode": "immediate"}])
            ]
        )],
        template="plotly_white",
        margin=dict(t=100, b=40, l=40, r=40),
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1))
    
    return pio.to_html(fig, full_html=False, include_plotlyjs='cdn',auto_play=False, config={'responsive': True})
