import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

plt.style.use('dark_background')

data = {
    "2022": [14389143, 7386496, 4559480, 4406241, 2868012],
    "2023": [18472491, 9399281, 5895934, 5594130, 3880957],
    "2024": [21261806, 11071697, 6698533, 6363559, 4467264],
}

airports = [
    "Warszawa",
    "Kraków",
    "Gdańsk",
    "Katowice",
    "Wrocław"
]

df = pd.DataFrame(data, index=airports)

def millions_formatter(x, pos):
    """Formatuje liczbę na string 'X.Y mln'"""
    return f'{x/1_000_000:.1f}'

formatter = mtick.FuncFormatter(millions_formatter)

blue_shades = ['#66B2FF', '#007FFF', '#0059B3']

print("Generowanie wykresu z czarnym tłem i większą legendą...")

fig = plt.figure(figsize=(12, 7))
fig.patch.set_facecolor('black')

ax = plt.gca()

df.plot(kind='bar', color=blue_shades, ax=ax)

ax.set_facecolor('black')

ax.set_title('Passenger Top 5 Traffic by Airport in Poland (2022-2024)', fontsize=16, pad=20)
ax.set_ylabel('Number of Passengers [mln]', fontsize=20)
ax.set_xlabel('Airport city', fontsize=20)

legend = ax.legend(title='Year', fontsize=20)
plt.setp(legend.get_title(), color='white', fontsize=20)

plt.xticks(rotation=0)
ax.yaxis.set_major_formatter(formatter)

plt.grid(axis='y', linestyle='--', alpha=0.4, color='gray')
plt.grid(axis='x', which='both', visible=False)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['left'].set_visible(False)

ax.tick_params(axis='x', length=0, labelsize=18)
ax.tick_params(axis='y', length=0, labelsize=18)

plt.tight_layout()

plt.show()