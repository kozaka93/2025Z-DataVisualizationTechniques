import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

#======GENEROWANIE PUNKTOW CHOINKI======

def choinka(liscie=4500, bombki=100):
    #generowanie punktow
    x = np.random.uniform(-0.5, 0.5, liscie)
    y = np.random.uniform(0, 1, liscie)
    
    #wybieranie tylko tych punktow, ktore tworza choinke
    good_values = np.abs(x) < 0.55 * (1 - y)
    x_choinka = x[good_values]
    y_choinka = y[good_values]
    
    #generowanie bombek w taki sam sposob
    x_b = np.random.uniform(-0.5, 0.5, bombki)
    y_b = np.random.uniform(0, 1, bombki)
    good_values_b = np.abs(x_b) < 0.55 * (1 - y_b)
    x_bombki = x_b[good_values_b]
    y_bombki = y_b[good_values_b]

    #generowanie sniegu
    x_snieg = np.random.uniform(-1, 1, 100)
    y_snieg = np.random.uniform(0, 1.2, 100)

    return (x_choinka, y_choinka), (x_bombki, y_bombki), (x_snieg, y_snieg)

(x_choinka, y_choinka), (x_bombki, y_bombki), (x_snieg, y_snieg) = choinka()

#======TWORZENIE CHOINKI======

fig, ax = plt.subplots(figsize=(6, 8), facecolor="#11114e")
ax.set_facecolor("#11114e")
ax.set_xticks([])
ax.set_yticks([])
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["bottom"].set_visible(False)
ax.spines["left"].set_visible(False)

ax.scatter(x_choinka, y_choinka, c="darkgreen", s=11, marker="D") #choinka
ax.scatter([0], [1], c="gold", s=350, marker="*", zorder=3) #gwiazda
ax.plot([0, 0], [0, -0.1], c="brown", linewidth=12, zorder=1) #pien choinki
bombki = ax.scatter(x_bombki, y_bombki, s=35, zorder=2) #bombki
snieg = ax.scatter(x_snieg, y_snieg, c="white", s=20, zorder=4) #snieg

ax.set_title("Wesołych świąt!", color="white", fontsize=22)

#======ANIMOWANIE======

kolory_lista = np.array(["#ff0000", "#ffff00", "#00ff15", "#00f7ff", "#8c00ff"])

def animacja(frame):
    snieg_pozycja = snieg.get_offsets()
    snieg_pozycja[:, 1] -= 0.003 #przesuwam w dół lekko na osi Y
    
    reset = snieg_pozycja[:, 1] < -0.1 #ten snieg ktory jest za nisko powinien sie resetowac
    snieg_pozycja[reset, 1] = 1.2 #wraca na gore
    
    snieg.set_offsets(snieg_pozycja)

    if frame % 10 == 0: #miganie bombek
        kolory = np.random.choice(kolory_lista, len(x_bombki))
        bombki.set_color(kolory)
    return snieg, bombki

anim = FuncAnimation(fig, animacja, frames=200, interval=50)

anim.save("choinka.gif")
plt.show()
