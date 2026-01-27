import numpy as np
import matplotlib.pyplot as plt
import random

layers = 20             
points_per_layer = 50    
tree_height = 15
tree_radius = 6
x = []
y = []
z = []
colors = []

for i in range(layers):
    zt = i * (tree_height / layers)  
    radius = tree_radius * (1 - i / layers)  
    for j in range(points_per_layer):
        theta = 2 * np.pi * j / points_per_layer + i * 0.3  
        xt = radius * np.cos(theta)
        yt = radius * np.sin(theta)
        x.append(xt)
        y.append(yt)
        z.append(zt)
        colors.append('green')

num_ozd = 50
ozd = random.sample(range(len(x)), num_ozd)
for i in ozd:
    colors[i] = random.choice(['red','yellow','cyan','magenta'])

num_snow = 200
snow_x = [random.uniform(-10, 10) for _ in range(num_snow)]
snow_y = [random.uniform(-10, 10) for _ in range(num_snow)]
snow_z = [random.uniform(0, tree_height + 5) for _ in range(num_snow)]

fig = plt.figure(figsize=(8,12))
ax = fig.add_subplot(111, projection='3d')
ax.set_facecolor('midnightblue')
fig.patch.set_facecolor('midnightblue')
ax.scatter(x, y, z, c=colors, s=20)
trunkh = tree_height * 0.1
trunkr = tree_radius * 0.2
trunkz = np.linspace(-trunkh, 0, 10)
trunkt = np.linspace(0, 2*np.pi, 20)
trunkt, trunkzz = np.meshgrid(trunkt, trunkz)
trunkx = trunkr * np.cos(trunkt)
trunky = trunkr * np.sin(trunkt)
ax.plot_surface(trunkx, trunky, trunkzz, color='brown')
ax.scatter(0, 0, tree_height + 0.5, color='gold', s=500, marker='*')
ax.scatter(snow_x, snow_y, snow_z, color='white', s=8, alpha=0.4)
ax.set_axis_off()
ax.set_title("Wesołych świąt!", fontsize=16, color='white')
plt.tight_layout()
plt.savefig("drzewko.png", dpi=300)
plt.show()