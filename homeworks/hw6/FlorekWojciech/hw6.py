#%%
#pobieranie danych
import numpy as np
import matplotlib.pyplot as plt
import statsmodels.api as sm
from ucimlrepo import fetch_ucirepo 
  
# fetch dataset 
chess_king_rook_vs_king = fetch_ucirepo(id=23) 
  
# data (as pandas dataframes) 
X = chess_king_rook_vs_king.data.features 
y = chess_king_rook_vs_king.data.targets 
  
# metadata 
print(chess_king_rook_vs_king.metadata) 
  
# variable information 
print(chess_king_rook_vs_king.variables) 
#%%
#mapowanie
mapping1={'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8}
mapping2={'draw': -1, 'zero':0,'one': 1,'two':2,'three':3,'four':4,'five':5,'six':6,'seven':7,'eight':8,'nine':9,'ten':10,'eleven':11,'twelve':12,'thirteen':13,'fourteen':14,'fifteen':15,'sixteen':16}
X["white-king-file"] = X["white-king-file"].map(mapping1)
X["white-rook-file"] = X["white-rook-file"].map(mapping1)
X["black-king-file"] = X["black-king-file"].map(mapping1)
y["white-depth-of-win"] = y["white-depth-of-win"].map(mapping2)
#%%
#zad1a
indeksy1_1=y[y["white-depth-of-win"] == 0].index
dane1_1=X.loc[indeksy1_1, ["black-king-file","black-king-rank"]].value_counts()
plt.bar(range(len(dane1_1.index)),dane1_1.values)
plt.title('Pola czarnego króla zakończone matem')
plt.xlabel('Pozycja czarnego króla')
plt.ylabel('Liczba wystąpień')
plt.xticks([0, 1, 2, 3], [f"({a},{b})" for a, b in dane1_1.index])
#dla tych danych mat najczęściej jest dawany na polach a1, a2, c1, d1, czyli na krawędziach planszy.
# %%
#zad1b
indeksy1_2=y[y["white-depth-of-win"] == -1].index
dane1_2=X.loc[indeksy1_2, ["black-king-file","black-king-rank"]].value_counts()
dane1_2 = dane1_2[dane1_2 >= 50]
plt.bar(range(len(dane1_2.index)),dane1_2.values)
plt.title('Pola czarnego króla zakończone remisem')
plt.xlabel('Pozycja czarnego króla')
plt.ylabel('Liczba wystąpień')
plt.xticks(range(len(dane1_2)), [f"({a},{b})" for a, b in dane1_2.index],fontsize=7)
#dla tych danych remis najczęściej jest na 7, 6, 5 i też 8 (czyli krawędzi) wierszu.
# %%
#metryki
# euklidesa
X["euklides"] = np.sqrt((X["white-king-file"] - X["black-king-file"])**2 + (X["white-king-rank"]-X["black-king-rank"])**2)
# Manhattana
X["manhattan"] = np.abs(X["white-king-file"] - X["black-king-file"]) + np.abs(X["white-king-rank"]-X["black-king-rank"])
# Czebyszewa
X["czebyszew"] = np.maximum(np.abs(X["white-king-file"] - X["black-king-file"]), np.abs(X["white-king-rank"]-X["black-king-rank"]))

# %%
#zad2
indeksy2=y[y["white-depth-of-win"]!=-1].index
dane2X=X.loc[indeksy2]
dane2y=y.loc[indeksy2]
korelacja1_euklides=dane2X["euklides"].corr(dane2y["white-depth-of-win"])
korelacja1_manhattan=dane2X["manhattan"].corr(dane2y["white-depth-of-win"])
korelacja1_czebyszew=dane2X["czebyszew"].corr(dane2y["white-depth-of-win"])
plt.bar(["euklides","manhattan","czebyszew"],[korelacja1_euklides,korelacja1_manhattan,korelacja1_czebyszew])
plt.title('Korelacje')
plt.xlabel('metryki')
plt.ylabel('wartość')
#najlepiej spisuje się metryka manhattan, a najgorzej metryka czebyszewa jeśli chodzi o przewidywanie ilości ruchów do mata dla naszych danych.
# %%
#metryki (odleglość od krawędzi jest w linii prostej, czyli w praktyce bierzemy 1 wymiar i zakładam że bierzemy najbliższą krawędź)
#euklidesa
X["euklides2"] = np.sqrt(np.minimum(np.minimum(X["black-king-file"]-1,8-X["black-king-file"]), np.minimum(X["black-king-rank"]-1,8-X["black-king-rank"]))**2)
#manhattana
X["manhattan2"] = np.minimum(np.minimum(np.minimum(X["black-king-file"]-1,8-X["black-king-file"]), np.minimum(X["black-king-rank"]-1,8-X["black-king-rank"])),8)
#czebyszewa
X["czebyszew2"] = np.maximum(np.minimum(np.minimum(X["black-king-file"]-1,8-X["black-king-file"]), np.minimum(X["black-king-rank"]-1,8-X["black-king-rank"])),0)
#%%
#zad3a
indeksy3=y[y["white-depth-of-win"]!=-1].index
dane3X=X.loc[indeksy3]
dane3y=y.loc[indeksy3]
korelacja2_euklides=dane3X["euklides2"].corr(dane3y["white-depth-of-win"])
korelacja2_manhattan=dane3X["manhattan2"].corr(dane3y["white-depth-of-win"])
korelacja2_czebyszew=dane3X["czebyszew2"].corr(dane3y["white-depth-of-win"])
plt.bar(["euklides","manhattan","czebyszew"],[korelacja2_euklides,korelacja2_manhattan,korelacja2_czebyszew])
plt.title('Korelacje')
plt.xlabel('metryki')
plt.ylabel('korelacja')
#z powodu, że król ma do najbliższej krawędzi w 1 stronę (idzie tylko w jednym kierunku), wartości korelacji metryk są równe.
# %%
#zad3b
euklides = X[["euklides", "euklides2"]]
euklides = sm.add_constant(euklides)
model1 = sm.OLS(y["white-depth-of-win"],euklides).fit()
manhattan = X[["manhattan", "manhattan2"]]
manhattan = sm.add_constant(manhattan)
model2 = sm.OLS(y["white-depth-of-win"],manhattan).fit()
czebyszew = X[["czebyszew", "czebyszew2"]]
czebyszew = sm.add_constant(czebyszew)
model3 = sm.OLS(y["white-depth-of-win"],czebyszew).fit()
a=np.array(["euklides","manhattan","czebyszew"])
b=np.array([korelacja1_euklides,korelacja2_euklides,model1.rsquared,korelacja1_manhattan,korelacja2_manhattan,model2.rsquared,korelacja1_czebyszew,korelacja2_czebyszew,model3.rsquared])
x_idx = np.arange(3)
plt.bar(x_idx - 0.25, b[0], 0.25, label='odległość od białego króla')
plt.bar(x_idx,         b[1], 0.25, label='odległość od najbliższej krawędzi szachownicy')
plt.bar(x_idx + 0.25, b[2], 0.25, label='obie dane')
plt.xticks(x_idx, a)
plt.title('Korelacje')
plt.xlabel('metryki')
plt.ylabel('korelacja')
plt.legend(loc="lower center",bbox_to_anchor=(0.5, 1.15),ncol=3)
#dodatkowe dane typu odległość króli nie pomaga dodatkowo