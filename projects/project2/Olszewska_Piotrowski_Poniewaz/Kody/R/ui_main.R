ui <- navbarPage(
  title = "Studencki Grudzień",
  id = "topnav",
  header = tags$head(
    tags$link(rel = "stylesheet", href = "style.css")
  ),
  
  tabPanel(
    "Strona główna",
    fluidPage(
      column(10, offset = 1,
             br(),
             fluidRow(
               column(
                 12,
                 div(
                   class = "bento-card",
                   style = "padding: 45px; text-align: left;",
                   h1(
                     "Jak dbamy o zdrowie jako studenci PW?",
                     style = "font-weight: 800; font-size: 42px; margin-bottom: 30px; letter-spacing: -1px;"
                   ),
                   p(
                     "Hej, jesteśmy studentami 2 roku na kierunku Inżynieria i Analiza Danych. ",
                     "Projekt skupia się na naszych codziennych nawykach zdrowotnych. ",
                     "Sprawdzamy, jak wygląda nasze życie studenckie pod kątem zdrowia ",
                     "i które obszary wymagają największej uwagi.",
                     style = "max-width: 950px; font-size: 18px; line-height: 1.7; color: #636e72;"
                   )
                 )
               )
             ),
             
             br(),
             fluidRow(
               column(
                 12,
                 div(
                   class = "bento-card",
                   style = "padding: 35px; text-align: left;",
                   h2("Sekcja „Analiza”", style = "font-weight: 700; margin-bottom: 20px;"),
                   p(
                     "W sekcji „Analiza” znajdziesz wykresy przedstawiające dane o nas ",
                     "podzielone na trzy główne kategorie: spożycie kofeiny, sen oraz czas ekranowy.",
                     style = "font-size: 17px; line-height: 1.7; color: #636e72;"
                   )
                 )
               )
             ),
             
             br(),
             
             fluidRow(
               class = "equal-height",
               column(
                 4,
                 div(
                   class = "bento-card",
                   style = "padding: 30px; text-align: left;",
                   h3("Spożycie kofeiny", style = "font-weight: 700;"),
                   tags$ul(
                     tags$li("w jakiej formie i ilości spożywamy kofeinę,"),
                     tags$li("o jakiej porze dnia najczęściej sięgamy po kofeinę.")
                   )
                 )
               ),
               
               column(
                 4,
                 div(
                   class = "bento-card",
                   style = "padding: 30px; text-align: left;",
                   h3("Sen", style = "font-weight: 700;"),
                   tags$ul(
                     tags$li("jak długo śpimy,"),
                     tags$li("o których godzinach najczęściej zasypiamy i wstajemy,"),
                     tags$li("w jakie dni tygodnia śpimy najwięcej i najmniej.")
                   )
                 )
               ),
               
               column(
                 4,
                 div(
                   class = "bento-card",
                   style = "padding: 30px; text-align: left;",
                   h3("Czas ekranowy", style = "font-weight: 700;"),
                   tags$ul(
                     tags$li("ile czasu dziennie spędzamy przed ekranem,"),
                     tags$li("ile powiadomień dostajemy w ciągu dnia,"),
                     tags$li("z jakich aplikacji korzystamy najczęściej,"),
                     tags$li("z której aplikacji otrzymujemy najwięcej powiadomień,"),
                     tags$li("w które dni tygodnia spędzamy najwięcej czasu przed ekranem.")
                   )
                 )
               )
             ),
             
             br(),
             fluidRow(
               column(
                 6,
                 div(
                   class = "bento-card",
                   style = "padding: 30px; text-align: left;",
                   h3("Sekcja „Overview”", style = "font-weight: 700;"),
                   p(
                     "W sekcji „Overview” znajdziesz podsumowanie danych ",
                     "zaprezentowanych w całej aplikacji.",
                     style = "font-size: 16px; line-height: 1.6; color: #636e72;"
                   )
                 )
               ),
               
               column(
                 6,
                 div(
                   class = "bento-card",
                   style = "padding: 30px; text-align: left;",
                   h3("Sekcja „Mini Quiz”", style = "font-weight: 700;"),
                   p(
                     "W sekcji „Mini Quiz” możesz sprawdzić swoją wiedzę o nas ",
                     "na podstawie informacji przedstawionych w aplikacji.",
                     style = "font-size: 16px; line-height: 1.6; color: #636e72;"
                   )
                 )
               )
             )
             
             ,
             
             div(class = "bento-card",
                 h3("Poznaj twórców projektu", 
                    style = "text-align: center; font-weight: 700; margin-bottom: 40px; color: #2d3436;"),
                 
                 fluidRow(
                   column(4, 
                          actionLink("jump_kacper", 
                                     label = avatar_box("Ferb.png", tags$span("KACPER", style="font-size: 20px; letter-spacing: 2px;"), 180, "5%"),
                                     style = "text-decoration: none; color: inherit;")
                   ),
                   column(4, 
                          actionLink("jump_emilka", 
                                     label = avatar_box("Fretka.png", tags$span("EMILKA", style="font-size: 20px; letter-spacing: 2px;"), 180, "0%"),
                                     style = "text-decoration: none; color: inherit;")
                   ),
                   column(4, 
                          actionLink("jump_bartek", 
                                     label = avatar_box("Fineasz.png", tags$span("BARTEK", style="font-size: 20px; letter-spacing: 2px;"), 180, "20%"),
                                     style = "text-decoration: none; color: inherit;")
                   )
                 )
             ),
             
             div(style = "text-align: center; margin-top: 40px; margin-bottom: 50px;",
                 actionButton("go_analysis", 
                              label = list("ROZPOCZNIJ ANALIZĘ", icon("chevron-right")), 
                              class = "btn-main-action")
             )
      )
    )
  ),
  
  tabPanel(
    "Analiza",
    sidebarLayout(
      sidebarPanel(
        width = 4,
        div(class = "bento-card", 
            style = "padding: 30px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05);",
            
            h4("FILTRY", style = "font-family: 'Outfit'; letter-spacing: 3px; border-bottom: 2px solid #f0f2f5; padding-bottom: 15px; margin-bottom: 25px;"),
            p("Wybierz osobę/osoby:", 
              style = "font-family: 'Outfit'; font-weight: 300; font-size: 14px; color: #95a5a6; margin-bottom: 15px;"),
            div(class = "custom-filters",
                checkboxGroupInput(
                  "person_choice",
                  label = NULL,
                  choices = c("Wszyscy" = "all", persons),
                  selected = "all"
                )
            ),
            br(),
            hr(style = "border-top: 1px solid #f0f2f5;"),
            div(style = "text-align: center;",
                uiOutput("selected_avatar")
            )
        )
      ),
      
      mainPanel(
        tabsetPanel(
          tabPanel(
            categories$caffeine,
            fluidPage(
              br(),
              fluidRow(
                column(12,
                       div(class = "bento-card",
                           airDatepickerInput(
                             inputId = "caffeine_days_range",
                             label = "Zakres dat:",
                             range = TRUE,
                             toggleSelected = FALSE,
                             value = c(as.Date("2025-12-01"), as.Date("2025-12-31")),
                             autoClose = TRUE,
                             minDate = min(caffeine_df$date),
                             maxDate = max(caffeine_df$date),
                             width = "100%"
                           )
                           
                       )
                )
              ),
              
              hr(),
              fluidRow(
                column(
                  9,
                  div(
                    class = "bento-card",
                    h4("Średnie dzienne spożycie napojów"),
                    plotOutput("caffeine_avg_bar", height = "400px")
                  )
                ),
                column(
                  3,
                  div(
                    class = "bento-card",
                    h4("Podsumowanie kofeiny"),
                    uiOutput("caffeine_summary_text")
                  )
                )
              ),
              
              hr(),
              fluidRow(
                column(
                  9,
                  div(
                    class = "bento-card",
                    h4("Rozkład spożycia w ciągu dnia"),
                    p("Gęstość spożycia napojów kofeinowych według godziny."),
                    plotOutput("caffeine_density", height = "400px")
                  )
                ),
                column(
                  3,
                  div(
                    class = "bento-card",
                    uiOutput("caffeine_time_summary")
                  )
                )
              )
            )
          )
          ,
          tabPanel(
            categories$sleep,
            fluidPage(
              br(),
              fluidRow(
                column(
                  12,
                  div(
                    class = "bento-card",
                    airDatepickerInput(
                      inputId = "sleep_days_range",
                      label = "Zakres dat:",
                      range = TRUE,
                      toggleSelected = FALSE,
                      value = c(as.Date("2025-12-01"), as.Date("2025-12-31")),
                      autoClose = TRUE,
                      minDate = min(sleep_df$date),
                      maxDate = max(sleep_df$date),
                      width = "100%"
                    )
                  )
                )
              ),
              
              fluidRow(
                column(
                  9,
                  div(
                    class = "bento-card",
                    h4("Ilość snu w czasie"),
                    p("Liczba godzin snu w kolejnych dniach."),
                    plotOutput("sleep_hours_bar", height = "400px")
                  )
                ),
                column(
                  3,
                  div(
                    class = "bento-card",
                    h4("Podsumowanie snu"),
                    uiOutput("sleep_summary_text")
                  )
                )
              ),
              
              br(),
              fluidRow(
                column(
                  6,
                  div(
                    class = "bento-card",
                    h4("Godziny zasypiania"),
                    p("Rozkład godzin pójścia spać."),
                    plotOutput("sleep_bed_hist", height = "350px")
                  )
                ),
                column(
                  6,
                  div(
                    class = "bento-card",
                    h4("Godziny wstawania"),
                    p("Rozkład godzin wstawania."),
                    plotOutput("sleep_wake_hist", height = "350px")
                  )
                )
              ),
              
              br(),
              fluidRow(
                column(
                  12,
                  div(
                    class = "bento-card",
                    h4("Zasypianie a dzień tygodnia"),
                    p("Rozkład godzin zasypiania w zależności od dnia."),
                    uiOutput("weeksleep_dynamic", height = "450px")
                  )
                )
              ),
              br()
            )
          ),
          
          tabPanel(categories$screen, 
                   fluidPage(
                     br(),
                     fluidRow(
                       column(12,
                              div(class = "bento-card",
                                  airDatepickerInput(
                                    inputId = "screen_days_range",
                                    label = "Zakres dat:",
                                    range = TRUE,
                                    toggleSelected = FALSE,
                                    value = c(as.Date("2025-12-01"), as.Date("2025-12-31")),
                                    autoClose = TRUE,
                                    minDate = min(screen_df$date),
                                    maxDate = max(screen_df$date),
                                    width = "100%"
                                  ))
                       )
                     ),
                     
                     hr(),
                     fluidRow(
                       column(9, 
                              div(class = "bento-card",
                                  h4("Czas przed ekranem (h)"),
                                  plotOutput("screen_time_bar", height = "400px")
                              )
                       ),
                       column(3, 
                              div(class = "bento-card",
                                  h4("Podsumowanie czasu"),
                                  uiOutput("screen_time_summary_text")
                              )
                       )
                     ),
                     
                     hr(),
                     fluidRow(
                       column(9, 
                              div(class = "bento-card",
                                  h4("Powiadomienia"),
                                  p("Analiza liczby otrzymanych powiadomień w ciągu dnia."),
                                  plotOutput("notifications_bar", height = "400px")
                              )
                       ),
                       column(3, 
                              div(class = "bento-card",
                                  h4("Podsumowanie czasu"),
                                  uiOutput("notifications_summary_text")
                              )
                       )
                     ),
                     fluidRow(
                       column(6, 
                              div(class = "bento-card", 
                                  h4("Z jakiej aplikacji kożystamy najczęściej?"),
                                  p("Wielkość słowa = łączny czas w aplikacji."),
                                  plotOutput("screen_time_cloud", height = "400px")
                              )
                       ),
                       column(6, 
                              div(class = "bento-card", 
                                  h4("Z której aplikacji dostajemy najwięcej powiadomień?"),
                                  p("Wielkość słowa = liczba powiadomień."),
                                  plotOutput("notifications_cloud", height = "400px")
                              )
                       )
                     ),
                     fluidRow(
                       column(12,
                              div(class = "bento-card",
                                  h4("Jaka jest zależność między czasem przed ekranem a liczbą powiadomień?"),
                                  plotOutput("correlation_plot", height = "500px")
                              ))
                     ),
                     
                     fluidRow(
                       column(6, 
                              div(class = "bento-card", 
                                  h4("Ile minut spędzamy w aplikacji na każde 1 powiadomienie?"),
                                  p("Wskaźnik zaangażowania"),
                                  plotOutput("engagement_plot", height = "400px")
                              )
                       ),
                       column(6, 
                              div(class = "bento-card", 
                                  h4("W które dni tygodnia spędzamy najwięcej czasu na telefonie?"),
                                  p("Analiza dni tygodnia"),
                                  uiOutput("weekday_dynamic", height = "400px")
                              )
                       )
                     )
                     
                   )
          ))
      )
    )
  ),
  
  tabPanel(
    "Overview",
    fluidPage(
      br(),
      div(
        style = "display: flex; justify-content: space-between; align-items: center;",
        h2("Podsumowanie indywidualne"),
        actionLink(
          "show_all_overview",
          div(
            style = "
      padding: 12px 30px;
      background: #2d3436;
      color: white;
      border-radius: 30px;
      font-family: 'Outfit', sans-serif;
      font-weight: 600;
      letter-spacing: 1px;
      box-shadow: 0 6px 15px rgba(0,0,0,0.15);
      transition: all 0.3s ease;
    ",
            icon("users"),
            span(" Pokaż wszystkich")
          ),
          style = "text-decoration: none;"
        )
      ),
      hr(),
      uiOutput("ui_overview")
    )
  ),
  
  tabPanel(
    "Mini Quiz", 
    fluidPage(
      column(8, offset = 2,
             br(),
             div(class = "bento-card",
                 style = "text-align: center; padding: 40px;",
                 h2("TEST WIEDZY O NAS"),
                 p("Sprawdź, jak dobrze nas znasz! Rozwiąż krótki quiz oparty na naszych danych."),
                 
                 quiz_ui(quiz)
             )
      )
    )
  ))
