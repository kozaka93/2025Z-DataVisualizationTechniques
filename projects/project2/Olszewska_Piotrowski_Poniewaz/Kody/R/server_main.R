source("R/plots_all.R")
server <- function(input, output, session) {
  
  observe({
    ordered_dates <- screen_df %>%
      arrange(date) %>%
      pull(date) %>%
      unique()
    updatePickerInput(session, "screen_days_range",
                      choices = ordered_dates,
                      selected = ordered_dates)
  })
  
  observe({
    ordered_dates <- sleep_df %>%
      arrange(date) %>%
      pull(date) %>%
      unique()
    updatePickerInput(session, "sleep_days_filter",
                      choices = ordered_dates,
                      selected = ordered_dates
    )
  })
  
  observe({
    ordered_dates <- caffeine_df %>%
      arrange(date) %>%
      pull(date) %>%
      unique()
    updatePickerInput(session, "caffeine_days_filter",
                      choices = ordered_dates,
                      selected = ordered_dates
    )
  })
  
  
  overview_selection <- reactiveVal(persons)
  observeEvent(input$go_analysis, { updateNavbarPage(session, "topnav", selected = "Analiza") })
  
  
  observeEvent(input$jump_kacper, {
    overview_selection("Kacper")
    updateNavbarPage(session, "topnav", selected = categories$overview)
  })
  observeEvent(input$jump_emilka, {
    overview_selection("Emilka")
    updateNavbarPage(session, "topnav", selected = categories$overview)
  })
  observeEvent(input$jump_bartek, {
    overview_selection("Bartek")
    updateNavbarPage(session, "topnav", selected = categories$overview)
  })
  observeEvent(input$show_all_overview, { overview_selection(persons) })
  
  
  selected_people <- reactive({
    sel <- input$person_choice
    if (is.null(sel) || "all" %in% sel) persons else sel
  })
  
  output$selected_avatar <- renderUI({
    ppl <- selected_people() 
    fluidRow(
      lapply(ppl, function(nm) {
        if (!is.null(avatars[[nm]])) {
          a <- avatars[[nm]]
          column(12, avatar_box(a$img, nm, 90, a$y))
        }
      })
    )
  })
  
  
  filtered_screen_data <- reactive({
    req(input$screen_days_range)
    screen_df %>%
      filter(
        imie %in% selected_people(),
        date >= input$screen_days_range[1],
        date <= input$screen_days_range[2]
      )
  })
  
  filtered_caffeine_data <- reactive({
    req(input$caffeine_days_range)
    caffeine_df %>%
      filter(
        imie %in% selected_people(),
        date >= input$caffeine_days_range[1],
        date <= input$caffeine_days_range[2]
      )
  })
  
  filtered_sleep_data <- reactive({
    req(input$sleep_days_range)
    sleep_df %>%
      filter(
        imie %in% selected_people(),
        date >= input$sleep_days_range[1],
        date <= input$sleep_days_range[2]
      )
  })
  

  output$sleep_hours_bar <- renderPlot({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_hours_bar(d, person_colors)
  })
  
  output$sleep_bed_hist <- renderPlot({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_bed_hist(d, person_colors)
  })
  
  output$sleep_wake_hist <- renderPlot({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_wake_hist(d, person_colors)
  })
  
  output$screen_time_bar <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_screen_time_bar(d, person_colors)
  })
  
  output$screen_time_cloud <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_screen_time_cloud(d)
  })
  
  output$notifications_bar <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_notifications_bar(d, person_colors)
  })
  
  output$notifications_cloud <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_notifications_cloud(d)
  })
  
  output$correlation_plot <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_correlation_plot(d, person_colors)
  })
  
  output$engagement_plot <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_engagement_plot(d, person_colors)
  })
  
  output$screentime_weekday_table <- renderTable({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_screentime_weekday_table(d, screen_df)
  })
  
  output$weekday_plot <- renderPlot({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_weekday_plot(d, selected_people(), person_colors)
  })
  
  output$weekday_dynamic <- renderUI({
    req(input$screen_days_range)
    if (input$screen_days_range[1] == input$screen_days_range[2]) {
      tagList(
      p("Radar plot nie ma sensu dla jednego dnia. Poniżej porównanie do średniej miesięcznej."),
      div(style = "overflow-x:auto;", tableOutput("screentime_weekday_table")))
      }
    else {plotOutput("weekday_plot", height = "400px")}
  })
  
  output$sleep_bed_weekday_plot <- renderPlot({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_weekday_plot(d, selected_people(), person_colors)
  })
  
  output$sleep_bed_weekday_table <- renderTable({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_weekday_table(d, sleep_df)
  })
  
  output$weeksleep_dynamic <- renderUI({
    req(input$sleep_days_range)
    if (input$sleep_days_range[1] == input$sleep_days_range[2]) {
      tagList(
        p("Radar plot nie ma sensu dla jednego dnia. Poniżej porównanie do średniej miesięcznej."),
        div(style = "overflow-x:auto;", tableOutput("sleep_bed_weekday_table")))
    }
    else {plotOutput("sleep_bed_weekday_plot", height = "400px")}
  })
  
  output$screen_time_summary_text <- renderUI({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_screen_time_summary_text(d)
  })
  
  output$sleep_summary_text <- renderUI({
    d <- filtered_sleep_data()
    req(nrow(d) > 0)
    make_sleep_summary_text(d)
  })
  
  output$caffeine_summary_text <- renderUI({
    d <- filtered_caffeine_data()
    req(nrow(d) > 0)
    make_caffeine_summary_text(d)
  })
  
  output$caffeine_time_summary <- renderUI({
    d <- filtered_caffeine_data()
    req(nrow(d) > 0)
    make_caffeine_time_summary(d)
  })
  
  output$notifications_summary_text <- renderUI({
    d <- filtered_screen_data()
    req(nrow(d) > 0)
    make_notifications_summary_text(d)
  })
  
  output$caffeine_avg_bar <- renderPlot({
    d <- filtered_caffeine_data()
    req(nrow(d) > 0)
    make_caffeine_avg_bar(d, selected_people(), person_colors, drink_variant_colors, drink_variant_labels)
  })
  
  output$caffeine_density <- renderPlot({
    d <- filtered_caffeine_data()
    req(nrow(d) > 0)
    make_caffeine_density(d, selected_people(), person_colors, drink_variant_colors, drink_variant_labels)
  })
  
  
  output$ui_overview <- renderUI({
    
    tagList(
      lapply(overview_selection(), function(nm) {
        color <- person_colors[nm]
        sd <- screen_df %>% filter(imie == nm)
        
        daily_screen <- sd %>%
          group_by(date) %>%
          summarise(total_min = sum(minuty, na.rm = TRUE), .groups = "drop")
        
        avg_screen_h <- mean(daily_screen$total_min, na.rm = TRUE) / 60
        
        no_life_day <- daily_screen %>%
          mutate(
            wd = get_weekday_pl(date)
          ) %>%
          filter(!is.na(wd)) %>%
          slice_max(total_min, n = 1, with_ties = FALSE) %>%
          pull(wd)
        
        top_app <- sd %>%
          group_by(aplikacja) %>%
          summarise(s = sum(minuty, na.rm = TRUE), .groups = "drop") %>%
          slice_max(s, n = 1, with_ties = FALSE) %>%
          pull(aplikacja)
        
        daily_notif <- sd %>%
          group_by(date) %>%
          summarise(n = sum(powiadomienia, na.rm = TRUE), .groups = "drop")
        
        avg_notif <- mean(daily_notif$n, na.rm = TRUE)
        
        top_notif_app <- sd %>%
          group_by(aplikacja) %>%
          summarise(n = sum(powiadomienia, na.rm = TRUE), .groups = "drop") %>%
          slice_max(n, n = 1, with_ties = FALSE) %>%
          pull(aplikacja)
        
        engagement_app <- sd %>%
          group_by(aplikacja) %>%
          summarise(
            t = sum(minuty, na.rm = TRUE),
            n = sum(powiadomienia, na.rm = TRUE),
            .groups = "drop"
          ) %>% filter(n!=0) %>% 
          mutate(ratio = t / n) %>%
          slice_max(ratio, n = 1, with_ties = FALSE) %>%
          pull(aplikacja)
        
        sl <- sleep_df %>% filter(imie == nm)
        avg_sleep <- mean(sl$sen_h, na.rm = TRUE)
        avg_wake <- mean(sl$wake_min, na.rm = TRUE)
        
        avg_wake_time <- if (is.na(avg_wake)) {
          "Brak danych"
        } else {
          sprintf(
            "%02d:%02d",
            floor(avg_wake / 60),
            round(avg_wake %% 60)
          )
        }
        
        min_sleep_day <- sl %>%
          mutate(wd = get_weekday_pl(date)) %>%
          group_by(wd) %>%
          summarise(avg = mean(sen_h, na.rm = TRUE), .groups = "drop") %>%
          slice_min(avg, n = 1, with_ties = FALSE) %>%
          pull(wd)
        
        cf <- caffeine_df %>% filter(imie == nm)
        
        daily_kofeina <- cf %>%
          group_by(date) %>%
          summarise(total = sum(kofeina_mg), .groups = "drop")
        
        avg_kofeina <- mean(daily_kofeina$total, na.rm = TRUE)
        
        top_caffeine_type <- cf %>%
          group_by(typ) %>%
          summarise(s = sum(kofeina_mg), .groups = "drop") %>%
          slice_max(s, n = 1, with_ties = FALSE) %>%
          pull(typ)
        
        max_caffeine_day <- cf %>%
          mutate(wd = get_weekday_pl(date)) %>%
          group_by(wd) %>%
          summarise(avg = mean(kofeina_mg), .groups = "drop") %>%
          slice_max(avg, n = 1, with_ties = FALSE) %>%
          pull(wd)
        
        tags$div(
          style = paste0(
            "padding:25px; margin-bottom:25px; border-radius:15px;",
            "background:#ffffff; border-left:10px solid ", color, ";",
            "box-shadow:0 6px 15px rgba(0,0,0,0.08);"
          ),
          fluidRow(
            column(2, avatar_box(avatars[[nm]]$img, nm, 110, avatars[[nm]]$y)),
            column(
              10,
              h3(paste("Karta Analityczna –", nm),
                 style = paste0("color:", color, "; font-weight:bold;")),
              hr(),
              fluidRow(
                column(
                  3,
                  section_box(
                    "Czas ekranowy", "📱", color,
                    tagList(
                      p(paste("• Średnio:", round(avg_screen_h, 1), "h")),
                      p(paste("• Dzień No-Life:", no_life_day)),
                      p(paste("• Top apka:", top_app))
                    )
                  )
                ),
                column(
                  3,
                  section_box(
                    "Powiadomienia", "🔔", color,
                    tagList(
                      p(paste("• Średnio:", round(avg_notif))),
                      p(paste("• Najwięcej:", top_notif_app)),
                      p(paste("• Złodziej:", engagement_app))
                    )
                  )
                ),
                column(
                  3,
                  section_box(
                    "Sen", "🛌", color,
                    tagList(
                      p(paste("• Średnio:", round(avg_sleep, 1), "h")),
                      p(paste("• Pobudka ok.:", avg_wake_time)),
                      p(paste("• Najmniej snu:", min_sleep_day))
                    )
                  )
                ),
                column(
                  3,
                  section_box(
                    "Kofeina", "☕", color,
                    tagList(
                      p(paste("• Średnio:", round(avg_kofeina), "mg")),
                      p(paste("• Główne źródło:", top_caffeine_type)),
                      p(paste("• Najwięcej w:", max_caffeine_day))
                    )
                  )
                )
              )
              
            )
          )
        )
      })
    )
  })
  quiz_server(quiz)
}