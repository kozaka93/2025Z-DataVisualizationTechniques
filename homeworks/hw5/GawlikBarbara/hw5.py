import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.patches import Polygon


# ===== Generowanie danych =====

np.random.seed(42)

levels = 12
points_per_level = 20

data = []

domains = ["MAT", "MAD", "IAD", "ISI"]
colors = {
    "MAT": "#1f77b4",
    "MAD": "#2ca02c",
    "IAD": "#d62728",
    "ISI": "#ff7f0e"
}

for level in range(levels):
    width = (levels - level) / levels
    n_points = points_per_level + level * 3
    x = np.random.uniform(-width, width, n_points)
    y = np.ones(n_points) * level
    domain = np.random.choice(domains, n_points)
    for xi, yi, di in zip(x, y, domain):
        data.append([xi, yi, di])

df = pd.DataFrame(data, columns=["x", "y", "domain"])


# ===== Rysowanie komponentów =====

fig, ax = plt.subplots(figsize=(6, 9))
ax.set_facecolor("#0b132b")
fig.patch.set_facecolor("#0b132b")

def draw_tree(frame):

    ax.clear()
    ax.set_facecolor("#0b132b")
    ax.axis("off")
    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1, levels + 2.6)

    # Pień
    ax.add_patch(Polygon(
        [(-0.1, -1), (0.1, -1), (0.15, 0), (-0.15, 0)],
        closed=True, color="#8b4513"
    ))

    # Choinka
    tree = Polygon(
        [(-1, 0), (0, levels + 0.5), (1, 0)],
        closed=True, color="#0b5d1e", alpha=0.3
    )
    ax.add_patch(tree)

    # Światełka
    visible = df.sample(frac=0.8 + 0.2 * np.sin(frame / 3))
    for domain in domains:
        subset = visible[visible["domain"] == domain]
        ax.scatter(
            subset["x"],
            subset["y"],
            s=30 + 20 * np.sin(frame / 2),
            color=colors[domain],
            alpha=0.9,
            label=domain
        )

    # Gwiazda
    ax.text(
        0,
        levels + 2.2,
        "★",
        color="gold",
        fontsize=30,
        ha="center",
        va="center"
    )

    # Śnieg
    snow_x = np.random.uniform(-1.1, 1.1, 70)
    snow_y = np.random.uniform(0, levels + 2.4, 70)
    sizes = np.random.uniform(15, 35, 70) 
    for x, y, s in zip(snow_x, snow_y, sizes):
        ax.text(
            x,
            y,
            "*",
            color="white",
            fontsize=s,
            ha="center",
            va="center",
            alpha=0.8
        )

    # Tytuł
    ax.text(
        0,
        levels + 1.4,
        "Wesołych Świąt!",
        color="white",
        fontsize=16,
        ha="center",
        va="center"
    )


# ===== Generowanie i zapis animacji =====

anim = FuncAnimation(fig, 
                     draw_tree, 
                     frames=30, 
                     interval=360)

anim.save(
    "hw5/drzewko.gif",
    writer="pillow",
    dpi=150
)

plt.close()