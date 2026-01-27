import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.animation import FuncAnimation

np.random.seed(2137)
elem_count = 5000
angles = np.linspace(0, 10 * np.pi, elem_count)
y = np.linspace(0, 1, elem_count)
r = 1 - y

noise = np.random.normal(0, 0.05, elem_count)
x = (r + noise) * np.sin(angles)
tree = pd.DataFrame({'x': x, 'y': y})

# Do bombek
balls_count = 50
weights = (1 - 0.4 * tree['y']) # ładne rozmieszczenie bombek
weights /= weights.sum()
indices = np.random.choice(tree.index, balls_count, replace=False, p=weights)
balls_df = tree.iloc[indices]

ball_sizes = [('#FF4444', 80),('#FFDF2D', 50),('#44CCFF', 65)]
random_indices = np.random.randint(0, len(ball_sizes), balls_count)
colors = [ball_sizes[i][0] for i in random_indices]
sizes = [ball_sizes[i][1] for i in random_indices]

# funkcja do rysowania prezentów
def draw_gift(x_center, y_bottom, size, box_col, rib_col, zo):
    bx = [x_center - size, x_center + size, x_center + size, x_center - size]
    by = [y_bottom, y_bottom, y_bottom + size, y_bottom + size]
    plt.fill(bx, by, color=box_col, zorder=zo)
    plt.plot([x_center, x_center], [y_bottom, y_bottom + size], color=rib_col, linewidth=3, zorder=zo+1)
    plt.plot([x_center - size, x_center + size], [y_bottom + size/2, y_bottom + size/2], color=rib_col, linewidth=3, zorder=zo+1)

# Do śnieku
snow_count = 200
snow_x = np.random.uniform(-1.2, 1.2, snow_count)
snow_y = np.random.uniform(0, 1.2, snow_count)
snow_speed = np.random.uniform(0.005, 0.015, snow_count)


# Wykres
fig = plt.figure(figsize=(6, 8), facecolor="#051928")
ax = plt.gca()
plt.axis('off')

# Pień
plt.fill([-0.1, 0.1, 0.1, -0.1], [-0.15, -0.15, 0, 0], color="#3F2723") 
for i in np.linspace(-0.08, 0.08, 5):
    plt.plot([i, i], [-0.145, -0.005], color="#221512", linewidth=1.5, alpha=0.6)

# Choinka
plt.scatter(tree['x'], tree['y'], c=tree['y'], cmap='Greens', s=10, alpha=0.5)

# Bombki
plt.scatter(balls_df['x'], balls_df['y'], c=colors, s=sizes, edgecolors='white', linewidth=0.4)

# Prezenty
draw_gift(-0.35, -0.20, 0.14, "#D32F2F", "#EA9988", 1)
draw_gift(-0.05, -0.18, 0.11, "#1976D2", "#92FFF8", 2)
draw_gift(0.32, -0.2, 0.15, "#FF7B08", "#E4BD8F", 2)
draw_gift(-0.12, -0.23, 0.09, "#FBC02D", "#EBE769", 4)
draw_gift(0.24, -0.22, 0.12, "#388E3C", "#B3FA90", 4)
draw_gift(-0.48, -0.21, 0.08, "#7B1FA2", "#E1BEE7", 4)

# Gwiazda
plt.scatter([0], [1.04], marker='*', s=800, c='gold', edgecolors='orange')

# Ruchomy śnieg
snow_scatter = ax.scatter(snow_x, snow_y, c='white', s=8, alpha=0.8, zorder=6)

def update(frame):
    global snow_y, snow_x
    snow_y -= snow_speed
    reset = snow_y < -0.2
    snow_y[reset] = [1.2] * np.sum(reset)
    snow_x[reset] = np.random.uniform(-1.2, 1.2, np.sum(reset))
    snow_scatter.set_offsets(np.c_[snow_x, snow_y])
    return snow_scatter,

ani = FuncAnimation(fig, update, frames=200, interval=30, blit=True)
ani.save('christmas_tree.gif', writer='pillow', fps=30)
plt.show()