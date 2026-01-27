make_screen_time_bar <- function(data,person_colors) {
  
  unique_days <- unique(data$date)
  
  if (length(unique_days) == 1) {
    app_data <- data %>%
      group_by(aplikacja, imie) %>%
      summarise(val = sum(minuty, na.rm = TRUE) / 60, .groups = 'drop')
    
    top_apps_names <- app_data %>%
      group_by(aplikacja) %>%
      summarise(total = sum(val)) %>%
      arrange(desc(total)) %>%
      head(15) %>%
      pull(aplikacja)
    
    plot_data <- app_data %>% filter(aplikacja %in% top_apps_names)
    
    ggplot(plot_data, aes(x = reorder(aplikacja, -val), y = val, fill = imie)) +
      geom_col(
        width = 0.7,
        position = position_dodge2(
          width = 0.5,
          preserve = "single"
        )) +
      scale_fill_manual(values = person_colors) +
      labs(title = paste("Top 15 aplikacji w dniu", unique_days[1]), 
           x = "Aplikacja", 
           y = "Godziny (h)", 
           fill = "Osoba") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"))
    
  } else {
    plot_data <- data %>%
      group_by(date, imie) %>%
      summarise(val = sum(minuty, na.rm = TRUE)/60, .groups = 'drop')
    
    plot_data$date_label <- format(plot_data$date, "%d.%m")
    chronological_order <- format(sort(unique(plot_data$date)), "%d.%m")
    plot_data$date_label <- factor(plot_data$date_label, levels = chronological_order)
    
    ggplot(plot_data, aes(x = date_label, y = val, color = imie, group = imie)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      scale_color_manual(values = person_colors) +
      labs(
        title = "Dzienny czas przed ekranem",
        x = "Data",
        y = "Godziny (h)",
        color = "Osoba"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
}


make_screen_time_summary_text <- function (data) {
  
  total_min <- sum(data$minuty, na.rm = TRUE)
  num_people <- length(unique(data$imie))
  num_days   <- length(unique(data$date))
  h <- floor(total_min / 60)
  m <- round(total_min %% 60)
  
  h_os <-floor((total_min /(num_days*num_people))/60)
  m_os <- round((total_min /(num_days*num_people))%%60)
  
  
  tagList(
    h1(paste0(h, "h ", m, "m"), style = "font-size: 36px; font-weight: bold; color: #333;"),
    p("Całkowity czas przed ekranem dla zaznaczonych osób i dni."),
    br(),
    p(strong("Średnio dziennie:"), paste0(h_os, "h ", m_os, "m")," na osobe")
  )
}


make_screen_time_cloud <- function (data) {
  
  cloud_data <- data %>%
    group_by(aplikacja) %>%
    summarise(weight = sum(minuty, na.rm = TRUE)) %>%
    arrange(desc(weight))
  
  par(mar = c(0, 0, 0, 0))
  
  wordcloud(words = cloud_data$aplikacja, 
            freq = cloud_data$weight, 
            min.freq = 1,
            max.words = 50,
            random.order = FALSE,
            rot.per = 0.35,
            colors = magma(10, begin = 0.2, end = 0.7),
            scale = c(3.5, 0.9))
}


make_notifications_bar <- function(data, person_colors){
  
  unique_days <- unique(data$date)
  
  if (length(unique_days) == 1) {
    app_data <- data %>%
      group_by(aplikacja, imie) %>%
      summarise(val = sum(powiadomienia, na.rm = TRUE), .groups = 'drop')
    
    top_apps_names <- app_data %>%
      group_by(aplikacja) %>%
      summarise(total = sum(val)) %>%
      arrange(desc(total)) %>%
      head(15) %>%
      pull(aplikacja)
    
    plot_data <- app_data %>% filter(aplikacja %in% top_apps_names)
    
    ggplot(plot_data, aes(x = reorder(aplikacja, -val), y = val, fill = imie)) +
      geom_col(
        width = 0.6,
        position = position_dodge2(
          width = 0.7,
          preserve = "single"
        )) +
      scale_fill_manual(values = person_colors) +
      labs(title = paste("Najbardziej absorbujące aplikacje w dniu", unique_days[1]), 
           x = "Aplikacja", 
           y = "Liczba powiadomień", 
           fill = "Osoba") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"))
    
  } else {
    plot_data <- data %>%
      group_by(date, imie) %>%
      summarise(val = sum(powiadomienia, na.rm = TRUE), .groups = 'drop')
    
    plot_data$date_label <- format(plot_data$date, "%d.%m")
    chronological_order <- format(sort(unique(plot_data$date)), "%d.%m")
    plot_data$date_label <- factor(plot_data$date_label, levels = chronological_order)
    
    ggplot(plot_data, aes(x = date_label, y = val, color = imie, group = imie)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      scale_color_manual(values = person_colors) +
      labs(title = "Liczba powiadomień dziennie", x = "Data", y = "Liczba", color = "Osoba") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
}


make_notifications_summary_text <- function(data){
  
  total_notif <- sum(data$powiadomienia, na.rm = TRUE)
  num_people <- length(unique(data$imie))
  num_days <- length(unique(data$date))
  avg_powiadomienia <- round(total_notif / (num_days * num_people),0)
  tagList(
    h1(format(total_notif, big.mark = " "), style = "font-size: 36px; font-weight: bold; color: #333;"),
    p("Łączna liczba powiadomień dla zaznaczonych osób i dni."),
    br(),
    p(strong("Średnio dziennie:"), avg_powiadomienia, "powiadomienia na osobe")
  )
}


make_notifications_cloud <- function(data){
  
  cloud_data <- data %>%
    group_by(aplikacja) %>%
    summarise(weight = sum(powiadomienia, na.rm = TRUE)) %>%
    arrange(desc(weight))
  par(mar = c(0, 0, 0, 0))
  wordcloud(words = cloud_data$aplikacja, 
            freq = cloud_data$weight, 
            min.freq = 1,
            max.words = 50,
            random.order = FALSE,
            rot.per = 0.20,
            colors = magma(10, begin = 0.2, end = 0.7),
            scale = c(4, 0.8))
}


make_correlation_plot <- function(data,person_colors){
  data <- data%>% tidyr::drop_na(powiadomienia, minuty)
  req(nrow(data) > 0)
  
  unique_days <- unique(data$date)
  
  if (length(unique_days) == 1) {
    app_stats <- data %>%
      group_by(imie, aplikacja) %>%
      summarise(
        app_time  = sum(minuty, na.rm = TRUE),
        app_notif = sum(powiadomienia, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      filter(app_time > 0 & app_notif > 0)
    
    req(nrow(app_stats) > 0)
    
    ggplot(app_stats, aes(x = app_notif, y = app_time, color = imie))+
      geom_point(alpha = 0.75, size = 4) +
      scale_y_log10(labels = scales::label_log())+
      scale_x_log10(labels = scales::label_log())+
      scale_color_manual(values = person_colors) +
      labs(
        title = paste0("Zależność: powiadomienia vs czas (", unique_days[1], ")"),
        subtitle = "Każdy punkt to aplikacja (osobno dla każdej osoby)",
        x = "Powiadomienia w aplikacji (suma)",
        y = "Czas w aplikacji (minuty)",
        color = "Osoba"
      ) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
    
  } else {
    daily_stats <- data %>%
      group_by(date, imie) %>%
      summarise(
        daily_time = sum(minuty, na.rm = TRUE),
        daily_notif = sum(powiadomienia, na.rm = TRUE),
        .groups = 'drop'
      )
    
    ggplot(daily_stats, aes(x = daily_notif, y = daily_time, color = imie)) +
      geom_point(size = 4, alpha = 0.7) + 
      geom_smooth(method = "lm", se = FALSE, size = 1.5) +
      scale_color_manual(values = person_colors) +
      labs(
        title = "Zależność między powiadomieniami a czasem przed ekranem",
        subtitle = "Analiza dzienna (Im więcej powiadomień, tym więcej czasu?)",
        x = "Liczba powiadomień w ciągu dnia",
        y = "Czas przed ekranem (minuty)",
        color = "Osoba"
      ) +
      theme_minimal() +
      theme(
        text = element_text(size = 14),
        legend.position = "bottom"
      )
  }
}


make_engagement_plot <- function(data,person_colors){
  
  eng_data <- data %>%
    group_by(aplikacja, imie) %>%
    summarise(
      total_time = sum(minuty, na.rm = TRUE),
      total_notif = sum(powiadomienia, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    mutate(ratio = total_time / (total_notif + 1)) %>%
    filter(total_time > 5) %>%
    group_by(imie) %>%
    slice_max(order_by = ratio, n = 5)
  
  ggplot(eng_data, aes(x = fct_reorder(aplikacja, ratio), y = ratio, fill = imie)) +
    geom_col(
      width = 0.7,
      position = position_dodge2(
        width = 0.5,
        preserve = "single"
      )) +
    coord_flip() +
    scale_fill_manual(values = person_colors) +
    labs(x = NULL, y = "Minuty na jedno powiadomienie", fill = "Osoba") +
    theme_minimal(base_size = 14) +
    theme(legend.position = "bottom")
}



make_weekday_plot <- function(data,selected_people, person_colors){
  
  daily_totals <- data %>%
    mutate(
      wday_num = lubridate::wday(date, week_start = 1)
    ) %>%
    group_by(imie, date, wday_num) %>%
    summarise(suma_dnia = sum(minuty, na.rm = TRUE), .groups = 'drop')
  
  radar_prep <- daily_totals %>%
    group_by(imie, wday_num) %>%
    summarise(avg_h = mean(suma_dnia, na.rm = TRUE) / 60, .groups = 'drop') %>%
    tidyr::complete(imie, wday_num = 1:7, fill = list(avg_h = 0)) %>%
    arrange(wday_num) %>%
    mutate(wd_label = WEEKDAYS_PL[wday_num]) %>%
    select(-wday_num) %>%
    tidyr::pivot_wider(names_from = wd_label, values_from = avg_h)
  
  plot_data <- radar_prep %>% filter(imie %in% selected_people)
  
  if(nrow(plot_data) > 0) {
    mat_data <- as.matrix(plot_data[, WEEKDAYS_PL])
    mode(mat_data) <- "numeric"
    
    max_val <- max(mat_data, na.rm = TRUE)
    upper_limit <- if(max_val < 1) 1 else ceiling(max_val)
    
    radar_final <- as.data.frame(rbind(rep(upper_limit, 7), rep(0, 7), mat_data))
    
    active_ppl <- plot_data$imie
    cols_border <- person_colors[active_ppl]
    cols_fill <- scales::alpha(cols_border, 0.3)
    
    par(mar = c(2, 2, 4, 2))
    radarchart(
      radar_final, 
      axistype = 1, 
      pcol = cols_border, 
      pfcol = cols_fill, 
      plwd = 4, 
      cglcol = "grey80", 
      axislabcol = "grey30", 
      caxislabels = seq(0, upper_limit, length.out = 5),
      vlcex = 1.2, 
      title = "Średni łączny czas dzienny (h)"
    )
    
    legend(x = "topright", legend = active_ppl, bty = "n", pch = 20, 
           col = cols_border, cex = 1.2, pt.cex = 2)
  }
}


make_caffeine_avg_bar <- function(df, selected_people, person_colors, drink_variant_colors, drink_variant_labels) {
  
  time_range <- as.numeric(diff(range(df$date))) + 1
  
  if (length(selected_people) > 1) {
    plot_data <- df %>%
      group_by(imie, typ) %>%
      summarise(daily_ml = sum(ilosc_ml), .groups = "drop") %>%
      group_by(imie, typ) %>%
      summarise(avg_ml = daily_ml/time_range, .groups = "drop")
    
    ggplot(plot_data, aes(x = typ, y = avg_ml, fill = imie)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = person_colors) +
      labs(
        x = "Typ napoju",
        y = "Średnia dzienna ilość (ml)",
        fill = "Osoba"
      ) +
      theme_minimal(base_size = 14)
    
  } else {
    plot_data <- df %>%
      group_by(typ, rodzaj) %>%
      summarise(daily_ml = sum(ilosc_ml), .groups = "drop") %>%
      group_by(typ, rodzaj) %>%
      summarise(avg_ml = daily_ml/time_range, .groups = "drop") %>%
      mutate(drink_variant = paste(typ, rodzaj, sep = "_"))
    
    ggplot(plot_data, aes(x = typ, y = avg_ml, fill = drink_variant)) +
      geom_col(position = "dodge") +
      scale_fill_manual(
        values = drink_variant_colors,
        labels = drink_variant_labels,
        drop = FALSE
      ) +
      labs(
        x = "Typ napoju",
        y = "Średnia dzienna ilość (ml)",
        fill = "Rodzaj"
      ) +
      theme_minimal(base_size = 14)
  }
}


make_caffeine_density <- function(df, selected_people, person_colors, drink_variant_colors, drink_variant_labels) {
  
  if (length(selected_people) > 1) {
    ggplot(df, aes(x = godzina_h, color = imie, fill = imie)) +
      geom_density(alpha = 0.3, linewidth = 1) +
      scale_color_manual(values = person_colors) +
      scale_fill_manual(values = person_colors) +
      labs(
        x = "Godzina dnia",
        y = "Gęstość",
        color = "Osoba",
        fill = "Osoba"
      ) +
      theme_minimal(base_size = 14)
    
  } else {
    df <- df %>% mutate(drink_variant = paste(typ, rodzaj, sep = "_"))
    ggplot(df, aes(x = godzina_h, color = drink_variant, fill = drink_variant)) +
      geom_density(alpha = 0.3, linewidth = 1) +
      scale_color_manual(
        values = drink_variant_colors,
        labels = drink_variant_labels,
        drop = FALSE
      ) +
      scale_fill_manual(
        values = drink_variant_colors,
        labels = drink_variant_labels,
        drop = FALSE
      ) +
      labs(
        x = "Godzina dnia",
        y = "Gęstość",
        color = "Rodzaj",
        fill = "Rodzaj"
      ) +
      theme_minimal(base_size = 14)
  }
}


make_sleep_hours_bar <- function(df, person_colors) {
  
  unique_days <- unique(df$date)
  if (length(unique_days) == 1) {
    plot_data <- df %>%
      group_by(imie) %>%
      summarise(val = mean(sen_h, na.rm = TRUE), .groups = "drop")
    
    ggplot(plot_data, aes(x = imie, y = val, fill = imie)) +
      geom_col() +
      scale_fill_manual(values = person_colors) +
      labs(title = paste("Sen w dniu", unique_days[1]), x = "Osoba", y = "Godziny (sen_h)", fill = "Osoba") +
      theme_minimal()
  } else {
    plot_data <- df %>%
      group_by(date, imie) %>%
      summarise(val = mean(sen_h, na.rm = TRUE), .groups = "drop") %>%
      mutate(
        date_label = format(date, "%d.%m"),
        date_label = factor(date_label, levels = format(sort(unique(date)), "%d.%m"))
      )
    
    ggplot(plot_data, aes(x = date_label, y = val, fill = imie)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = person_colors) +
      labs(title = "Godziny snu dziennie", x = "Data", y = "Godziny (sen_h)", fill = "Osoba") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
}


make_sleep_bed_hist <- function(s, person_colors) {
  
  plot_data <- s %>%
    mutate(
      bed_h_wrap = ifelse(bed_h < 12, bed_h + 24, bed_h)
    )
  
  ggplot(plot_data, aes(x = bed_h_wrap, fill = imie)) +
    geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.45) +
    scale_fill_manual(values = person_colors) +
    scale_x_continuous(
      breaks = seq(20, 30, by = 1),
      labels = function(x) sprintf("%02d:00", as.integer(x %% 24))
    ) +
    labs(title = "Histogram: godziny zasypiania", x = "Godzina", y = "Liczba dni", fill = "Osoba") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}


make_sleep_wake_hist <- function(s, person_colors) {
  
  ggplot(s, aes(x = wake_h, fill = imie)) +
    geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.45) +
    scale_fill_manual(values = person_colors) +
    scale_x_continuous(
      breaks = seq(5, 12, by = 1),
      labels = function(x) sprintf("%02d:00", as.integer(x))
    ) +
    labs(title = "Histogram: godziny wstawania", x = "Godzina", y = "Liczba dni", fill = "Osoba") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}


make_sleep_bed_weekday <- function(s, person_colors){
  
  plot_data <- s %>%
    mutate(
      weekday = factor(weekdays(date), levels = WEEKDAYS_PL),
      bed_h_wrap = ifelse(bed_h < 12, bed_h + 24, bed_h)
    )
  
  means <- plot_data %>%
    group_by(weekday, imie) %>%
    summarise(mean_bed = mean(bed_h_wrap, na.rm = TRUE), .groups = "drop")
  
  ggplot() +
    geom_col(data = means, aes(x = weekday, y = mean_bed, fill = imie), position = "dodge", alpha = 0.85) +
    geom_point(
      data = plot_data,
      aes(x = weekday, y = bed_h_wrap, color = imie),
      alpha = 0.35,
      position = position_jitterdodge(jitter.width = 0.15, dodge.width = 0.9)
    ) +
    scale_fill_manual(values = person_colors) +
    scale_color_manual(values = person_colors) +
    scale_y_continuous(
      breaks = seq(20, 30, by = 1),
      labels = function(x) sprintf("%02d:00", as.integer(x %% 24))
    ) +
    labs(
      title = "Godzina zasypiania vs dzień tygodnia",
      subtitle = "Słupki = średnia, punkty = pojedyncze dni",
      x = "Dzień tygodnia",
      y = "Godzina zasypiania",
      fill = "Osoba",
      color = "Osoba"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

make_sleep_weekday_plot <- function(data, selected_people, person_colors) {
  
  daily_sleep <- data %>% mutate(wday_num = lubridate::wday(date, week_start = 1)) %>% 
    group_by(imie, date, wday_num) %>%
    summarise(sen_dnia = mean(sen_h, na.rm = TRUE), .groups = "drop")
  
  radar_prep <- daily_sleep %>%
    group_by(imie, wday_num) %>%
    summarise(avg_sleep = mean(sen_dnia, na.rm = TRUE), .groups = "drop") %>%
    tidyr::complete(imie, wday_num = 1:7, fill = list(avg_sleep = 0)) %>%
    arrange(imie, wday_num) %>%
    mutate(wd_label = WEEKDAYS_PL[wday_num]) %>%
    select(imie, wd_label, avg_sleep) %>%
    tidyr::pivot_wider(names_from = wd_label, values_from = avg_sleep)
  
  plot_data <- radar_prep %>% filter(imie %in% selected_people)
  
  mat_data <- as.matrix(plot_data[, WEEKDAYS_PL])
  mode(mat_data) <- "numeric"
  
  max_val <- max(mat_data, na.rm = TRUE)
  upper_limit <- if (max_val < 1) 1 else ceiling(max_val)
  
  radar_final <- as.data.frame(rbind(rep(upper_limit, 7), rep(0, 7), mat_data))
  
  active_ppl <- plot_data$imie
  cols_border <- person_colors[active_ppl]
  cols_fill <- scales::alpha(cols_border, 0.30)
  
  par(mar = c(2, 2, 4, 2))
  fmsb::radarchart(
    radar_final,
    axistype = 1,
    pcol = cols_border,
    pfcol = cols_fill,
    plwd = 4,
    cglcol = "grey80",
    axislabcol = "grey30",
    caxislabels = seq(0, upper_limit, length.out = 5),
    vlcex = 1.2,
    title = "Średnia długość snu (h) wg dnia tygodnia"
  )
  
  legend("topright", legend = active_ppl, bty = "n", pch = 20,
         col = cols_border, cex = 1.2, pt.cex = 2)
}


make_sleep_summary_text <- function(df) {
  req(nrow(df) > 0)
  
  total_sleep_h <- sum(df$sen_h, na.rm = TRUE)
  avg_sleep_per_person <- mean(df$sen_h, na.rm = TRUE)
  
  tagList(
    h1(
      paste0(round(total_sleep_h, 1), " h"),
      style = "font-size: 36px; font-weight: bold;"
    ),
    p("Łączna liczba godzin snu w wybranym okresie."),
    br(),
    p(
      strong("Średnio dziennie na osobę:"),
      round(avg_sleep_per_person, 2), "h"
    )
  )
}


make_caffeine_summary_text <- function(df) {
  req(nrow(df) > 0)
  
  total_kofeina <- sum(df$kofeina_mg, na.rm = TRUE)
  
  daily <- df %>%
    group_by(imie, date) %>%
    summarise(daily_mg = sum(kofeina_mg), .groups = "drop")
  
  avg_daily <- mean(daily$daily_mg, na.rm = TRUE)
  
  tagList(
    h1(
      paste0(round(total_kofeina), " mg"),
      style = "font-size: 36px; font-weight: bold;"
    ),
    p("Łączna ilość spożytej kofeiny."),
    br(),
    p(
      strong("Średnio dziennie na osobę:"),
      round(avg_daily), "mg"
    )
  )
}


make_caffeine_time_summary <- function(df) {
  req(nrow(df) > 0)
  
  df2 <- df %>%
    mutate(
      pora = case_when(
        godzina_h >= 5  & godzina_h <= 11 ~ "rano",
        godzina_h >= 12 & godzina_h <= 17 ~ "południe",
        godzina_h >= 18 & godzina_h <= 23 ~ "wieczór",
        TRUE ~ NA_character_
      )
    ) %>%
    filter(!is.na(pora))
  
  top_by_pora <- df2 %>%
    group_by(pora, typ) %>%
    summarise(total = sum(kofeina_mg, na.rm = TRUE), .groups = "drop") %>%
    group_by(pora) %>%
    slice_max(total, n = 1, with_ties = FALSE)
  
  get_top <- function(p) {
    x <- top_by_pora %>% filter(pora == p) %>% pull(typ)
    if (length(x) == 0) "brak danych" else x
  }
  
  tagList(
    h4("Rytm dnia (dominujący napój)"),
    p(strong("Rano:"), get_top("rano")),
    p(strong("Południe:"), get_top("południe")),
    p(strong("Wieczór:"), get_top("wieczór"))
  )
}

make_sleep_weekday_table <- function(d_day, sleep_df_month) {
  
  stopifnot(nrow(d_day) > 0)

  h_to_hm <- function(x) {
    ifelse(
      is.na(x),
      NA_character_,
      {
        mins <- round(x * 60)
        h <- floor(mins / 60)
        m <- mins %% 60
        paste0(h, "h ", m, "m")
      }
    )
  }
  
  h_to_clock <- function(x) {
    ifelse(
      is.na(x),
      NA_character_,
      {
        h <- as.integer(floor(x))
        m <- as.integer(round((x - h) * 60))
        sprintf("%02d:%02d", h %% 24, m)
      }
    )
  }
  

  sel_date <- unique(d_day$date)
  if (length(sel_date) != 1)
    stop("make_sleep_weekday_table: d_day musi zawierać dokładnie jedną datę")
  
  date_label <- format(sel_date, "%d.%m")
 
  day_vals <- d_day %>%
    group_by(imie) %>%
    summarise(
      sleep_h = mean(sen_h, na.rm = TRUE),
      bed_h   = mean(bed_h, na.rm = TRUE),
      wake_h  = mean(wake_h, na.rm = TRUE),
      .groups = "drop"
    )

  month_avg <- sleep_df_month %>%
    group_by(imie, date) %>%
    summarise(
      sleep_h = mean(sen_h, na.rm = TRUE),
      bed_h   = mean(bed_h, na.rm = TRUE),
      wake_h  = mean(wake_h, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    group_by(imie) %>%
    summarise(
      avg_sleep_h = mean(sleep_h, na.rm = TRUE),
      avg_bed_h   = mean(bed_h, na.rm = TRUE),
      avg_wake_h  = mean(wake_h, na.rm = TRUE),
      .groups = "drop"
    )
  
  per_person <- day_vals %>%
    left_join(month_avg, by = "imie") %>%
    mutate(
      sleep_day = h_to_hm(sleep_h),
      sleep_avg = h_to_hm(avg_sleep_h),
      bed_day   = h_to_clock(bed_h),
      bed_avg   = h_to_clock(avg_bed_h),
      wake_day  = h_to_clock(wake_h),
      wake_avg  = h_to_clock(avg_wake_h)
    ) %>%
    select(
      imie,
      sleep_day, sleep_avg,
      bed_day, bed_avg,
      wake_day, wake_avg
    )
  
  out <- bind_rows(
    tibble(Metryka = "Data", imie = per_person$imie, Wartosc = date_label),
    
    tibble(Metryka = "Czas snu", imie = per_person$imie, Wartosc = per_person$sleep_day),
    tibble(Metryka = "Średni czas snu", imie = per_person$imie, Wartosc = per_person$sleep_avg),
    
    tibble(Metryka = "Godzina zasypiania", imie = per_person$imie, Wartosc = per_person$bed_day),
    tibble(Metryka = "Średnia godzina zasypiania", imie = per_person$imie, Wartosc = per_person$bed_avg),
    
    tibble(Metryka = "Godzina pobudki", imie = per_person$imie, Wartosc = per_person$wake_day),
    tibble(Metryka = "Średnia godzina pobudki", imie = per_person$imie, Wartosc = per_person$wake_avg)
  ) %>%
    pivot_wider(names_from = imie, values_from = Wartosc) %>%
    arrange(match(
      Metryka,
      c(
        "Data",
        "Czas snu", "Średni czas snu",
        "Godzina zasypiania", "Średnia godzina zasypiania",
        "Godzina pobudki", "Średnia godzina pobudki"
      )
    ))
  
  out
}

make_screentime_weekday_table <- function(d_day, screen_df_month) {
  
  stopifnot(nrow(d_day) > 0)
  
  min_to_hm <- function(x) {
    ifelse(
      is.na(x),
      NA_character_,
      {
        x <- round(x)
        h <- floor(x / 60)
        m <- x %% 60
        paste0(h, "h ", m, "m")
      }
    )
  }
  
  sel_date <- unique(d_day$date)
  if (length(sel_date) != 1) {
    stop("make_screentime_weekday_table: d_day musi zawierać dokładnie jedną datę")
  }
  
  date_label <- format(sel_date, "%d.%m")
  
  day_vals <- d_day %>%
    dplyr::group_by(imie) %>%
    dplyr::summarise(
      day_min = sum(minuty, na.rm = TRUE),
      .groups = "drop"
    )
  
  month_daily <- screen_df_month %>%
    dplyr::group_by(imie, date) %>%
    dplyr::summarise(
      day_min = sum(minuty, na.rm = TRUE),
      .groups = "drop"
    )
  
  month_avg <- month_daily %>%
    dplyr::group_by(imie) %>%
    dplyr::summarise(
      avg_min = mean(day_min, na.rm = TRUE),
      .groups = "drop"
    )
  
  per_person <- day_vals %>%
    dplyr::left_join(month_avg, by = "imie") %>%
    dplyr::mutate(
      time_day = min_to_hm(day_min),
      time_avg = min_to_hm(avg_min)
    ) %>%
    dplyr::select(imie, time_day, time_avg)
  
  out <- dplyr::bind_rows(
    tibble::tibble(Metryka = "Data", imie = per_person$imie, Wartosc = date_label),
    tibble::tibble(Metryka = "Czas ekranowy", imie = per_person$imie, Wartosc = per_person$time_day),
    tibble::tibble(Metryka = "Średni czas ekranowy", imie = per_person$imie, Wartosc = per_person$time_avg)
  ) %>%
    tidyr::pivot_wider(names_from = imie, values_from = Wartosc) %>%
    dplyr::arrange(match(
      Metryka,
      c("Data", "Czas ekranowy", "Średni czas ekranowy")
    ))
  
  out
}
