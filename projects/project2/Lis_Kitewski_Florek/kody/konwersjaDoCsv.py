# %%
from converter.pgn_data import PGNData
from os import listdir
# %%
dirname = "chess_games\\janek"
games=os.listdir(dirname)

for i in range(0, len(games)):
    games[i]=dirname+"\\"+games[i]

# %%
pgn_data = PGNData(games,"output")
result = pgn_data.export()
result.print_summary()
# %%


# %%
dirname2 = "chess_games\\bartek"
games2 = os.listdir(dirname2)

for i in range(0, len(games2)):
    games2[i] = dirname2 + "\\" + games2[i]

# %%
pgn_data = PGNData(games2, "output2")
result = pgn_data.export()
result.print_summary()

#%%
dirname3 = "chess_games\\wojtek"
games3 = os.listdir(dirname3)

for i in range(0, len(games3)):
    games3[i] = dirname3 + "\\" + games3[i]

#%%
pgn_data = PGNData(games3, "output3")
result = pgn_data.export()
result.print_summary()

# Zapisuję w output2 a nie w output, ponieważ github nie zbiera plików powyżej 100
# 100 MB. Proponuję, żeby później wrzucić te ramki do SQL pewnie, że by szybciej się otwierały.
# można też zrobić tak prowizorycznie na razie, że każdy będzie trzymał w folderze nad tym i każdy oddzielnie zmerguje sobie te pgn.
# W skrócie możemy to jeszcze ustalić. Niektóre kolumny w sumie i tak będzie można wyrzucić,
# np. uct time. Ale i tak output_moves2 jest zbyt duży.
#I jestem za sqlite3 do przechowywania ramek danych. Powinno być łatwiej.
## %

# %%
# Full, lepiej pewnie jakoś złączyć pojedyńcze csv ale nie
# znalazłem równie prostego sposobu jak po prostu jeszcze raz wywołanie
# tej funkcji ale na wszystkim
dirname4 = "chess_games\\full"
games4 = os.listdir(dirname4)

for i in range(0, len(games4)):
    games4[i] = dirname4 + "\\" + games4[i]

#%%
pgn_data = PGNData(games4, "full")
result = pgn_data.export()
result.print_summary()
# %%
