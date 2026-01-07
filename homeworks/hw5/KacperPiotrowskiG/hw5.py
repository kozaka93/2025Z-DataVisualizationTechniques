import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.collections import LineCollection

NP_SEED = 202512
TREE_HEIGHT = 10
TREE_WIDTH_BASE = 5
N_BRANCHES = 3000   
N_SNOWFLAKES = 300
N_BAUBLES = 40
BAUBLE_SIZE = 190
MIN_DIST = 0.8
CAP_SIZE = 30       
CAP_OFFSET = 0.28   
DURATION_SEC = 8    
FPS = 20
TOTAL_FRAMES = DURATION_SEC * FPS

np.random.seed(NP_SEED)

def generate_branch_segments(n, height, width_base):
    ys = np.random.uniform(0, height, n)
    current_width_limit = (width_base / 2) * (1 - (ys / height)**1.1)
    xs = np.random.uniform(-current_width_limit, current_width_limit, n)
    lengths = np.random.uniform(0.1, 0.4, n) * (1 - 0.6*(ys/height))
    angles = np.random.uniform(np.pi * 1.1, np.pi * 1.9, n)
    xe = xs + lengths * np.cos(angles) + np.random.uniform(-0.05, 0.05, n)
    ye = ys + lengths * np.sin(angles)
    segments = np.stack((np.c_[xs, ys], np.c_[xe, ye]), axis=1)
    return segments, ys

def generate_textured_trunk(height, width, n_lines=70):
    y_start = np.linspace(-0.8, -0.8, n_lines)
    y_end = np.linspace(1.2, 1.2, n_lines)
    x_pos = np.random.uniform(-width/2, width/2, n_lines)
    x_start = x_pos + np.random.uniform(-0.08, 0.08, n_lines)
    x_end = x_pos + np.random.uniform(-0.08, 0.08, n_lines)
    segments = np.stack((np.c_[x_start, y_start], np.c_[x_end, y_end]), axis=1)
    browns = ['#3d2817', '#5c3a1e', '#4a2e18', '#2e1e12']
    colors = np.random.choice(browns, n_lines)
    return segments, colors

def generate_smart_baubles(n, height, width_base, min_dist):
    palette = ['#DC143C', '#FFD700', '#1E90FF', '#FF69B4', '#32CD32', '#FFA500']
    repeats = int(np.ceil(n / len(palette)))
    full_colors = (palette * repeats)[:n]
    np.random.shuffle(full_colors)
    
    accepted_x = []
    accepted_y = []
    
    attempts = 0
    max_attempts = n * 200
    
    while len(accepted_x) < n and attempts < max_attempts:
        attempts += 1
        
        y_cand = np.random.uniform(0.8, height - 1.2)
        x_lim = (width_base / 2) * (1 - (y_cand / height)) * 0.75
        x_cand = np.random.uniform(-x_lim, x_lim)
        
        collision = False
        for i in range(len(accepted_x)):
            dist = np.sqrt((x_cand - accepted_x[i])**2 + (y_cand - accepted_y[i])**2)
            if dist < min_dist:
                collision = True
                break
        
        if not collision:
            accepted_x.append(x_cand)
            accepted_y.append(y_cand)
            
    return np.array(accepted_x), np.array(accepted_y), np.array(full_colors[:len(accepted_x)])

def generate_snow_data(n_flakes, x_lim, y_lim):
    x = np.random.uniform(x_lim[0], x_lim[1], n_flakes)
    y = np.random.uniform(y_lim[0], y_lim[1], n_flakes)
    sizes = np.random.uniform(5, 20, n_flakes)
    return x, y, sizes

tree_segs, tree_ys = generate_branch_segments(N_BRANCHES, TREE_HEIGHT, TREE_WIDTH_BASE)
sort_idx = np.argsort(tree_ys)
tree_segs = tree_segs[sort_idx]
tree_ys = tree_ys[sort_idx]
tree_colors = plt.cm.summer(np.linspace(0, 1, N_BRANCHES))
tree_colors[:, :3] *= 0.55 
tree_colors = tree_colors[sort_idx]

trunk_segs, trunk_colors = generate_textured_trunk(height=2.0, width=1.0)
bauble_x, bauble_y, bauble_c = generate_smart_baubles(N_BAUBLES, TREE_HEIGHT, TREE_WIDTH_BASE, MIN_DIST)
snow_x, snow_y, snow_sizes = generate_snow_data(N_SNOWFLAKES, (-5, 5), (-2, 13))

fig, ax = plt.subplots(figsize=(7, 9), facecolor='#02020a')
ax.set_facecolor('#02020a')
ax.set_xlim(-4, 4)
ax.set_ylim(-1.5, 11.5)
ax.axis('off')

scat_snow = ax.scatter(snow_x, snow_y, s=snow_sizes, c='white', alpha=0.6, edgecolors='none', zorder=1)
trunk_col = LineCollection(trunk_segs, colors=trunk_colors, linewidths=4, zorder=2)
ax.add_collection(trunk_col)
tree_collection = LineCollection([], linewidths=1.3, zorder=3)
ax.add_collection(tree_collection)

scat_caps = ax.scatter([], [], s=CAP_SIZE, marker='s', c='#DAA520', edgecolors='none', zorder=4)
scat_baubles = ax.scatter([], [], s=BAUBLE_SIZE, marker='o', edgecolors='none', zorder=5, alpha=1.0)

star, = ax.plot([], [], '*', color='#ffd700', markersize=35, 
                markeredgecolor='#ffae42', markeredgewidth=2, zorder=6)
star_glow, = ax.plot([], [], 'o', color='#ffd700', markersize=70, alpha=0.1, zorder=5)

title_text = ax.text(0, -1.8, "Optymalizacja rozmieszczenia...", color='#87ceeb', ha='center', fontsize=13, family='monospace')

def update(frame):
    global snow_y
    build_end_frame = TOTAL_FRAMES * 0.75
    progress = min(1.0, frame / build_end_frame)
    
    delayed_progress = max(0, (progress - 0.3) / 0.7)
    bauble_progress = delayed_progress ** 2
    
    snow_y -= (snow_sizes * 0.007 + 0.03)
    reset_mask = snow_y < -2
    snow_y[reset_mask] = 13 + np.random.uniform(0, 1, np.sum(reset_mask))
    snow_x[reset_mask] = np.random.uniform(-5, 5, np.sum(reset_mask))
    scat_snow.set_offsets(np.c_[snow_x, snow_y])

    count = int(N_BRANCHES * progress)
    tree_collection.set_segments(tree_segs[:count])
    tree_collection.set_color(tree_colors[:count])

    total_generated = len(bauble_x)
    b_count = int(total_generated * bauble_progress)
    
    if b_count > 0:
        b_sort_idx = np.argsort(bauble_y)
        bx_s = bauble_x[b_sort_idx][:b_count]
        by_s = bauble_y[b_sort_idx][:b_count]
        bc_s = bauble_c[b_sort_idx][:b_count]
        
        scat_baubles.set_offsets(np.c_[bx_s, by_s])
        scat_baubles.set_facecolors(bc_s)
        scat_caps.set_offsets(np.c_[bx_s, by_s + CAP_OFFSET])
    
    if progress >= 0.99:
        star.set_data([0], [TREE_HEIGHT + 0.2])
        star_glow.set_data([0], [TREE_HEIGHT + 0.2])
        pulse = (np.sin(frame * 0.25) + 1) / 2
        star.set_markersize(35 + 5 * pulse)
        star_glow.set_markersize(70 + 15 * pulse)
        star_glow.set_alpha(0.1 + 0.2 * pulse)
        title_text.set_text("Wesołych Świąt!")
        title_text.set_color('#FFD700')
    else:
        title_text.set_text(f"Dekorowanie: {int(progress*100)}%")

    return tree_collection, scat_baubles, scat_caps, scat_snow, star, star_glow, title_text

anim = FuncAnimation(fig, update, frames=TOTAL_FRAMES, interval=1000/FPS, blit=True)

output_file = 'choinka.gif'
anim.save(output_file, writer='pillow', fps=FPS, savefig_kwargs={'facecolor':'#02020a'})
plt.close()