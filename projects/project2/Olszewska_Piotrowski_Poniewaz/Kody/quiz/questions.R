quiz_questions <- list(

create_question(
  "Kto z nas pije najwięcej herbaty?",
  add_choice("Emilka"),
  add_choice("Bartek", correct = TRUE),
  add_choice("Kacper")
),

create_question(
  "Jak aplikacja jest najczęściej używana przez Emilkę?",
  add_choice("Youtube"),
  add_choice("Instagram"),
  add_choice("Tiktok", correct = TRUE)
),

create_question(
  "Kto z nas najwięcej czasu spędza przed ekranem?",
  add_choice("Kacper"),
  add_choice("Bartek"),
  add_choice("Emilka", correct = TRUE)
),

create_question(
  "Kto ma największy średni dzienny czas ekranowy?",
  add_choice("Kacper"),
  add_choice("Emilka", correct = TRUE),
  add_choice("Bartek")
),

create_question(
  "Kto ma najmniejszy średni dzienny czas ekranowy?",
  add_choice("Kacper"),
  add_choice("Emilka"),
  add_choice("Bartek", correct = TRUE)
),

create_question(
  "Ile wynosi średni dzienny czas ekranowy Kacpra (w godzinach)?",
  add_slider(correct = 6, min = 3, max = 15)
),

create_question(
  "Ile wynosi średni dzienny czas ekranowy Emilki (w godzinach)?",
  add_slider(correct = 9, min = 0, max = 15)
),

create_question(
  "Ile wynosi średni dzienny czas ekranowy Bartka (w godzinach)?",
  add_slider(correct = 5, min = 0, max = 15)
),

create_question(
  "Jaka jest top aplikacja Kacpra?",
  add_choice("YouTube", correct = TRUE),
  add_choice("TikTok"),
  add_choice("Discord")
),

create_question(
  "Jaka jest top aplikacja Emilki?",
  add_choice("YouTube"),
  add_choice("TikTok", correct = TRUE),
  add_choice("Instagram")
),

create_question(
  "Jaka jest top aplikacja Bartka?",
  add_choice("YouTube", correct = TRUE),
  add_choice("Discord"),
  add_choice("Instagram")
),

create_question(
  "Który dzień jest 'Dniem No-Life' Kacpra?",
  add_choice("poniedziałek", correct = TRUE),
  add_choice("środa"),
  add_choice("wtorek")
),

create_question(
  "Który dzień jest 'Dniem No-Life' Emilki?",
  add_choice("poniedziałek"),
  add_choice("środa", correct = TRUE),
  add_choice("niedziela")
),

create_question(
  "Który dzień jest 'Dniem No-Life' Bartka?",
  add_choice("poniedziałek", correct = TRUE),
  add_choice("wtorek"),
  add_choice("piątek")
),

create_question(
  "Kto ma największą średnią liczbę powiadomień dziennie?",
  add_choice("Kacper"),
  add_choice("Emilka", correct = TRUE),
  add_choice("Bartek")
),

create_question(
  "Ile wynosi średnia liczba powiadomień Emilki?",
  add_choice(623, correct = TRUE),
  add_choice(762),
  add_choice(899)
),

create_question(
  "Ile wynosi średnia liczba powiadomień Kacpra?",
  add_choice(185, correct = TRUE),
  add_choice(250),
  add_choice(325)
),

create_question(
  "Ile wynosi średnia liczba powiadomień Bartka?",
  add_choice(150, correct = TRUE),
  add_choice(200),
  add_choice(100)
),

create_question(
  "Z której aplikacji Kacper ma najwięcej powiadomień?",
  add_choice("Discord", correct = TRUE),
  add_choice("Instagram"),
  add_choice("Messenger")
),

create_question(
  "Z której aplikacji Emilka ma najwięcej powiadomień?",
  add_choice("Instagram", correct = TRUE),
  add_choice("Discord"),
  add_choice("YouTube")
),

create_question(
  "Z której aplikacji Bartek ma najwięcej powiadomień?",
  add_choice("Messenger", correct = TRUE),
  add_choice("Discord"),
  add_choice("Chrome")
),

create_question(
  "Jaki jest 'Złodziej' powiadomień u Kacpra?",
  add_choice("Youtube", correct = TRUE),
  add_choice("Dokumenty"),
  add_choice("Chrome")
),

create_question(
  "Jaki jest 'Złodziej' powiadomień u Emilki?",
  add_choice("Chrome"),
  add_choice("Dokumenty", correct = TRUE),
  add_choice("Mihon")
),

create_question(
  "Jaki jest 'Złodziej' powiadomień u Bartka?",
  add_choice("Chrome"),
  add_choice("Dokumenty"),
  add_choice("Youtube", correct = TRUE)
),

create_question(
  "Kto ma najwyższą średnią długość snu?",
  add_choice("Kacper"),
  add_choice("Emilka", correct = TRUE),
  add_choice("Bartek")
),

create_question(
  "Ile średnio trwa sen Emilki (w godzinach)?",
  add_slider(correct = 7, min = 0, max = 12)
),

create_question(
  "Ile średnio trwa sen Kacpra (w godzinach)?",
  add_slider(correct = 6, min = 0, max = 12)
),

create_question(
  "Ile średnio trwa sen Bartka (w godzinach)?",
  add_slider(correct = 6, min = 0, max = 12)
),

create_question(
  "O której Emilka zazwyczaj wstaje?",
  add_choice("07:20"),
  add_choice("10:03", correct = TRUE),
  add_choice("06:30")
),

create_question(
  "O której Kacper zazwyczaj wstaje?",
  add_choice("07:20", correct = TRUE),
  add_choice("10:03"),
  add_choice("08:45")
),

create_question(
  "Kto spożywa najwięcej kofeiny?",
  add_choice("Kacper"),
  add_choice("Emilka"),
  add_choice("Bartek", correct = TRUE)
),

create_question(
  "Która osoba ma jednocześnie: top aplikację YouTube ORAZ 'najmniej snu: poniedziałek'?",
  add_choice("Kacper", correct = TRUE),
  add_choice("Emilka"),
  add_choice("Bartek")
)

)