import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap

MATRIX_SIZE = 301
MIDDLE = 150
NUM_BRANCHES = 20


def create_empty_matrix(size):
    return np.zeros((size, size), dtype=int)

def draw_tree_trunk(matrix, middle):
    matrix[130:300, middle-2:middle+1] = 1
    return matrix

def draw_tree_boundaries(matrix, middle):
    # Lewa granica
    x = 50
    y = 300
    while x < middle:
        matrix[y-2:y, x-40:x] = 2
        x += 1
        y -= 2
    
    # Prawa granica
    x = 250
    y = 300
    while x > middle:
        matrix[y-2:y, x:x+40] = 2
        x -= 1
        y -= 2
    
    return matrix

def add_branches(matrix, ys, middle):
    for y_start in ys:
        # Rysowanie prawej gałęzi
        x = middle
        y = y_start
        
        while y < 300 and x < 300:
            next_x = x + 9
            if next_x + 10 >= 301:
                break
            if np.any(matrix[y-1:y+1, next_x:next_x+11] == 2):
                break
            
            matrix[y, x:x+10] = 1
            matrix[y-1:y+2, x+9:x+12] = np.random.choice([3, 4, 5, 6])
            left_x = middle - (x - middle)
            
            if left_x - 10 < 0:
                break
            
            matrix[y, left_x-10:left_x] = 1
            matrix[y-1:y+2, left_x-10:left_x-7] = np.random.choice([3, 4, 5, 6])
            
            x = next_x
            y -= 1
    return matrix

def add_star(matrix):
    center_y = 130
    center_x = MIDDLE-1
    radius = 7
    
    for y in range(center_y - radius, center_y + radius + 1):
        for x in range(center_x - radius, center_x + radius + 1):
            if (y - center_y)**2 + (x - center_x)**2 <= radius**2:
                matrix[y, x] = 7
    
    return matrix

def main():
    # dane dla ktorych robimy wykres 
    matrix = create_empty_matrix(MATRIX_SIZE)
    matrix = draw_tree_trunk(matrix, MIDDLE)
    matrix = draw_tree_boundaries(matrix, MIDDLE)
    branch_heights = np.linspace(300, 100, NUM_BRANCHES, dtype=int)[1:-1]
    matrix = add_branches(matrix, branch_heights, MIDDLE)
    matrix = add_star(matrix)
    
    cmap = ListedColormap([
        'lightblue',  # 
        'green',      # choinka
        'lightblue',  # granice (taki sam kolor jak tlo)
        'red',        # bombki
        'blue',       # 
        'orange',     # 
        'purple',     # 
        'yellow'      # gwiazda
    ])


    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(matrix, cmap=cmap, interpolation='nearest')
    ax.text(
        MIDDLE, 
        30, 
        'Wesołych Świąt!',
        fontsize=20,
        color='black',
        ha='center',
        va='center'
    )

    ax.axis('off')
    plt.savefig('choinka.png', dpi=300, bbox_inches='tight', pad_inches=0.1)
    plt.show()

if __name__ == "__main__":
    main()