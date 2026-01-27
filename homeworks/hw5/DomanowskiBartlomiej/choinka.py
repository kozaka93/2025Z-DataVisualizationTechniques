import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

def generate_tree_data(height=10):
    t_tree = np.linspace(0, 20 * np.pi, 1000)
    z_tree = np.linspace(0, height, 1000)
    r_tree = 6 * (1 - z_tree / height)
    x_tree = r_tree * np.cos(t_tree)
    y_tree = r_tree * np.sin(t_tree)
    t_chain = np.linspace(0, 8 * np.pi, 200)
    z_chain = np.linspace(0.2, height * 0.9, 200)
    r_chain = 6.5 * (1 - z_chain / height)
    x_chain = r_chain * np.cos(t_chain)
    y_chain = r_chain * np.sin(t_chain)
    num_ornaments = 50
    z_orn = np.random.uniform(0.5, height * 0.85, num_ornaments)
    r_orn = 6.2 * (1 - z_orn / height)
    theta_orn = np.random.uniform(0, 2 * np.pi, num_ornaments)
    x_orn = r_orn * np.cos(theta_orn)
    y_orn = r_orn * np.sin(theta_orn)
    colors_orn = np.random.choice(['red', 'blue'], num_ornaments)
    return (x_tree, y_tree, z_tree), (x_chain, y_chain, z_chain), (x_orn, y_orn, z_orn, colors_orn)

tree_data, chain_data, orn_data = generate_tree_data()
xt, yt, zt = tree_data
xc, yc, zc = chain_data
xo, yo, zo, co = orn_data

fig = plt.figure(figsize=(8, 8), facecolor='black')
ax = fig.add_subplot(111, projection='3d', facecolor='black')
ax.plot(xt, yt, zt, color='darkgreen', linewidth=2, alpha=0.7)
ax.plot(xc, yc, zc, color='gold', linewidth=4, alpha=0.9)
ax.scatter(xo, yo, zo, c=co, s=50, depthshade=True)
ax.scatter(0, 0, 10.2, c='yellow', marker='*', s=300)
ax.set_axis_off()
ax.grid(False)
ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_zlim(0, 10)

def update(frame_num):
    angle = frame_num * 2
    ax.view_init(elev=15, azim=angle)
    return fig,

anim = FuncAnimation(fig, update, frames=180, interval=50, blit=False)
anim.save('choinka.gif', writer='pillow', fps=20)
plt.close(fig)