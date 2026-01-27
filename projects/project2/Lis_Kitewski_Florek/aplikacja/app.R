library(shinydashboard)
library(shiny)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(tibble)

### Wczytanie danych i obróbka

df_ruchy <- read.csv("..\\apk\\dane\\full_moves.csv")
df_dane_partii <- read.csv("..\\apk\\dane\\full_game_info.csv")
df_debiuty <- read.csv("..\\apk\\dane\\debiuty.csv")
df_debiuty <- df_debiuty %>% filter(name!="")

df_temp <- read.csv("..\\apk\\dane\\podsumowanie.csv")



nick = c("FirejFox","BarMan-ek","GDgamers","bArmAnEk")

df_dane_partii<-df_dane_partii %>% 
  mutate(gracz = if_else(white %in% nick,white,if_else(black %in% nick,black, NA))) %>% 
  mutate(gracz = if_else(gracz=="BarMan-ek","bArmAnEk",gracz)) %>% 
  mutate(date_played = ymd(date_played)) %>% 
  mutate(weekday = wday(date_played, label=TRUE, abbr=FALSE)) %>% 
  mutate(year = year(date_played))

df_ruchy <- df_ruchy %>% left_join(df_dane_partii %>% select(game_id, gracz, weekday, year),
                                   by = "game_id")

df_debiuty <- df_debiuty %>% left_join(df_dane_partii %>% select(game_id, gracz, weekday, year),
                                       by = "game_id")




ui <- dashboardPage(skin="green",
  dashboardHeader(title = "Chess dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analiza wyników", tabName = "first", icon = icon("king", lib = "glyphicon")),
      menuItem("Analiza przebiegu partii", tabName = "widgets", icon = icon("bishop", lib = "glyphicon")),
      menuItem("Debiuty", tabName = "third", icon = icon("knight", lib = "glyphicon")),

      selectInput("player",
                  "Wybierz użytkownika: ",
                  choices = c("Wszyscy" = "all",
                              "Janek" ="FirejFox",
                              "Bartek" = "bArmAnEk",
                              "Wojtek" = "GDgamers")
                  ),
      sliderInput("lata", "Lata",min=2017,max=2025,step=1,sep="",
                  value = c(2017,2025)
    )
  )
  ),
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "first",
              fluidRow(valueBoxOutput("full_win"),valueBoxOutput("full_draw"),valueBoxOutput("full_loss")),
              fluidRow(
                column(6, box(title= h3("Wyniki w zależności od dnia tygodnia", style="text-align: center;font-family: 'Poppins', sans-serif;"), status="success", solidHeader = TRUE, width=12,
                              #height = "500px",
                          
                              plotOutput("weekday_wins"),
                              HTML("
             Całościowy stosunek zwycięstw i porażek zwykle utrzymuje się z trochę większą liczbą zwycięstw.
             Co ciekwae gdy spojrzymy na poszczególnie dni tygodnia, może okazać się, że są dni w których powinniśmy
             grać więcej (np. niedziela), natomiast wtorki nie dla każdego są szczęśliwe.")
                                    )
                       ),
                column(6,
                       box(title=h3("Procent zwycięstw", style="text-align: center;font-family: 'Robota', sans-serif;"),height="700px", width=12,status="success", solidHeader = TRUE,
                           div(
                             style="display:flex; justify-content:center; align-items:center; height:100%;",tableOutput("podsumowanie")),
                           plotOutput("kolowy")
                           
                           )
                       )
                )
      ),
      
      
      tabItem(tabName = "widgets",
              h2("Szczegóły partii", style="text-align: center;font-family: 'Robota', sans-serif"),
              fluidRow(
                    box(title=h3("Rozkład partii względem liczby ruchów", style="text-align: center;font-family: 'Robota', sans-serif"),status="success", solidHeader = TRUE, plotOutput("rozklad_partii")),
                box(title=h3("Średni materiał na planszy podczas partii", style="text-align: center;font-family: 'Robota', sans-serif"),status="success", solidHeader = TRUE, plotOutput("rozklad_material")),
                box(title=h3("Średnie odwiedzanie pól podczas partii", style="text-align: center;font-family: 'Robota', sans-serif"),status="success", solidHeader = TRUE, plotOutput("heatmap_ruchy")),
                box(title=h3("Czym jest materiał i skąd wachania na końcu partii?", style="text-align: center;font-family: 'Robota', sans-serif"),
                status="success", solidHeader = TRUE, HTML("Materiał liczymy mnożąc liczbę figur przez ich wartość. Każda figura na szachownicy ma swoją wartość:
    <ul>
      <li>Pionek - 1 punkt</li>
      <li>Skoczek - 3 punkty</li>
      <li>Goniec - 3 punkty</li>
      <li> Wieża - 5 punktów </li>
      <li> Hetman - 9 punktów </li>
      <li> Król - bezcenny </li>
    </ul>
    Na ogół wraz z rozwojem partii spodzieamy się tendencji spadkowej materiału, jednak jeśli pionek trafi na
    ostatni wiersz, to następuje <b> promocja </b>, co oznacza, że pionek może stać się dowolną figurą (najczęściej 
    <b> hetmanem</b>).")
              ))),
      
      
      
      tabItem(tabName = "third",
              h2("Ulubione debiuty", style="text-align: center;font-family: 'Robota', sans-serif"),
              fluidRow(
                box(title = "Czym jest debiut?",
                    width = 12,
                    HTML('
      <div style="
        text-align: justify;
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
      ">
        <b>Debiutem</b>, inaczej otwarcie, początkowa faza partii szachów. Debiuty o nazwach są zwykle
        dobrze zbadane i zapewniające obu stronom gry równe szanse na zwycięstwo. Często mówi się też o
        liniach teorii szachowej i jak długo gracze trzymają się jej. Na poniższych wykresach można
        zobaczyć kto, kiedy i jakie otwarcia grał oraz obejrzeć animację tych ruchów.
      </div>
    '))
              ),
              
              
              fluidRow(
              
              box(title=h3("Rozkład najpopularniejszych debiutów", style="text-align: center;font-family: 'Robota', sans-serif"),
                  status="success", solidHeader = TRUE,width=12, plotOutput("debiuty_liczba"))
              ),
              fluidRow(
                box(width=12, uiOutput("select_debiut"),
                plotlyOutput("animacja",height = "500px"),
                sliderInput("debiut_dlg", "Dlugość debiutu", min = 1, max=10, step=1,
                                value=c(1,5))
                    ),
              )
              )
      )
      )
    )


  


server <- function(input, output) {
  output$weekday_wins <- renderPlot({
    
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    poziomy = c("poniedziałek","wtorek","środa","czwartek","piątek","sobota","niedziela")
    
    wykres<-df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      select(winner,weekday) %>% mutate(wygrana=case_when(
        winner %in% nick ~ "wygrana",
        winner == "draw" ~ "remis",
        .default = "przegrana")) %>% filter(!(wygrana=="remis")) %>% 
      group_by(weekday,wygrana) %>% summarise(ile = n()) %>% 
      mutate(weekday = factor(weekday, levels=poziomy))%>% 
      ggplot(aes(y=weekday,x=ile,fill=wygrana)) + geom_col(position = "dodge") +
      labs(#title = "Wygrane i przegrane w zależności od dnia tygodnia", 
        x = "liczba partii",
           y = "dzień tygodnia", fill="") +
      theme(
        panel.background = element_blank(),
        plot.background = element_rect(colour = "white"),
        # plot.title.position = "plot",
        # plot.title = element_text(hjust=0.5),
        axis.text.x= element_text(color = "black",vjust=1,size=14),
        axis.text.y = element_text(color="black",size=14),
        axis.ticks.y = element_line(color="black"),
        panel.grid.major.y = element_line(color="black",linetype=1),
        panel.grid.minor.y = element_line(color="black"),
        panel.grid.minor.x = element_line(colour = "black"),
        axis.ticks.x = element_blank(),
        legend.text = element_text(color="black",size=14),
        legend.title = element_text(color="black",size=14),
        title = element_text(size=16),
        panel.grid.major.x = element_blank()
      ) + scale_fill_discrete(palette = c("#00b300","#c0000d"), limits=c("wygrana","przegrana"))
    wykres
    
  })
  
  output$rozklad_partii <- renderPlot({
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    wykres <- df_ruchy %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      select(game_id,move_no) %>% group_by(game_id) %>% summarise(ruchy = max(move_no)) %>% 
      ggplot(aes(x=ruchy)) + geom_histogram(fill="black",colour="lightgray",bins = 30) + 
      labs(#title= "Rozkład partii względem ilości ruchów", 
        x = "Liczba ruchów",y = "liczba partii") +
      theme(
        panel.background = element_blank(),
        # plot.background = element_rect(colour = "white"),
        # plot.title.position = "plot",
        # plot.title = element_text(hjust=0.5),
        axis.text.x= element_text(color = "black",vjust=1,size=14),
        axis.text.y = element_text(color="black",size=14),
        axis.ticks.y = element_line(color="black"),
        panel.grid.major.y = element_line(color="black",linetype=1),
        panel.grid.minor.y = element_line(color="black"),
        panel.grid.minor.x = element_line(colour = "black"),
        axis.ticks.x = element_blank(),
        title = element_text(size=16),
        panel.grid.major.x = element_blank()
      )
    
    wykres
  })
  
  output$rozklad_material <- renderPlot({
    
    rok <- input$lata
    
    wykres<-df_ruchy %>% filter(year<=rok[2] & year>=rok[1]) %>% 
      select(gracz, move_no,white_pawn_count,white_queen_count,white_bishop_count,white_knight_count,
             white_rook_count,black_pawn_count,black_queen_count,black_bishop_count,
             black_knight_count,black_rook_count) %>% 
      mutate(value = 9*(white_queen_count + black_queen_count)+
               5*(white_rook_count + black_rook_count)+
               3*(white_bishop_count+black_bishop_count+white_knight_count+black_knight_count)+
               (white_pawn_count+black_pawn_count)) %>% 
      select(move_no, value, gracz) %>% group_by(move_no, gracz) %>% summarise(avg = mean(value)) %>% 
      mutate(gracz = case_when(
        gracz == "FirejFox" ~ "Janek",
        gracz == "GDgamers"~ "Wojtek",
        .default = "Bartek"
      )) %>% 
      ggplot(aes(x=move_no, y = avg, color=gracz)) + geom_line(size=1) +
      labs(#title = "Średni materiał na planszy ze względu na długość partii",
           x = "Liczba ruchów", y = "Średni materiał", color = "Gracz") +
      theme(
        panel.background = element_blank(),
        # plot.background = element_rect(colour = "white"),
        # plot.title.position = "plot",
        # plot.title = element_text(hjust=0.5),
        axis.text.x= element_text(color = "black",vjust=1,size=14),
        axis.text.y = element_text(color="black",size=14),
        axis.ticks.y = element_line(color="black"),
        panel.grid.major.y = element_line(color="black",linetype=1),
        panel.grid.minor.y = element_line(color="black"),
        panel.grid.minor.x = element_line(colour = "black"),
        axis.ticks.x = element_blank(),
        legend.text = element_text(color="black",size=14),
        legend.title = element_text(color="black",size=14),
        title = element_text(size=16),
        panel.grid.major.x = element_blank()
      )
    wykres
    
  })
  
  output$rozklad_figury <- renderPlot({
    
    rok <- input$lata
    
    wykres<-df_ruchy %>% filter(year<=rok[2] & year>=rok[1]) %>% 
      select(move_no,white_count,black_count,gracz) %>% mutate(liczba = white_count+black_count) %>% 
      group_by(move_no, gracz) %>% summarise(avg = mean(liczba)) %>% 
      ggplot(aes(x=move_no, y=avg,color=gracz)) + geom_line() +
      labs(title= "Średnia liczba figur na planszy ze względu na liczbę ruchów")
    wykres
  })
  
  output$heatmap_ruchy <- renderPlot({
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    
    df_pola <- df_ruchy %>% select(to_square, gracz, year) %>% 
      filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      group_by(to_square) %>% summarise(ile = n())
    
    df_pola <- df_pola %>% mutate(y = substr(to_square,2,2), x = substr(to_square,1,1)) %>% 
      select(-to_square)
    
    ilosc_partii <- dim(df_dane_partii %>% filter(gracz %in% c(gracze)) %>% 
                          filter(year <= rok[2] & year>=rok[1]))[1]
    
    wykres<-df_pola %>% mutate(ile = ile/ilosc_partii) %>% ggplot(aes(x=x, y=y, fill=ile)) + 
      geom_tile(color="black") +
      scale_fill_gradient(low = "white", high = "darkgreen", name="Średnia") +theme_minimal()+
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_text(color = "black",vjust=1,size=14),
        axis.text.y = element_text(color="black",size=14),
        legend.text = element_text(color="black",size=14),
        legend.title = element_text(color="black",size=14),
        legend.ticks = element_line(colour = "black"),
        # title = element_text(size=16),
        # plot.title.position = "plot",
        # plot.title = element_text(hjust=0)
      )+
      guides(fill = guide_colorbar(barwidth = 1.5, barheight = 15)) +
      labs(#title="Średnie odwiedzanie pól względem partii"
        ) +
      coord_fixed()
    wykres
  })
  
  output$debiuty_liczba <- renderPlot({
    rok <- input$lata
    gracze <- input$player
    dlg <- input$debiut_dlg
    
    if (gracze=="all")
      gracze = nick
    
    
    
    wykres<- df_debiuty %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>%
      group_by(game_id) %>% 
      filter(move_no<=dlg[2] & move_no >= dlg[1]) %>% summarise(debiut = last(name), .groups = "drop") %>% 
      group_by(debiut) %>% summarise(ile = n()) %>% top_n(5) %>% arrange() %>% 
      ggplot(aes(y=debiut,x=ile)) + geom_col(fill="black") + 
      labs(title=paste("Top 5 rozegranych debiutów od", dlg[1],"do",dlg[2],"ruchów",sep=" "),
           x = "Liczba", y = "Debiut") +
      theme(
        panel.background = element_blank(),
        plot.background = element_rect(colour = "white"),
        plot.title.position = "plot",
        plot.title = element_text(hjust=0.5),
        axis.text.x= element_text(color = "black",vjust=1,size=14),
        axis.text.y = element_text(color="black",size=14),
        axis.ticks.y = element_line(color="black"),
        panel.grid.major.y = element_line(color="black",linetype=1),
        panel.grid.minor.y = element_line(color="black"),
        panel.grid.minor.x = element_line(colour = "black"),
        axis.ticks.x = element_blank(),
        title = element_text(size=16),
        panel.grid.major.x = element_blank()
      )
    wykres
    
    
    
  })
  
  output$kolowy <- renderPlot({
    
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    df_plot <- df_dane_partii %>% filter(year <= rok[2] & year >= rok[1]) %>%
      filter(gracz %in% gracze) %>% select(winner, gracz) %>% mutate(wygrana = case_when(
        winner %in% nick ~ "wygrana",
        winner == "draw" ~ "remis",
        TRUE ~ "przegrana"
      )) %>% group_by(wygrana) %>% summarise(ile = n(), .groups = "drop") %>%
      mutate( wygrana = factor(wygrana, levels = c("wygrana", "remis", "przegrana")),
              proc = ile / sum(ile) * 100,
              label = paste0(wygrana, " (", round(proc, 1), "%)"),
              ypos = cumsum(ile) - 0.5*ile
      )
    
    ggplot(df_plot, aes(x = 1, y = ile, fill = wygrana)) +
      geom_bar(stat = "identity", width = 1, color = "white") +
      coord_polar("y", start = 0) +
      theme_void() +
      theme(plot.margin = unit(c(1,1,1,1), "pt")) +
      geom_text(aes(y = ypos, label = label),
                size = 5,
                position = position_nudge(x = 0.6)) +
      scale_fill_manual(values = c( "wygrana" = "#00b300",
                                    "remis" = "#0000b3","przegrana" = "#cc0000"),name = "Wynik") +
      guides(fill = "none") + xlim(0.5, 2) 
  })
  
  output$podsumowanie <- renderTable({
    
    rok <- input$lata
    
    max_min_partia <- df_ruchy %>% filter(year<=rok[2] & year>=rok[1])%>% 
      select(gracz, move_no) %>% group_by(gracz) %>% 
      summarise(max_dlg = max(move_no), min_dlg = min(move_no)) %>% 
      mutate(gracz = case_when(gracz=="FirejFox"~"Janek",gracz=="GDgamers" ~ "Wojtek", .default = "Bartek"))
    
    
    max_dzien <- df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% 
      select(gracz, date_played) %>% group_by(gracz, date_played) %>% summarise(ile = n()) %>% 
      group_by(gracz) %>% summarise(liczba_partii = max(ile))
    wynik <- cbind(max_min_partia, max_dzien)[c(1,2,3,5)]
    
    
    wynik <- t(wynik)
    colnames(wynik) <- (unlist(wynik[1,]))
    wynik<-wynik[-1,,drop=FALSE]
    wynik <- cbind(kategoria =c("najdłuższa gra", "najkrótsza gra", "najwięcej gier jednego dnia"), wynik )
    wynik
    
  })
  
  output$select_debiut <- renderUI({
    
    rok <- input$lata
    gracze <- input$player
    dlg <- input$debiut_dlg
    
    if (gracze=="all")
      gracze = nick
    
    
    lista<- df_debiuty %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>%
      group_by(game_id) %>% 
      filter(move_no<=dlg[2] & move_no >= dlg[1]) %>% summarise(debiut = last(name), .groups = "drop") %>% 
      group_by(debiut) %>% summarise(ile = n()) %>% top_n(5) %>% arrange() %>% select(debiut)
    
    
    selectInput("debiut_wybrany","Debiuty: ", choices = lista)
  })
  
  output$animacja <- renderPlotly({
    #Czcionka do figur
    piece_map <- c(
      R = "♖", N = "♘", B= "♗", Q= "♕", K = "♔", P = "♙",  
      r = "♜", n= "♞", b= "♝", q= "♛", k = "♚", p= "♟"   
    )
    
    #Pomocnicza funkcja
    fen_to_df <- function(fen, klatka) {
      
      #Dzielimy na wiersze szachownicy
      rows <- strsplit(fen, "/")[[1]]
      #Przygotowanie wyniku
      result <- list()
      
      #Po wierszach szachwonicy
      for (i in seq_along(rows)) {
        
        row <- rows[i]
        #Znam kolejność, wczytywania (wiersz od y się zmianiają powoli)
        y <- 9 - i        
        x <- 1
        
        chars <- strsplit(row, "")[[1]]
        
        for (ch in chars) {
          
          if (grepl("[0-9]", ch)) {
            x <- x + as.numeric(ch)
          } else {
            result[[length(result) + 1]] <- data.frame( frame=klatka,
                                                        piece = piece_map[ch], x = x, y = y-0.1
            )
            x <- x + 1
          }
        }
      }
      
      #Łączenie wyników
      bind_rows(result)
    }
    
    
    one_game_leading_to_debut <- function(data, debut_name) {
      #Uwzględniam początkową pozycję do animacji
      fen0 <- "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
      # Znajdź pierwsze id, w którym występuje debiut
      first_id <- data %>% filter(name == debut_name) %>%
        arrange(game_id) %>% slice(1) %>% pull(game_id)
      
      #W razie czego, zwracam pozycję 0
      if (length(first_id) == 0 || is.na(first_id)) {
        return (data.frame(fen=fen0))
      }
      
      #Zwracam feny do momentu debiutu włącznie
      fens<-data %>% filter(game_id == first_id) %>% mutate(step = row_number()) %>% 
        filter(step <= min(step[name == debut_name])) %>% select(fen)
      
      #Połączenie
      fens<-rbind(fen0,fens)
    }
    
    fen_rows_to_df <- function(fens_df) {
      
      out <- list()
      idx <- 1
      
      for (i in seq_len(nrow(fens_df))) {
        #Ramka z klatek na fen
        tmp <- fen_to_df(fens_df$fen[i],i)
        #Lista ramek danych, idx - indeks na który zapisujemy ramkę danych
        out[[idx]] <- tmp
        idx <- idx + 1
      }
      #Wywołąnie rbind, na out (pola listy out to ramki danych)
      do.call(rbind, out)
    }
    
    #Tworzenie szachownicy, pętla w pętli, funkcja definiowana w miejscu,
    # W środku jest informacja co robię dla każdej pary (x,y) (64 pola) o środku w punkcie (x,y)
    # na koniec spłaszczenie
    board_shapes <- lapply(1:8, function(x) {
      lapply(1:8, function(y) {
        list(
          type = "rect",
          x0 = x - 0.5,
          x1 = x + 0.5,
          y0 = y - 0.5,
          y1 = y + 0.5,
          fillcolor = ifelse((x + y) %% 2 == 0, "#769656", "#EEEED2"),
          line = list(width = 1),
          layer="below"
        )
      })
    }) |> unlist(recursive = FALSE)
    
    
    
    
    
    debiut<- input$debiut_wybrany;
    
    wynik<- fen_rows_to_df(one_game_leading_to_debut(df_debiuty,debiut))
    
    fig <- plot_ly() %>%
      
      add_text(
        data = wynik,
        x = ~x,
        y = ~y,
        text = ~piece,
        frame = ~frame,
        textfont = list(size = 30),
        hoverinfo="skip"
      ) %>%
      
      layout(
        shapes = board_shapes,
        xaxis = list(
          range = c(0.5, 8.5),
          tickvals = 1:8,
          ticktext = letters[1:8],
          tickfont = list(size=14),
          fixedrange = TRUE,
          showgrid=FALSE,
          title="",
          constrain="domain"
          
        ),
        yaxis = list(
          range = c(0.5, 8.5),
          tickvals=1:8,
          ticktext = 1:8,
          tickfont = list(size=14),
          scaleanchor = "x",
          fixedrange = TRUE,
          showgrid=FALSE,
          title="",
          automargin=FALSE
          
        ),
        showlegend=FALSE,
        title=list(text=paste(debiut),font=t)
        
      ) %>% animation_opts(transition = 0)
    
    fig
    
  })
  
  output$full_win <- renderValueBox({
    
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    dane<-df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      filter(winner==gracz)
    wartosc<-dim(dane)[1]
    
    valueBox(
      value = wartosc,
      subtitle = "Wygrane",
      color="green",
      icon=icon("thumbs-up")
    )
  })
  
  output$full_loss <- renderValueBox({
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    dane<-df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      filter(loser==gracz)
    wartosc<-dim(dane)[1]
    
    valueBox(
      value = wartosc,
      subtitle = "Przegrane",
      color="red",
      icon=icon("thumbs-down")
    )
  })
  
  output$full_draw <- renderValueBox({
    rok <- input$lata
    gracze <- input$player
    
    if (gracze=="all")
      gracze = nick
    
    dane<-df_dane_partii %>% filter(year<=rok[2] & year>=rok[1]) %>% filter(gracz %in% c(gracze)) %>% 
      filter(loser=="draw")
    wartosc<-dim(dane)[1]
    
    valueBox(
      value = wartosc,
      subtitle = "Remisy",
      color="yellow",
      icon=icon("equals")
    )
  }
  )
  
}

shinyApp(ui, server)
