import pandas as pd
import glob
import os

sciezka= "sciezka_do_folderu_z_jsonami"
plik_wynikowy = 'nazwa_pliku.csv'

pliki_json = glob.glob(os.path.join(sciezka, '*.json'))

lista_danych = []
for plik in pliki_json:
    try:
        df = pd.read_json(plik)
        lista_danych.append(df)
    except ValueError as e:
        print(f"Pominięto plik {plik} z powodu błędu: {e}")

if lista_danych:
    calosc = pd.concat(lista_danych, ignore_index=True)
    
    calosc.to_csv(plik_wynikowy, index=False, encoding='utf-8')
    print(f"Gotowe! Zapisano {len(calosc)} wierszy w pliku {plik_wynikowy}")
else:
    print("Nie znaleziono plików JSON.")
