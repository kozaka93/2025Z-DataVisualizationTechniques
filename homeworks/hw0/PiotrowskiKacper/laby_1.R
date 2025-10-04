###########################################
###    TECHNIKI WIZUALIZACJI DANYCH     ###
###           LABORATORIUM 1            ###
###########################################


# 0. Prowadzący  -------------------------------------------------------------

# Anna Kozak/Antoni Chudy/Iza Danielewska/Dawid Płudowski/Katarzyna Woźnica
# Kontakt: MS Teams lub mail


# 1. Sposób pracy na zajęciach laboratoryjnych -------------------------------

# a) pracujemy w R (większość semestru) i Python
# b) pracujemy na przygotowanych plikach, które będą na repozytorium przedmiotu
# c) podczas zajęć prowadzący będzie wprowadzał zagdanienia, a następnie będzie rozwiązywanie zadań w celu utrwalenia wiadomości
# d) kolejna porcja materiału będzie omawiana jeżeli większość grupy wykona zadane zadanie 
# e) wszelkie pytania czy to związane z kodem, pracą domową czy kwestie teoretyczne proszę śmiało zgłaszać prowadzącemu 


# 2. Materiały ------------------------------------------------------------

# Repozytorium na GitHub
# https://github.com/kozaka93/2025Z-DataVisualizationTechniques


# 3. Jak działa GitHub? ---------------------------------------------------

# Jak zgłosić pracę domową/projekt? (fork, commit, pull request)
# https://rogerdudler.github.io/git-guide/


# 4. Podstawy R - rozgrzewka ----------------------------------------------

data(mtcars)
head(mtcars)

mtcars[c(1,2), c(1,2,3)]
mtcars$mpg
?mtcars
colname <- c("mpg")
mtcars[colname]

# Jak wybieramy wiersze (obserwacje) oraz kolumny (zmienne)?


# Pierwszy wiersz, pierwsza kolumna?


# 10 pierszych wierszy, 2 i 3 kolumna?


# Jak wybieramy kolumny po nazwach? 


# Wszystkie wiersze i kolumny w kolejności "am", "wt", "mpg"?


# Jak wybierać jedną kolumnę?

# Uwaga na przecinek i wybór kolumn poprzez indeksy

# Pytania

# 1. Wymiar ramki danych
dim(mtcars)

# 2. Jakie są typy zmiennych?
str(mtcars)


# 3. Ile jest unikalnych wartości zmiennej "cyl" i jakie to są wartości?
unique(mtcars["cyl"])


# 4. Jaka jest średnia wartość zmiennej "drat" dla samochodów 
# o wartości zmiennej "cyl" równej 4?

mean(mtcars[mtcars$cyl == 4, "drat"])

# 5. Jakie są unikalne wartości zmiennej "am" i jaki jest ich rozkład (liczba wystąpień)? 
table(mtcars$am)

# Prosty wykres
plot(mtcars$mpg, mtcars$hp)

# Zależność "mpg" i "hp" - scatter plot


# Zmienna "cyl" - barplot
barplot(table(mtcars$cyl))

# 5. Zadanie "proton" -----------------------------------------------------

# Utwórz nowy plik .R. Zainstaluj/uruchom pakiet proton:
install.packages("proton")
library(proton)

# W pliku zapisuj sposób rozwiązania gry.
proton()
employees
employees[employees$surname == "Insecure",]
proton(action = "login", login="johnins")
top1000passwords
proton(action = "login", login="johnins", password="123456")
max(table(top1000passwords))
# 6. Zamieszczamy rozwiązanie na repozytorium -----------------------------
for (el in top1000passwords) {
  if (proton(action="login", login="johnins", password=el) == "Success! User is logged in!") {
    passw <- el
    }
}
res <- sapply(top1000passwords, function(x) proton(action="login", login="johnins", password=x))
res

for (el in top1000passwords) {
  print(el)
}
proton(action = "login", login="johnins", password=passw)

proton(action = "server", host="XYZ")

proton(action="server")
employees[employees$surname == "Pietraszko",]
logs[logs$login == "slap",]
logs_pietr <- logs[logs$login == "slap",]
which.max(table(logs_pietr$host))
host_max <- "194.29.178.16"
proton(action="server", host=host_max)
bash_history
unique(gsub(" .*$", "", bash_history))
proton(action="login", login="slap", password="DHbb7QXppuHnaXGN")
