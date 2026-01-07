import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(2025) 
np.random.seed(2025)

plt.figure(figsize=(6, 9), facecolor='black')
plt.axis('off'); plt.xlim(-5, 5); plt.ylim(-2, 14)

plt.scatter(np.random.uniform(-5, 5, 120), np.random.uniform(-2, 14, 120), c='white', s=8, marker='*')

plt.fill([-0.6, 0.6, 0.6, -0.6], [-1, -1, 0, 0], c='brown')

h = 1.5 
pietra = 8
max_szer = 1.9

for i in range(pietra):
    szer_dol = max_szer * (pietra - i) / pietra
    szer_gora = max_szer * (pietra - (i+1)) / pietra
    
    if  i%2==0:
        kolor="forestgreen"
    else:
        kolor="limegreen"
        
    plt.fill([-szer_dol, szer_dol, szer_gora, -szer_gora], 
             [i*h, i*h, (i+1)*h, (i+1)*h], 
             c=kolor)


y = np.linspace(0.5, pietra*h - 0.5, 250)
szer_w_tym_miejscu = max_szer * (1 - y/(pietra*h)) 
plt.plot(np.sin(y*3) * szer_w_tym_miejscu, y, c='gold', lw=4, zorder=3)

for krok in range(30):
    bombka = random.uniform(0.3, pietra*h - 0.3)
    limit_x = (max_szer * (1 - bombka/(pietra*h))) * 0.85 
    plt.scatter(random.uniform(-limit_x, limit_x), bombka, c='blue', s=85, zorder=4, edgecolors='black')

plt.scatter(0, pietra*h + 0.2, c='yellow', s=500, marker='*', zorder=5)

plt.show()