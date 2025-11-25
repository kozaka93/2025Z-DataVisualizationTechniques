import plotly.graph_objects as go
import pandas as pd

airports = ["Warsaw (WAW)", "Kraków (KRK)", "Gdańsk (GDN)", "Wrocław (WRO)", "Katowice (KTW)"]
routes   = [141, 131, 76, 72, 57]
airlines = [36, 33, 12, 11, 8]

df = pd.DataFrame({
    "Airport": airports,
    "Routes": routes,
    "Airlines": airlines
}).sort_values("Routes", ascending=True)

fig = go.Figure()

fig.add_trace(
    go.Bar(
        y=df["Airport"],
        x=df["Routes"],
        orientation="h",
        name="Number of routes",
        marker=dict(
            color=df["Routes"],
            colorscale=["#6495ed", "#6495ed", "#6495ed", "#6495ed", "#6495ed"]
        ),
        text=df["Routes"],
        textposition="outside",
        textfont=dict(color="white", size=14),
        hovertemplate="<b>%{y}</b><br>Routes: %{x}<extra></extra>"
    )
)

fig.add_trace(
    go.Scatter(
        y=df["Airport"],
        x=df["Airlines"],
        mode="lines+markers+text",
        name="Number of airlines (pink line)",
        line=dict(color="#ff1493", width=4),
        marker=dict(size=10, color="#ff1493", line=dict(color="white", width=1)),
        text=df["Airlines"],
        textposition="middle right",
        textfont=dict(color="white", size=12),
        hovertemplate="<b>%{y}</b><br>Airlines: %{x}<extra></extra>"
    )
)

fig.update_layout(
    title=dict(
        text="Routes and Airlines per Airport<br>",
        x=0.5, xanchor="center",
        font=dict(size=22, family="Poppins", color="white")
    ),
    plot_bgcolor="black",
    paper_bgcolor="black",
    font=dict(color="white", family="Poppins", size=14),
    margin=dict(t=80, r=80, b=120, l=150),
    legend=dict(
        orientation="h",
        yanchor="bottom",
        y=-0.35,
        xanchor="center",
        x=0.5,
        font=dict(color="white")
    ),
)

fig.update_xaxes(
    title="Number of routes / airlines",
    color="white",
    showgrid=False,
    zeroline=False
)

fig.update_yaxes(
    title="Airport",
    color="white",
    showgrid=False,
    zeroline=False
)

fig.show()