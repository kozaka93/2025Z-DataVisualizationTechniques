library(stringi)
library(dplyr)
library(lubridate)
cleaning_data_ania<-function(sciezka,data_poczatek,data_koniec)
{
  data_poczatek<-as_date(data_poczatek)
  data_koniec<-as_date(data_koniec)
  
  
  rozrywka <- c(
    "Instagram","YouTube","Netflix","Disney+","Spotify",
    "Pinterest","BeReal.","Sliding Seas","Cinema City","Letterboxd",
    "YouTube Music","Gaming Hub","Killer Sudoku",
    "Stardew Valley"
  )
  
  zakupy <- c(
    "Zalando","Allegro","OLX.pl","Rossmann","Vinted",
    "Biedronka","Pyszne","InPost Mobile","DPD Mobile",
    "Reserved","Stradivarius","IKO","Caffe Nero",
    "Empik","McDonald's","żappka","Revolut","mBank"
  )
  
  
  komunikacja <- c(
    "Facebook","Messenger","WhatsApp","Gmail",
    "df","Kontakty",
    "Phone","Call","Messages","YourPhoneAppProxy","Discord"
  )
  
  nauka <- c(
    "Duolingo","Mobilny USOS PW","ChatGPT","ANTON",
    "Todoist","TimeTree","Arkusze","Tlumacz",
    "Pracuj.pl","Teams","Outlook",
    "Code","rstudio","MATLAB","WindowsTerminal",
    "rsession-utf8","Notepad","ONENOTE","Acrobat",
    "Notion","Samsung Notes","OneNote",
    "Docs","EXCEL","Dysk","Rgui",
    "eclipse",
    "studio64","Teams"
  )
  
  podroze <- c(
    "Jakdojade","PKP INTERCITY","Mapy","Pogoda",
    "Bolt","Android Auto","Skiline","Mio Trentino","Booking.com",
    "mini.forecasts","WeatherApp"
  )
  
  zdjecia <- c(
    "Aparat","Zdjecia","Zdjecia i filmy",
    "Galeria","Edytor Galerii","Media viewer","Skaner","Photos",
    "Photo Editor","Photoroom","Studio",
    "Media picker","Samsung capture",
    "SnippingTool","ScreenClippingHost"
  )
  
  przegladarka <- c(
    "Chrome","Google","Mi Przegladarka",
    "Samsung Internet","opera"
  )
  
  narzedzia <- c(
    "Pliki","Menedzer plikow",
    "Kalkulator","Zegar","Kalendarz",
    "Notatki","Menedzer danych logowania",
    "My Files","Files","Drive","OneDrive",
    "Settings","Ustawienia","Clock","Calculator",
    "Device care","Software update",
    "Wallpaper and style","Modes and Routines",
    "Key Chain","Authenticator",
    "Permission controller","IntentResolver",
    "Google Play Store","Galaxy Store",
    "Google Play services","Meta App Manager",
    "Malwarebytes","RescueTime",
    "Digital Wellbeing"
  )
  
  sport_zdrowie <- c(
    "Cyfrowa rownowaga","Cyfrowy dobrostan","StayFree","Strava","Flo"
  )
  
  df<-data.frame(read.csv(sciezka))
  df$data.app<-stri_trans_general(df$data.app, "Latin-ASCII")
  
  df<-df %>% 
    mutate(data=as_date(as.POSIXct(df$timestamp))) %>% 
    filter((data>=data_poczatek)&(data<=data_koniec))
  
  shiny::validate(need(nrow(df) > 0, "Brak danych w wybranym zakresie."))
  
  df<-df %>% 
    mutate(cat=case_when(df$data.app %in% rozrywka ~ "rozrywka",
                         df$data.app %in% komunikacja ~ "komunikacja",
                         df$data.app %in% nauka ~ "nauka",
                         df$data.app %in% zakupy ~ "zakupy",
                         df$data.app %in% podroze ~ "podróże",
                         df$data.app %in% zdjecia ~ "zdjęcia",
                         df$data.app %in% przegladarka ~ "przeglądarka",
                         df$data.app %in% narzedzia ~ "narzędzia",
                         df$data.app %in% sport_zdrowie ~ "sport i zdrowie",
                         TRUE ~ "inne")) %>% 
    filter(cat!="inne")
  return(df)}


