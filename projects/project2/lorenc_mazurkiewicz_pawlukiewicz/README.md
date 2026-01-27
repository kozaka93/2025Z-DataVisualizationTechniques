# 📸 Analiza Galerii Zdjęć 

Projekt z Technik Wizualizacji Danych (TWD), mający na celu przekształcenie surowych danych z galerii w interaktywny dashboard. Aplikacja pokazuje nasze nawyki i preferencje co do robienia zdjęć.

## O Projekcie

Celem projektu była analiza dancyh o zdjęciach w naszych telefonach. Nasza aplikacja pozwala odpowiedzieć na pytania:
* **Gdzie** najczęściej robimy zdjęcia?
* **Kiedy** jrobimy najwięcej zdjęć (sezonowość)?
* **Co** fotografujemy? (Czy to faktycznie zdjęcia, czy tylko zrzuty ekranu?)

Raport został wygenerowany jako interaktywny plik HTML.

## Technologie

Projekt został zrealizowany w środowisku **RStudio** z wykorzystaniem języka **R**. Kluczowe biblioteki:

* **Leaflet:** Interaktywne mapy, klastrowanie punktów, warstwy satelitarne.
* **sf & rnaturalearth:** Obsługa danych geoprzestrzennych i granic państw.
* **dplyr & lubridate:** Czyszczenie danych (Data Wrangling) i obsługa stref czasowych.
* **RMarkdown:** Generowanie końcowego raportu HTML.

## Analiza Wykresów i Funkcjonalności


### 1. Struktura Galerii (Wykres 1)
![Wykres 1 - wszyscy](w1_o.png)
![Wykres 1 - Leonard](w1_l.png)
![Wykres 1 - Wojtek](w1_w.png)
![Wykres 1 - Paweł](w1_p.png)
* Wykres prezentuje ilościowy rozkład zawartości galerii, pogrupowany według typu mediów oraz ich sumarycznej liczebności. Wewnętrzne podziały kolorystyczne słupków identyfikują techniczne źródło każdego pliku, wskazując na konkretny obiektyw (np. selfie) lub pochodzenie systemowe (np. zrzut ekranu).
* Analizując wykres można dojść do wniosku, że u wszystkich z nas dominują faktyczne zdjęcia, a nie zrzuty ekranu. Widzimy też, że Paweł i Leonard preferują zdjęcia Live, gdy Wojtek woli zdjęcia statyczne.

### 2. Wykres od czasu
* Wykres pokazuje, ile każdy z nas zrobił zdjęć z podziałem na różne jednosctki czasu - mamy do wyboru ilość zdjęć w zależności od miesiąca, dnia tygodnia i pory dnia (godziny).
![Wykres 2 miesiące - wszyscy](w2_mo.png)
![Wykres 2 - Leonard](w2_ml.png)
![Wykres 2 - Wojtek](w2_mw.png)
![Wykres 2 - Paweł](w2_mp.png)
* W zależności od miesiąca - okazało się że każdy z nas robi najwięcej zdjęć w innym miesiącu / okresie roku. Dla Leonarda okazał się to styczeń i okres jesienno - zimowy, dla Wojtka grudzień i okres od sierpnia do grudnia, a dla Pawła czerwiec i okres wakacyjny.
![Wykres 2 godziny - wszyscy](w2_go.png)
![Wykres 2 - Leonard](w2_gl.png)
![Wykres 2 - Wojtek](w2_gw.png)
![Wykres 2 - Paweł](w2_gp.png)
* W zależności od pory dnia / godziny - dla nas wsyztskich okazało się że znaczną większość zdjęć wykonujemy w godzinach 9 - 22, gdzie żadna godzina nie wyróżnia się na tle pozostałych.
![Wykres 2 dni tygodnia - wszyscy](w2_do.png)
![Wykres 2 - Leonard](w2_dl.png)
![Wykres 2 - Wojtek](w2_dw.png)
![Wykres 2 - Paweł](w2_dp.png)
* W zależności od dnia tygodnia - Leonard najwięcej zdjęć robi w niedziele i zdecydowanie najmniej w poniedziałek. Wojtek najczęsciej używa aparatu w swoim telefonie w sobotę, a najrzadziej w czwartek, za to Pawełrobi najwięcej zdjęć w czwartek a najmniej w poniedziałek.



Mapa stanowi serce projektu i wizualizuje geograficzne rozmieszczenie zdjęć.
* **Klastrowanie (Grouping):** Punkty są automatycznie grupowane w klastry (liczniki), co zapobiega "zaśmieceniu" mapy przy dużej liczbie zdjęć w jednym miejscu (np. w domu).
* **Filtrowanie Czasowe:** W panelu sterowania zaimplementowano logikę pozwalającą na szybkie odseparowanie zdjęć z konkretnych miesięcy (np. *"07 Lipiec"* vs *"01 Styczeń"*).
* **Kontekst Geograficzny:** Mapa została przycięta do obszaru Europy (z wyłączeniem Rosji) dla lepszej czytelności. Dodano warstwę granic państw, co ułatwia identyfikację zagranicznych wyjazdów.
* **Wnioski z analizy:** Mapa wyraźnie pokazuje dualizm w życiu studenta/użytkownika. W miesiącach akademickich (październik-czerwiec) zdjęcia skupiają się lokalnie (miasto uczelni/dom rodzinny). W miesiącach wakacyjnych (lipiec-wrzesień) widać dużą dyspersję punktów, co koreluje z wyjazdami turystycznymi.



### 3. Interaktywna Mapa Lokalizacji 
![Mapa 1](m1.png)
![Mapa 2](m2.png)
![Mapa 3](m3.png)
* **Klastrowanie:** Punkty są automatycznie grupowane w klastry (liczniki), co zapobiega "zaśmieceniu" mapy przy dużej liczbie zdjęć w jednym miejscu (np. w domu).
* **Filtrowanie Czasowe:** W panelu sterowania zaimplementowano logikę pozwalającą na szybkie odseparowanie zdjęć z konkretnych miesięcy (np. *"07 Lipiec"* vs *"01 Styczeń"*).
* **Kontekst Geograficzny:** Mapa została przycięta do obszaru Europy dla lepszej czytelności. Dodano warstwę granic państw, co ułatwia ich identyfikację.
* **Wnioski z analizy:** Mapa wyraźnie pokazuje, że w miesiącach akademickich (październik-czerwiec) zdjęcia skupiają się lokalnie (miasto uczelni/dom rodzinny). W miesiącach wakacyjnych (lipiec-wrzesień) widać dużą dyspersję punktów, co koreluje z wyjazdami turystycznymi.





---
*Autorzy: Leonard Lorenc, Wojciech Mazurkieiwcz, Paweł Pawlukiewicz
