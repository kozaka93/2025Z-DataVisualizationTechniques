library(shiny)
library(dplyr)
library(shinydashboard)
library(plotly)
library(shinyWidgets)
library(lubridate) 
library(rvest)
library(stringr)
library(dplyr)
library(tibble)

miesiace_pl <- c("Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec", "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień")
kolor1 <- "#f77464"
kolor2 <- "#30d5c8"

### Karolina dane
dane <- read.csv("https://raw.githubusercontent.com/Jedrek2/twd-projekt-2/refs/heads/main/projekt2/dane_koncowe_ksiazki.csv",sep = ";",header = TRUE)

przeczytane <- dane %>%
  filter(Date.Read != "")%>%
  mutate(Date.Read = as.Date(Date.Read, format = "%Y/%m/%d"))%>%
  mutate(year = as.integer(format(Date.Read, "%Y")),
         month = as.integer(format(Date.Read, "%m")))
oceny <- przeczytane %>%
  mutate(my_rating = as.numeric(My.Rating),
         avg_rating = as.numeric(Average.Rating)) %>%
  filter(!is.na(my_rating),
         !is.na(avg_rating))

### Jędrzej dane
df<-read.csv("https://raw.githubusercontent.com/Jedrek2/twd-projekt-2/refs/heads/main/projekt2/wiadomosci.csv")
df2<-read.csv("https://raw.githubusercontent.com/Jedrek2/twd-projekt-2/refs/heads/main/projekt2/wiadomosci_przetworzone.csv")
x <- theme(
  panel.background = element_rect(fill = "#F5F7FA", color = NA),
  plot.background  = element_rect(fill = "#F5F7FA", color = NA),
  panel.grid.major.x = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major.y = element_line(color = "#E0E6ED"),
  axis.title = element_text(size = 12),
  axis.text  = element_text(size = 11, color = "#333333"),
  plot.title = element_text(face = "bold", size = 16),
  plot.subtitle = element_text(size = 11, color = "#666666"),
  plot.margin = margin(12, 16, 12, 16)
)
### GABRIELA START

# polskie nazwy miesięcy
Sys.setlocale("LC_TIME", "pl_PL")

# wczytanie pliku HTML (z rozszerzeniem .java)
html <- read_html("https://raw.githubusercontent.com/Jedrek2/twd-projekt-2/refs/heads/main/projekt2/historia.java", encoding = "UTF-8")

# Każdy wpis YouTube
entries <- html %>%
  html_elements("div.outer-cell")

# Tytuł filmu
titles <- entries %>%
  html_element("a[href*='youtube.com/watch']") %>%
  html_text(trim = TRUE)

# Nazwa kanału
channels <- entries %>%
  html_element("a[href*='youtube.com/channel']") %>%
  html_text(trim = TRUE)

# Surowy tekst z datą
dates_raw <- entries %>%
  html_element("div.mdl-typography--body-1") %>%
  html_text()

# Wyciągnięcie daty
dates <- str_extract(
  dates_raw,
  "\\d{1,2} \\w+ \\d{4}, \\d{2}:\\d{2}:\\d{2} CET"
)

# Konwersja do POSIXct
dates_parsed <- as.POSIXct(
  dates,
  format = "%d %b %Y, %H:%M:%S CET",
  tz = "CET"
)

# Ramka danych
youtube_history <- tibble(
  title   = titles,
  channel = channels,
  date    = dates_parsed
)

df_youtube <- data.frame(
  data_publikacji = youtube_history$date,
  tytul_filmu = youtube_history$title,
  stringsAsFactors = FALSE  # Ważne w starszych wersjach R, aby tekst nie stał się 'factorem'
)

# przerobka danych
df_youtube$data_clean <- as.POSIXct(df_youtube$data_publikacji, format="%d %b %y, %H:%M:%S", tz="CET")
df_youtube$miesiac <- floor_date(df_youtube$data_clean, "month")


ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Analiza hobby"),
  dashboardSidebar(
    selectInput("wybranaOsoba", "Wybierz osobę:", choices = c("", "Gabriela", "Jędrzej","Karolina"), selected = ""),
    sidebarMenu(
      menuItem("Panel główny",tabName = "info", icon = icon("info-circle")),
      menuItem("Analizy", tabName = "analizy", icon = icon("chart-bar")))
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        @import url('https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,300;0,400;0,700;1,400&display=swap');
        body,h1, h2, h5, p,
        .sidebar, .main-header, .content-wrapper {
          font-family: 'Lato', 'Segoe UI', Arial, sans-serif;
        }
        .skin-black .main-header .navbar,
        .skin-black .main-header .logo {
          background-color: #0f1113 !important;
          color: #ffffff !important;
        }
        .skin-black .main-sidebar {
          background-color: #14181c;
        }
        .skin-black .sidebar-menu > li > a {
          color: #cfd8dc;
        }
        .skin-black .sidebar-menu > li.active > a {
          background-color: #1f252b;
          border-left: 3px solid #f77464;
        }
        .skin-black .main-header {
        position: fixed;
        width: 100%;
        }
        .skin-black .main-sidebar {
        position: fixed;
        }
        .content-wrapper{
        margin-top: 50px;
        }
      "))
    ),
    
    tabItems(
      tabItem(
        tabName = "info",
        h1("Informacje o projekcie"),
        p("Aplikacja prezentuje analizę danych dotyczących aktywności hobbystycznych trzech osób, opartą na rzeczywistych zbiorach danych pochodzących z różnych źródeł."),
        p("Projekt obejmuje:"),
        tags$ul(
          tags$li("analizę danych czytelniczych,"),
          tags$li("analizę historii oglądania materiałów w serwisie YouTube,"),
          tags$li("analizę zapytań kierowanych do narzędzia ChatGPT w ujęciu czasowym i tematycznym.")
        ),
        p(""),
        p("Aby zobaczyć szczegółowe analizy, wybierz osobę z panelu bocznego i przejdź do zakładki „Analizy”."),
        hr()
      ),
      
      tabItem(
        tabName = "analizy",
        
        # brak osoby
        conditionalPanel(
          condition = "input.wybranaOsoba == ''",
          h1("Wybierz osobę"),
          p("Aby zobaczyć analizy, wybierz osobę z panelu bocznego.")
        ),
        
        ### Karolina START
        conditionalPanel(
          condition = "input.wybranaOsoba == 'Karolina'",
          h2("Analiza danych o Książkach"),
          
          fluidRow(
            column(
              4,
              pickerInput(
                "rok",
                "Wybierz rok:",
                choices = sort(unique(przeczytane$year)),
                selected = sort(unique(przeczytane$year)),
                multiple = TRUE
              ),
              
              pickerInput(
                "miesiac",
                "Wybierz miesiące:",
                choices = setNames(1:12, miesiace_pl),
                selected = 1:12,
                multiple = TRUE
              )
            ),
            
            column(
              8,
              fluidRow(
                column(
                  6,
                  uiOutput("autorzy_title"),
                  uiOutput("autorzy")
                ),
                column(
                  6,
                  uiOutput("title_wydawnictwa"),
                  uiOutput("wydawnictwa")
                )
              )
            )
          ),
          
          hr(),
          fluidRow(
            column(6, plotlyOutput("wykres1", height = 400)),
            column(6, plotlyOutput("wykres2", height = 400))
          ),
          
          tags$hr(style = "
            border-top: 1px solid #808080;
            margin: 25px 0;
          "),
          fluidRow(
            column(
              6,
              pickerInput(
                "autor_rating",
                "Wybierz autora: ",
                choices = sort(unique(oceny$Author)),
                selected = "",
                options = list(`live-search` = TRUE)
              )
            ),
            fluidRow(
              column(
                12,
                plotlyOutput("wykres3", height = 400)
              )
            )
          )
        ),### Karolina END
        
        ### GABRIELA START
        conditionalPanel(
          condition = "input.wybranaOsoba == 'Gabriela'",
          
          h2("Analiza YouTube"),
          
          fluidRow(
            column(
              4,
              textInput("youtube_slowo", "Wpisz słowo kluczowe:", value = ""),
              selectInput("youtube_rok", "Wybierz rok:", choices = sort(unique(format(na.omit(df_youtube$miesiac), "%Y")))),
              helpText("Wykres pokazuje liczbę filmów zawierających wybrane słowo w poszczególnych miesiącach wybranego roku.")
            ),
            column(
              8,
              plotOutput("wykres_youtube", height = 400)
            )
          ),
          
          fluidRow(
            column(
              4,
              selectInput(
                "youtube_rok_heat",
                "Wybierz rok do heatmapy:",
                choices = sort(unique(format(na.omit(df_youtube$miesiac), "%Y")))
              ),
              helpText("Heatmap pokazuje liczbę obejrzanych filmów w danym dniu miesiąca i miesiącu wybranego roku.")
            ),
            column(
              8,
              plotOutput("heatmap_youtube", height = 500)
            )
          )
          
        ) ### GABRIELA END
        ,
        
        ### Jędrek Początek
        conditionalPanel(
          condition = "input.wybranaOsoba == 'Jędrzej'",
          
          h2("Analiza zapytań do ChatGPT"),
          
          fluidRow(
            column(
              12,
              plotlyOutput("wykres1j", height = 400)
            )
          ),
          fluidPage(
            
            
            dateRangeInput(
              "range",
              "Zakres dat",
              start = min(as.Date("2025-01-01")),
              end   = max(as.Date(df$created_iso_warsaw))
            ),
            
            
            plotlyOutput("wykres2j", height = 420)
          )
        ),
        ###Jędrek Koniec
      )
    )
  )
)

server <- function(input, output, session){
  
  ### Karolina START
  dane_filtrowane <- reactive({
    req(input$rok, input$miesiac)
    przeczytane %>%
      filter(
        year %in% as.integer(input$rok),
        month %in% as.integer(input$miesiac)
      )
  })
  
  output$autorzy_title <- renderUI({
    req(input$rok)
    lata <- sort(as.integer(input$rok))
    opis <- if (length(lata) == 1) paste("w roku", lata)
    else paste("w latach", paste(lata, collapse = ", "))
    h5(paste("Pięć najczęściej czytanych autorów", opis))
  })
  
  output$autorzy <- renderUI({
    req(input$rok)
    top_autorzy <- przeczytane %>%
      filter(year %in% as.integer(input$rok)) %>%
      group_by(Author) %>%
      summarise(ksiazki = n(), .groups = "drop") %>%
      arrange(desc(ksiazki)) %>%
      slice_head(n = 5)
    
    tags$ul(
      lapply(seq_len(nrow(top_autorzy)), function(i) {
        tags$li(
          paste0(top_autorzy$Author[i], " (", top_autorzy$ksiazki[i], " książek)")
        )
      })
    )
  })
  
  output$title_wydawnictwa <- renderUI({
    req(input$rok)
    lata <- sort(as.integer(input$rok))
    opis <- if (length(lata) == 1) paste("w roku", lata)
    else paste("w latach", paste(lata, collapse = ", "))
    h5(paste("Pięć najczęściej czytanych wydawnictw", opis))
  })
  
  output$wydawnictwa <- renderUI({
    req(input$rok)
    top_wydawnictwa <- przeczytane %>%
      filter(year %in% as.integer(input$rok),
             !is.na(Publisher),
             Publisher != "") %>%
      group_by(Publisher) %>%
      summarise(ile = n(), .groups = "drop") %>%
      arrange(desc(ile)) %>%
      slice_head(n = 5)
    
    tags$ul(
      lapply(seq_len(nrow(top_wydawnictwa)), function(i) {
        tags$li(
          paste0(top_wydawnictwa$Publisher[i], " (", top_wydawnictwa$ile[i], " książek)")
        )
      })
    )
  })
  
  output$wykres1 <- renderPlotly({
    df <- dane_filtrowane() %>%
      group_by(year, month) %>%
      summarise(nr_of_book = n(), .groups = "drop") 
    elementy_x <- expand.grid(
      year = unique(df$year),
      month = 1:12
    )
    df<- elementy_x%>%
      left_join(df, by = c("year", "month"))%>%
      mutate(
        nr_of_book = ifelse(is.na(nr_of_book), 0, nr_of_book),
        miesiac = factor(month, levels = 1:12, labels = miesiace_pl),
        tooltip = paste0(
          "<b>",miesiac, "</b><br>",
          "Rok: ",year, "<br>",
          "Liczba książek: ",nr_of_book
        )
      )
    
    p <- ggplot(df,
                aes(
                  x = miesiac,
                  y = nr_of_book,
                  fill = factor(year),
                  text = tooltip
                )
    ) +
      geom_col(position = "dodge") +
      labs(
        title = "Liczba przeczytanych książek w poszczególnych miesiącach",
        x = "Miesiąc",
        y = "Liczba książek",
        fill = "Rok"
      ) +
      theme_minimal()+
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank())+
      scale_fill_manual(values = c(kolor1, kolor2))
    
    ggplotly(p, tooltip = "text") %>% config(displaylogo = FALSE)
  })
  
  output$wykres2 <- renderPlotly({
    
    df <- dane_filtrowane() %>%
      mutate(
        Time = as.numeric(Time),
        pages = as.numeric(Number.of.Pages),
        tempo = pages / Time
      ) %>%
      filter(is.finite(tempo))
    
    p <- ggplot(
      df,
      aes(
        x = pages,
        y = tempo,
        color = factor(year),
        text = paste(
          "<b>", Title, "</b><br>",
          "Tempo:", round(tempo, 1), " str./dzień<br>",
          "Strony:", pages
        )
      )
    ) +
      geom_point(alpha = 0.7, size = 3) +
      scale_color_manual( values = c(kolor1,kolor2))+
      labs(
        title = "Tempo czytania a objętość książek",
        x = "Liczba stron",
        y = "Tempo (strony / dzień)",
        color = "Rok"
      ) +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>%
      config(displaylogo = FALSE)
  })
  
  output$wykres3 <- renderPlotly({
    df <- oceny
    if(!is.null(input$autor_rating)&& input$autor_rating !=""){
      df <- df%>% filter(Author == input$autor_rating)
    }
    req(nrow(df)>0)
    
    df_long <- df%>%
      select(Title, Author, my_rating, avg_rating) %>%
      tidyr:: pivot_longer(
        cols = c(my_rating, avg_rating),
        names_to = "typ_oceny",
        values_to = "ocena"
      ) %>%
      mutate(
        typ_oceny = recode(
          typ_oceny,
          my_rating ="Moja ocena",
          avg_rating = "Średnia ocena"
        )
      )
    
    p <- ggplot(
      df_long,
      aes(
        x = Title,
        y = ocena,
        fill = typ_oceny,
        text = paste0(
          "<b>", Title, "</b><br>",
          "Autor: ", Author, "<br>",
          typ_oceny, ": ",ocena
        )
      )
    ) +
      geom_col(position = position_dodge(width = 0.7))+
      labs(
        title = "Porównanie ocen książek",
        x = "Książki",
        y = "Ocena",
        fill = ""
      )+
      scale_fill_manual(values = c(kolor1,kolor2))+
      theme_minimal()+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text")%>%
      config(displaylogo =FALSE)
  }) ###Karolina END
  
  ### GABRIELA START
  
  output$wykres_youtube <- renderPlot({
    req(input$youtube_slowo, input$youtube_rok)  
    
    # filtrowanie danych po słowie i roku
    filtered_df <- df_youtube %>%
      filter(!is.na(miesiac),
             grepl(input$youtube_slowo, tytul_filmu, ignore.case = TRUE),
             format(miesiac, "%Y") == input$youtube_rok) %>%
      count(miesiac)
    
    # zeby byly zawsze wszystkie miesiace
    full_months <- tibble(
      miesiac = seq.Date(
        from = as.Date(paste0(input$youtube_rok, "-01-01")),
        to   = as.Date(paste0(input$youtube_rok, "-12-01")),
        by   = "month"
      )
    )
    
    # brakujace miesiace
    plot_df <- full_months %>%
      left_join(filtered_df, by = "miesiac") %>%
      mutate(n = ifelse(is.na(n), 0, n))
    
    # wykres
    ggplot(plot_df, aes(x = miesiac, y = n)) +
      geom_col(fill = kolor1) +
      scale_x_date(date_labels = "%Y-%m", date_breaks = "1 month") +
      labs(
        title = paste("Liczba filmów ze słowem:", input$youtube_slowo),
        x = "Miesiąc",
        y = "Liczba publikacji"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$heatmap_youtube <- renderPlot({
    req(input$youtube_rok_heat)
    
    # filtrowanie danych po wybranym roku
    df <- df_youtube %>%
      filter(!is.na(data_clean),
             format(data_clean, "%Y") == input$youtube_rok_heat) %>%
      mutate(
        month = as.integer(format(data_clean, "%m")),
        day   = as.integer(format(data_clean, "%d"))
      ) %>%
      group_by(month, day) %>%
      summarise(count = n(), .groups = "drop")
    
    # tworzymy pełną siatkę dni x miesiące, żeby mieć też 0 tam gdzie nie było filmów
    full_grid <- expand.grid(
      month = 1:12,
      day   = 1:31
    )
    
    df_plot <- full_grid %>%
      left_join(df, by = c("month", "day")) %>%
      mutate(count = ifelse(is.na(count), 0, count),
             month_label = factor(month, levels = 1:12, labels = miesiace_pl))
    
    # wykres
    ggplot(df_plot, aes(x = day, y = month_label, fill = count)) +
      geom_tile(color = "grey70") +
      scale_fill_gradient(low = "white", high = kolor1) +
      labs(
        title = paste("Liczba obejrzanych filmów w roku", input$youtube_rok_heat),
        x = "Dzień miesiąca",
        y = "Miesiąc",
        fill = "Liczba filmów"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 0))
  })
  ### GABRIELA END
  
  
  ## Jędrek Początek
  output$wykres1j <- renderPlotly({
    
    df2$topic <- recode(
      df2$topic,
      "topologia" = "Topologia",
      "teoria_miary" = "Teoria miary",
      "geometria_rozniczkowa" = "Geometria różniczkowa",
      "analiza_rzeczywista" = "Analiza rzeczywista",
      "algebra_liniowa" = "Algebra liniowa",
      "teoria_prawdopodobienstwa" = "Teoria prawdopodobieństwa",
      "informatyka" = "Informatyka",
      "inne" = "Inne"
    )
    
    p <- ggplot(df2, aes(x = reorder(topic, n), y = n,,
                         text = paste0(
                           "Temat: ", topic, "</b><br>",
                           "Liczba zapytań: ",n))) +
      geom_col(fill = kolor1) +
      theme_minimal() +
      labs(
        title = "Tematy",
        x = "Temat",
        y = "Liczba wiadomości")+
      x+ 
      theme(axis.text.x = element_text(angle = 45, hjust = 1))+
      theme(plot.title = element_text(face = "plain"))
    
    ggplotly(p, tooltip = "text")%>%
      config(displaylogo = FALSE)
  })
  output$wykres2j <- renderPlotly({
    d <- df %>%
      filter(author_role == "user") %>%
      mutate(date = as.Date(created_iso_warsaw)) %>%
      filter(date >= input$range[1], date <= input$range[2]) %>%
      count(date) %>%
      arrange(date) %>%
      mutate(
        ma7 = as.numeric(stats::filter(n, rep(1/7, 7), sides = 1))
      )
    
    p <- ggplot(d, aes(date)) +
      geom_col(aes(y = n, text = paste0(
        "<b>Data:</b> ", date, "<br>",
        "<b>Liczba zapytań:</b> ", n
      )), 
      fill = "#D0D7DE", width = 0.9) +
      geom_line(aes(y = ma7, group = 1, text = paste0(
        "<b>Średnia 7-dniowa</b><br>",
        "Data: ", date, "<br>",
        "Wartość: ", round(ma7, 1)
      )), color = kolor1, linewidth = 1.1) +
      scale_x_date(date_breaks = "1 month", date_labels = "%Y-%m") +
      labs(
        title = "Liczba zapytań dziennie",
        x = NULL,
        y = "Liczba zapytań"
      ) +
      theme_minimal() +
      x
    
    ggplotly(p, tooltip = "text") %>%
      layout(
        title = list(
          text = paste0(
            "Liczba zapytań dziennie<br>",
            "<span style='font-size:12px;color:#666;'>linia = średnia krocząca 7 dni</span>"
          )
        )
      ) %>%
      config(displaylogo = FALSE)
  })
  ### Jędrek Koniec
}


shinyApp(ui = ui, server = server)
