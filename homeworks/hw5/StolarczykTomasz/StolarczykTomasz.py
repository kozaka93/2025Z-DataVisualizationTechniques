# Tomasz Stolarczyk, 333090

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

################## 1. PUNKTY CHOINKI ##################

def generate_spiral_tree_data(height=15, base_radius=5, turns=15, n_points=3000):
    z = np.linspace(0, height, n_points) # wysokość
    r = base_radius * (1 - z / height) # promień zmniejsza się liniowo wraz z wysokością (stożek)
    theta = 2 * np.pi * turns * (z / height) # kąt rośnie wraz z wysokością (spirala)
    # współrzędne kartezjańskie na podstawie biegunowych
    x = r * np.cos(theta)
    y = r * np.sin(theta)

    return x, y, z

tree_x, tree_y, tree_z = generate_spiral_tree_data()

################## 2. BOMBKI ##################

np.random.seed(42) 
n_bombeczki = 120
# losowe punkty z naszej choinki
bombeczki_indices = np.random.choice(np.arange(len(tree_z)), n_bombeczki, replace=False) 
bombeczki_x = tree_x[bombeczki_indices]
bombeczki_y = tree_y[bombeczki_indices]
bombeczki_z = tree_z[bombeczki_indices] 
bombeczki_colors = np.random.choice(['#FF0000', '#FFD700', '#00BFFF', '#FF1493', '#FF4500'], n_bombeczki)
bombeczki_sizes_base = np.random.uniform(40, 120, n_bombeczki)

################## 3. WIZUALIZACJA 3D ##################

fig = plt.figure(figsize=(10, 10), facecolor='black')
ax = fig.add_subplot(111, projection='3d')
ax.set_facecolor('black')
ax.set_axis_off()
ax.grid(False)
ax.xaxis.set_pane_color((0.0, 0.0, 0.0, 0.0))
ax.yaxis.set_pane_color((0.0, 0.0, 0.0, 0.0))
ax.zaxis.set_pane_color((0.0, 0.0, 0.0, 0.0))

# pień choinki
ax.plot([0, 0], [0, 0], [0, -3], color='#8B4513', linewidth=10, zorder=1)
# choinka
ax.plot(tree_x, tree_y, tree_z, c='#228B22', linewidth=1.5, alpha=0.6, zorder=5)
# bombki
bombeczki_scatter = ax.scatter(bombeczki_x, bombeczki_y, bombeczki_z, 
                             c=bombeczki_colors, s=bombeczki_sizes_base, 
                             depthshade=True, 
                             marker='o', zorder=10)
# gwiazda na czubku choinki
ax.scatter([0], [0], [15.2], c='#FFD700', s=1200, marker='*', zorder=20, edgecolors='orange')

ax.view_init(elev=15, azim=0)
ax.set_xlim([-6, 6])
ax.set_ylim([-6, 6])
ax.set_zlim([-3, 16])
plt.title("Wesołych Świąt w 3D :)", color='white', fontsize=20, y=0.95)

################## 4. ANIMACJA ##################

def update(frame):
    ax.view_init(elev=15, azim=frame) # obrót kamery wokół osi Z
    # efekt pulsowania bombek (używamy funkcji sinus, aby rozmiar płynnie rósł i malał)
    pulse_factor = np.sin(frame / 8.0) * 0.4 + 1.0
    new_sizes = bombeczki_sizes_base * pulse_factor
    bombeczki_scatter.set_sizes(new_sizes)
    return bombeczki_scatter,

ani = FuncAnimation(fig, update, frames=np.arange(0, 360, 2), interval=50, blit=False)

################## 5. ZAPIS DO GIFa ##################

ani.save('wesolych_swiat.gif', writer='pillow', fps=20)