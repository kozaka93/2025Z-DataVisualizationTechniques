library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(forcats)
library(patchwork)
library(tidyverse)
library(devtools)
library(bdgramR) #Te biblioteke trzeba pobrać z githuba, albo zakomentować 
#Kod do pobrania:
#install.packages("devtools")
#devtools::install_github("josedv82/bdgramR")
library(plotly)
library(lubridate)

Sys.setlocale("LC_TIME", "C")


#Zmienne globalne:

# Kalwas:
sessions <- read_csv("treningi.csv",skip = 1338, n_max = 2338) %>% 
  filter(!(ename %in% c("spacer farmera", "monster walk")))
muscles <- read.csv("muscles.csv",sep=";",fileEncoding = "Windows-1250",check.names = FALSE) %>% 
  pivot_longer(cols=everything(),names_to="ename",values_to = "Muscle") %>% 
  filter(!(Muscle == "")) %>% 
  mutate(ename = str_replace_all(ename, "\\.", " "))

# Skok:
df <- read.csv("dane_skok.csv")
mean_weight <- mean(df$weight, na.rm = TRUE)
df$date <- as.Date(df$date)
df <- df %>%
  mutate(Ławka = bench_weight * (36/(37 - bench_reps)),
         Przysiad = squat_weight * (36/(37 - squat_reps)),
         OHP = ohp_weight * (36/(37 - ohp_reps))
  ) %>%
  pivot_longer(
    cols = c(Ławka, Przysiad, OHP),
    names_to = "exercise",
    values_to = "one_rep_max"
  )
data_skok <- df
data_skok$date <- as.Date(data_skok$date)

# Krajewska:
steps_raw <- read_csv("pedometer_day_summary.csv", skip = 1)

steps <- steps_raw %>% 
  mutate(day = as_date(as.POSIXct(day_time / 1000, origin = "1970-01-01", tz = "Europe/Warsaw"))) %>% 
  group_by(day) %>% 
  slice_max(order_by = step_count, n = 1, with_ties = FALSE) %>% 
  ungroup() %>% 
  select(day, step_count)

ui <- fluidPage(
  
  fluidRow(
    column(
      width = 3,
      radioButtons("person", "Person: ", c("Michal", "Marek", "Natalia")),
      uiOutput("sideText")
    ),
    column(
      width = 9,
      uiOutput("mainPanel")
    )
  )
)

server <- function(input, output) {
  
  show_anatomy <- reactiveVal(TRUE) 
  observeEvent(input$toggle_view, {
    show_anatomy(!show_anatomy())
  })
  
  output$mainPanel <- renderUI({
    if (input$person == "Michal") {
      data <- trainingData()
      req(data)
      typeofplot <- input$typeofplot
      if (is.null(typeofplot)) {
        typeofplot <- "Number of Exercises"
      }
      tagList(
        fluidRow(
          column(12,
                 actionButton("toggle_view", 
                              label = if(show_anatomy()) "Go to Statistics" else "Back to Anatomy", 
                              icon = icon("exchange-alt"),
                              class = "btn-primary", 
                              style = "margin-bottom: 15px; width: 100%;")
          )
        ),
        
        if (show_anatomy()) {
          fluidRow(
            column(12,
                   plotlyOutput("anatomyPlot", height = "85vh") 
            )
          )
        } else {
          tagList(
            div(
              class = "well",
              fluidRow(
                column(
                  width = 6,
                  selectInput("muscle", "Select muscle: ", c("Total", sort(unique(data$z$Muscle[!is.na(data$z$Muscle)]))))
                ),
                column(
                  width = 6,
                  selectInput("typeofplot", "Select plot type:",
                              c("Number of exercises", "Volume"),
                              selected = typeofplot)
                )
              )
            ),
            fluidRow(
              column(
                width = 12,
                if (typeofplot == "Volume") {
                  plotOutput("volumePlot", height = "60vh")
                } else {
                  plotOutput("favExercise", height = "60vh")
                }
              )
            )
          )
        }
      )
    }
    #W if dodajcie swoje GUI
    else if (input$person == "Marek") {
      tagList(
        div(
          class = "well",
          fluidRow(
            column(
              width = 3,
              selectInput(
                "marek_plot_type",
                "Plot type",
                choices = c("Point plot", "Box plot"),
                selected = "Point plot"
              )
            ),
            column(
              width = 6,
              checkboxGroupInput(
                "cwiczenia",
                "Exercises",
                choices = c("Bench press" = "Ławka",
                            "Squat" = "Przysiad",
                            "OHP" = "OHP"),
                selected = c("Ławka", "Przysiad", "OHP"),
                inline = TRUE
              )
            ),
            column(
              width = 3,
              uiOutput("marek_osx_ui")
            )
          )
        ),
        plotlyOutput("distPlot", height = "65vh")
      )
    }
    else if(input$person == "Natalia"){
      tagList(
        div(
          class = "well",
          fluidRow(
            column(
              width = 4,
              selectInput("plot", "Choose plot:", 
                          c("Steps trend", "Weekly average", "Goals calendar"))
            ),
            column(
              width = 8,
              uiOutput("dynamicInputs")
            )
          )
        ),
        plotlyOutput("nataliaPlot", height = "65vh")
      )
    }
  })

  
 trainingData <- reactive({
    req(input$person)
    if(input$person == "Michal"){
      
      
      max_sets <- max(str_count(sessions$logs,","))+1
      col_names <- paste0("Set",1:max_sets)
      
      y <- sessions%>% 
        separate(logs,into=col_names, sep=",",fill="right")
      y <- y %>% 
        pivot_longer(cols= starts_with("Set"),names_to="Set_name",values_to = "Set_info") %>% 
        separate(Set_info,into=c("Weight","Reps"),sep="x",convert = TRUE) %>% 
        mutate(volume= Weight*Reps)
      

      
      z <- y %>% 
        left_join(muscles,by="ename")
      
      
      
      
      dat <- bdgramr(data = data, model = "original_male") %>% 
        filter(!(Muscle=="Soleus") & !(Muscle=="Neck") & !(Muscle == "Head"))
      
      dat <- z %>% 
        select(ename,volume,Muscle) %>% 
        group_by(Muscle) %>% 
        filter(!(is.na(volume))) %>% 
        summarise(Total_volume=sum(volume)/1000) %>% 
        full_join(dat,by="Muscle") %>%
        filter(!(is.na(Total_volume))) %>% 
        mutate(label_text = paste0("Muscle: ", str_replace_all(Muscle,"_"," "), "\nVolume: ", round(Total_volume, 0)," t")) %>% 
        arrange(Id)
      return(list(z=z,dat=dat))
      
    }
    if(input$person == "Marek"){}
    if(input$person == "Natalia"){}
 })
  
  
  #outputy do wykresów
  # Michal
  output$favExercise <-renderPlot({
    data <-trainingData()
    req(input$muscle,data)
    if(input$muscle != "Total"){p<- data$z %>% filter(Muscle == input$muscle)}
    else{p<- data$z}
    p <-p %>% 
      group_by(mydate,ename) %>% 
      summarise(n=n()) %>% 
      group_by(ename) %>% 
      summarise(n=n())
    p <- p %>% 
      top_n(15) %>% 
      ggplot(aes(x=fct_reorder(ename,n),y=n))+
      geom_col()+
      theme(
        axis.text.x = element_text(
          angle=45,
          size=8,
          hjust = 1
        )
      )+
      labs(title = paste0("Most frequent exercises for ",input$muscle),y="Count",x="Exercise Name")+
      geom_text(aes(label=n,vjust=-0.5))
    print(p)
  })
  output$anatomyPlot <- renderPlotly({
    data <-trainingData()
    req(data)
    p <- data$dat %>%
      plot_ly(
        x = ~x,
        y = ~y,
        split= ~Id,
        color = ~Total_volume,
        type = 'scatter',
        mode = 'lines',
        fill = 'toself',
        text= ~label_text,  
        opacity = 0.5,
        hoverinfo="text",
        hoveron = "fills"
      ) %>%
      layout(
        xaxis = list(title = "", zeroline = FALSE, showticklabels = FALSE),
        yaxis = list(title = "", zeroline = FALSE, showticklabels = FALSE,autorange = "reversed"),
        showlegend = FALSE,
        title="Muscle anatomy plot"
      )
    print(p)
  })
  output$volumePlot <- renderPlot({
    data <-trainingData()
    req(input$muscle,data)
    if(input$muscle != "Total"){p<- data$z %>% filter(Muscle == input$muscle)}
    else{p<- data$z}
    p <- p %>% 
      select(-Muscle) %>% 
      distinct()%>% 
      group_by(ename) %>% 
      drop_na(volume) %>% 
      summarise(TotalVolume=sum(volume)) %>% 
      top_n(15) %>% 
      ggplot(aes(x=fct_reorder(ename,TotalVolume),y=TotalVolume/1000))+
      geom_col()+
      theme(
        axis.text.x = element_text(
          angle=45,
          size=8,
          hjust = 1
        )
      )+
      scale_y_continuous(labels = function(x) format(x, scientific = FALSE))+
      labs(title = paste0("Highest volume exercises for ", input$muscle),y="Volume [t]",x="Exercise Name")
    print(p)
  })
  
  #Marek
  output$distPlot <- renderPlotly({
    req(input$cwiczenia)
    req(input$marek_plot_type)
    
    data_skok_filtered <- data_skok %>%
      filter(exercise %in% input$cwiczenia) %>%
      filter(!is.na(one_rep_max)) %>%
      mutate(one_rep_max = round(one_rep_max, 1)) %>%
      mutate(exercise = recode(exercise,
                               "Ławka" = "Bench press",
                               "Przysiad" = "Squat",
                               "OHP" = "OHP"))
    
    # Boxplot
    if (input$marek_plot_type == "Box plot") {
      
      p <- ggplot(
        data_skok_filtered,
        aes(
          x = exercise,
          y = one_rep_max,
          fill = exercise,
          color = exercise,
          text = paste0("1RM: ", one_rep_max)
        )
      ) +
        geom_boxplot(alpha = 0.4, outlier.shape = NA) +
        labs(
          x = "Exercise",
          y = "One Rep Max (kg)",
          title = "1RM distribution — box plot",
          fill = "Exercise",
          color = "Exercise"
        ) +
        theme_minimal() +
        theme(legend.position = "none")
      
      return(
        ggplotly(p, tooltip = "text") %>%
          layout(
            legend = list(
              itemclick = FALSE,
              itemdoubleclick = FALSE
            )
          )
      )
    }
    
    # Pointplot
    req(input$osx)
    
    x_var <- if (input$osx == "Date") "date" else "weight"
    
    p <- ggplot(
      data_skok_filtered,
      aes(
        x = .data[[x_var]],
        y = one_rep_max,
        color = exercise,
        text = paste0(one_rep_max),
        group = exercise
      )
    )
    
    if (input$osx == "Bodyweight") {
      p <- p +
        geom_vline(
          xintercept = mean_weight,
          color = "pink",
          linetype = "dashed",
          size = 0.8
        ) +
        annotate(
          "text",
          x = mean_weight,
          y = max(data_skok_filtered$one_rep_max, na.rm = TRUE) + 5,
          label = paste0("Mean bodyweight: ", round(mean_weight, 1), "kg"),
          color = "black",
          size = 3,
          fontface = "bold",
          angle = 90,
          vjust = -0.5
        )
    }
    
    if (input$osx == "Date") {
      
      maj_start <- as.Date("2024-05-01")
      maj_end   <- as.Date("2024-05-24")
      maj_center <- maj_start + (maj_end - maj_start)/2
      maj_width  <- as.numeric(maj_end - maj_start) + 1
      
      jan_start <- as.Date("2025-01-05")
      jan_end   <- as.Date("2025-02-10")
      jan_center <- jan_start + (jan_end - jan_start)/2
      jan_width  <- as.numeric(jan_end - jan_start) + 1
      
      june_start <- as.Date("2025-05-25")
      june_end   <- as.Date("2025-06-15")
      june_center <- june_start + (june_end - june_start)/2
      june_width  <- as.numeric(june_end - june_start) + 1
      
      p <- p +
        geom_tile(
          data = data.frame(
            x = c(maj_center, jan_center, june_center),
            y = rep(mean(range(data_skok_filtered$one_rep_max)), 3),
            width = c(maj_width, jan_width, june_width),
            height = rep(diff(range(data_skok_filtered$one_rep_max)) + 15, 3),
            label = c("Matura 2024", "I academic\ncomeback", "II academic\ncomeback")
          ),
          aes(x = x, y = y, width = width, height = height),
          fill = "pink",
          alpha = 0.3,
          inherit.aes = FALSE,
          show.legend = FALSE
        ) +
        annotate(
          "text",
          x = c(maj_center, jan_center, june_center),
          y = max(data_skok_filtered$one_rep_max, na.rm = TRUE) + 5,
          label = c("2024 matura exam", "I academic\ncomeback", "II academic\ncomeback"),
          color = "black",
          size = 3,
          fontface = "bold"
        ) +
        scale_x_date(date_breaks = "1 month", date_labels = "%Y-%m")
    }
    
    p <- p +
      geom_point() +
      labs(
        x = ifelse(input$osx == "Date", "Date", "Bodyweight (kg)"),
        y = "One Rep Max (kg)",
        color = "Exercise",
        title = "One Rep Max — point plot"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text") %>%
      layout(
        legend = list(
          itemclick = FALSE,
          itemdoubleclick = FALSE
        )
      )
  })
  
  output$marek_osx_ui <- renderUI({
    req(input$marek_plot_type)
    
    if (input$marek_plot_type == "Point plot") {
      selectInput("osx", "X axis", c("Date", "Bodyweight"), selected = "Date")
    } else {
      NULL
    }
  })
  
  #Natalia
  output$dynamicInputs <- renderUI({
    req(input$plot)
    
    if(input$plot %in% c("Steps trend", "Weekly average")) {
      dateRangeInput("range", "Date range:",
                     start = min(steps$day, na.rm = TRUE),
                     end = max(steps$day, na.rm = TRUE))
      
    } else if(input$plot == "Goals calendar") {
      month_year_choices <- steps %>%
        mutate(month_year = format(day, "%b %Y")) %>%
        distinct(month_year) %>%
        arrange(as.Date(paste0("01 ", month_year), format="%d %b %Y")) %>%
        pull(month_year)
      
      tagList(
        selectInput("month_year", "Choose month:", 
                    choices = month_year_choices,
                    selected = month_year_choices[1]),
        numericInput("goal", "Steps goal:", value = 6000, min = 1000, max = 20000, step = 500)
      )
    }
  })
  
  output$nataliaPlot <- renderPlotly({
    req(input$plot)
    
    if(input$plot %in% c("Steps trend", "Weekly average")){
      req(input$range)
      steps_filtered <- steps %>%
        filter(day >= input$range[1] & day <= input$range[2])
    } else if(input$plot == "Goals calendar") {
      req(input$month_year, input$goal)
      steps_filtered <- steps %>%
        mutate(month_year = format(day, "%b %Y")) %>%
        filter(month_year == input$month_year) %>%
        mutate(
          achieved = step_count >= input$goal,
          weekday = wday(day, label = TRUE, week_start = 1, locale = "C"),
          month_day = day(day),
          week_in_month = as.numeric(format(day, "%W")) - as.numeric(format(floor_date(day, "month"), "%W")) + 1,
          tooltip_text = paste0("Day: ", day(day), "\nSteps: ", step_count)
        )
    }
    
    if (input$plot == "Steps trend") {
      steps_filtered <- steps_filtered %>%
        mutate(tooltip_text = paste0("Date: ", day, "\nSteps: ", step_count))
      
      p <- ggplot(steps_filtered, aes(x = day, y = step_count)) +
        geom_col(aes(text = tooltip_text), fill = "#4682B4") +
        geom_smooth(aes(group = 1), method = "loess", se = FALSE, color = "darkred", size = 0.8) +
        labs(title = "Daily steps trend", x = "Date", y = "Step count") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else if (input$plot == "Weekly average") {
      steps_week <- steps_filtered %>%
        group_by(week = floor_date(day, "week")) %>%
        summarise(avg_steps = mean(step_count, na.rm = TRUE)) %>% 
        mutate(week_end = week + days(6),
          tooltip_text = paste0("Week: ", week," - ",week_end, "\nStep average: ", round(avg_steps)))
      
      p <- ggplot(steps_week, aes(x = week, y = avg_steps)) +
        geom_line(aes(group = 1), color = "#1E90FF", linewidth = 1) +
        geom_point(aes(text = tooltip_text), color = "#1E90FF") +
        labs(title = "Average weekly step count", x = "Week", y = "Average step count") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else if (input$plot == "Goals calendar") {
      total_success <- sum(as.logical(steps_filtered$achieved), na.rm = TRUE)
      total_days <- nrow(steps_filtered)
      
      steps_filtered$achieved_factor <- factor(
        steps_filtered$achieved,
        levels = c(TRUE, FALSE),
        labels = c("Goal reached", "Goal not reached")
      )
      
      dni_tygodnia <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
      
      p <- ggplot(steps_filtered, aes(x = weekday, y = -week_in_month, fill = achieved_factor)) +
        geom_tile(aes(text = tooltip_text), color = "white", size = 0.5) +
        geom_text(aes(label = day(day)), size = 3, color = "black") +
        scale_fill_manual(values = c("Goal reached" = "#90EE90", "Goal not reached" = "#f2f2f2"),
                          name = NULL) +
        scale_x_discrete(labels = dni_tygodnia) +
        labs(
          title = paste0("Calendar ", input$month_year, "\nDays with goal reached: ", total_success, "/", total_days),
          x = NULL, y = NULL
        ) +
        theme_minimal(base_size = 12) +
        theme(
          panel.grid = element_blank(),
          axis.text.y = element_blank(),
          axis.text.x = element_text(face = "bold"),
          legend.position = "bottom"
        )
    }
    
    ggplotly(p, tooltip = "text")
  })
  
  output$sideText <- renderUI({
    req(input$person)
    
    txt <- switch(
      input$person,
      "Michal" =
        "This panel analyzes my training history with a focus on muscle engagement and volume.
You can toggle between two main views using the button at the top:

Anatomy View- An interactive visual body map showing which muscle groups are targeted most frequently, based on total volume.

Statistics View– Detailed charts analyzing my workout data.
In this view, you can filter by specific muscle groups (or view Total) and choose between two metrics:
- Number of Exercises: How often I perform specific movements.
- Volume: The total tonnage lifted (sets × reps × weight) for the selected muscle group.",
      
      "Marek" =
"This panel shows my strength progress for three lifts (Bench press, Squat, OHP) using an estimated One Rep Max (1RM), because I obviously don’t test a true max on every workout.

How 1RM is calculated:
Each workout in the CSV stores a working weight and number of reps (80 kg × 5).
From that I compute an estimated 1RM using the formula:
1RM = weight * (36 / (37 − reps))

Available plots:
Point plot — shows estimated 1RM as individual training entries, with the X-axis set either to Date, showing progress over time, or Bodyweight, showing relations between strength and bodyweight.
Box plot — shows the distribution of estimated 1RM values for each selected exercise.
",
      
      "Natalia" =
        "This panel visualizes my daily step data collected from activity tracker (mobile phone application).
You can explore my progress through three interactive views:

Daily step count – shows total steps per day within a selected date range.

Weekly average – displays the average number of steps taken each week.

Goals calendar – presents a monthly calendar highlighting which days set daily step goal was reached or missed.

Use the menu above to choose a chart type, adjust the date range or month, and set step goal. Each chart is interactive – hover over elements to see detailed step information."
    )
    
    tags$pre(
      style = "
      font-size: 12px;
      white-space: pre-wrap;
      overflow-wrap: normal;
      word-break: normal;
      margin-top: 35px;
      background-color: transparent;
      border: none;
      color: #000000;
    ",
      txt
    )
  })
}  
  
    


# Run the application 
shinyApp(ui = ui, server = server)
