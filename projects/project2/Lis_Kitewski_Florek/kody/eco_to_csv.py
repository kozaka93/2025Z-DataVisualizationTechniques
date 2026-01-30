# %%
import numpy as np
import pandas as pd

# %%
# Dane: https://github.com/lichess-org/chess-openings
#pliki=np.array(["a","b","c","d","e"])
#pliki="openings\\"+pliki+".tsv"
litery=["a","b","c","d","e"]
pliki = [f"openings\\{l}.tsv" for l in litery]
df2 = pd.concat(
    [pd.read_csv(p, sep="\t") for p in pliki],
    ignore_index=True
)
# %%

### Da się zrobić dużo lepiej, ale tak też działa
ruchy=df2.loc[:,"pgn"].str.split(" ")
for i in ruchy:
    for j in i:
        if(j[-1]=="."):
            i.remove(j)
for i in range(0, len(ruchy)):
    ruchy[i]="".join(ruchy[i])
df2.loc[:,"Ruchy_str"] = ruchy

# %%
games = pd.read_csv("full_moves.csv") 
games_small = games.loc[:,["game_id","move_no","move_sequence","fen"]]
# %%
games_small.loc[:,"Ruchy_str"] = games_small.loc[:,"move_sequence"].str.replace("|","")
# %%

wynik=pd.merge(games_small,df2,left_on="Ruchy_str",right_on="Ruchy_str",how="left")
wynik.to_csv("debiuty.csv")


# %%
df2.to_csv("lista_debiut.csv")
# %%
