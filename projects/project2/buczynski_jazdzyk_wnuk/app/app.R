library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(zoo)
library(cowplot)
library(plotly)
library(networkD3)
library(htmlwidgets)

Sys.setlocale("LC_TIME", "pl_PL.UTF-8") 

weekday.names <- weekdays(seq(as.Date("2026-01-05"), as.Date("2026-01-11"), by = "1 day"), abbr = TRUE)

df_jj <- readRDS("../data_final/jj/df.rds")
df_jj<-df_jj %>% 
  filter(date >= as.Date("2024-06-01"),
         date<= as.Date("2025-11-30"))
df_jj$category <- recode(
  df_jj$category,
  "Wpływy - inne" = "Wpływy",
  "Zwrot pieniędzy" = "Zwrot pieniędzy",
  "Jedzenie poza domem" = "Gotowe jedzenie",
  "Kawa" = "Kawa",
  "Żywność i chemia domowa" = "Jedzenie i środki czystości",
  "Przejazdy" = "Komunikacja miejska",
  "Sport i hobby " = "Sport i hobby",
  "Elektronika" = "Elektronika",
  "Odzież i obuwie" = "Odzież i obuwie",
  "Zdrowie i uroda" = "Zdrowie i uroda",
  "Multimedia, książki i prasa" = "Multimedia, książki i prasa",
  "Wyjścia i wydarzenia" = "Wyjścia i wydarzenia",
  "Wypłata gotówki" = "Gotówka"
)

df_jw <- read.csv("../data_final/jw/df_jw.csv")
df_jw$currency_date <- as.Date(df_jw$currency_date,"%d.%m.%Y")
df_jw$amount <- df_jw$amount*100
colnames(df_jw) = c("posting_date","date","amount","category")
df_jw$category <- recode(
  df_jw$category,
  "Jedzenie" = "Jedzenie i środki czystości",
  "Prezenty"= "Prezenty",
  "Biezace" = "Inne",
  "Gotowe jedzenie" = "Gotowe jedzenie",
  "Zdrowie" = "Zdrowie",
  "Transport publiczny" = "Komunikacja miejska",
  "Przychody" = "Wpływy",
  "Podroze" = "Podróże",
  "Sport" = "Sport i hobby",
  "Ubrania" = "Odzież i obuwie",
  "Kosmetyki" = "Kosmetyki",
  "Kino i teatr" = "Kino i teatr"
)

df_pkb <- read.csv("../data_final/pkb/df.csv") %>%
  tibble() %>%
  mutate(date = as.Date(date),
         datePosted = as.Date(datePosted))
df_pkb$category <- recode(
  df_pkb$category,
  "Wypłata gotówki" = "Gotówka"
)

df <- df_jj
categories <- unique(df_jj$category)

categoryPerson <- rbind(
  tibble(category = unique(df_jj$category), person = "jj"),
  tibble(category = unique(df_jw$category), person = "jw"),
  tibble(category = unique(df_pkb$category), person = "pkb")
)

datesUnion <- range(df_jj$date, df_jw$date, df_pkb$date)
datesIntersect <- c(max(min(df_jj$date), min(df_jw$date), min(df_pkb$date)),
                    min(max(df_jj$date), max(df_jw$date), max(df_pkb$date)))


moneyLabels <- function(x) format(x, big.mark = " ", scientific = FALSE)



all_categories <- unique(c(df_jj$category, df_jw$category, df_pkb$category))
all_categories <- sort(all_categories) 
all_categories <- c(all_categories, "Suma")

mega_palette <- c(
 "#F0E442",
 "#55A868",
 "#ffa600",
 "#AB63FA",
 "#a05195",
 "#FFBB78",
 "#00CC96",
 "#31A354",
 "#f95d6a",
 "#ff7c43",
 "#9EDAE5",
 "#E377C2",
 "#4C72B0",
 "#8FB0FF",
 "#d45087",
 "#DE9ED6",
 "#C5B0D5",
 "#17BECF",
 "#665191",
 "#EF553B",
 "#98DF8A",
 "#FF9896",
 "#FF9F4A",
 "#F7B6D2",
 "#FECB52",
 "#636EFA"
  )


category_colors <- setNames(mega_palette[1:length(all_categories)], all_categories)
category_colors["Suma"] <- "#525252"


ui <- navbarPage(
  title = "Analiza wpływów i wydatków",
  tabPanel(
    "Kalendarz wydatków",
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "select_person",
          "Wybierz osobę:",
          list("Jaga J" = "jj","Jagna W" = "jw","Paweł B" = "pkb")
        ),
        hr(),
        dateRangeInput(
          "dateRange",
          "Przedział czasowy",
          start = min(df$date),
          end = max(df$date),
          min = min(df$date),
          max = max(df$date),
          format = "dd.mm.yyyy",
          startview = "year",
          weekstart = 1,
          language = "pl",
          separator = "do"
        ),
        checkboxGroupInput(
          "categories",
          "Kategorie",
          choices = NULL
        ),
        actionButton("selectAll", "Zaznacz wszystko", style = "font-size: 0.9em; padding: 0.2em 0.6em;"),
        actionButton("deselect", "Odznacz",  style = "font-size: 0.9em; padding: 0.2em 0.6em;"),
        actionButton("invert", "Odwróć",  style = "font-size: 0.9em; padding: 0.2em 0.6em;"),
        width = 3
      ),
      mainPanel(
        br(),
        h4("Szczegółowa analiza w czasie"),
        plotOutput("githubPlot") 
      )
    )
  ),
  #Sankey Plot
  tabPanel(
    "Przepływ środków", 
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "select_person_sankey",
          "Wybierz osobę:",
          list("Jaga J" = "jj","Jagna W" = "jw","Paweł B" = "pkb")
        ),
        hr(),
        h5("Suma dla kategorii: "),
        tableOutput("statsTable"),
        width = 3
      ),
      mainPanel (
        br(),
        h4("Wykres przepływu pieniędzy"),
        sankeyNetworkOutput("sankey")
      )
    )
  ),
  tabPanel(
    "Porównanie osób",
    sidebarLayout(
      sidebarPanel(
        dateRangeInput(
          "dateRangePersonCmp",
          "Przedział czasowy",
          start = min(datesIntersect),
          end = max(datesIntersect),
          min = min(datesUnion),
          max = max(datesUnion),
          format = "dd.mm.yyyy",
          startview = "year",
          weekstart = 1,
          language = "pl",
          separator = "do"
        ),
        checkboxGroupInput(
          "persons",
          "Osoby",
          choices = list("Jaga J" = "jj","Jagna W" = "jw","Paweł B" = "pkb"),
          selected = c("jj", "jw", "pkb")
        ),
        radioButtons(
          "transactionType",
          "Rodzaj transakcji",
          choices = list("Wszystkie" = "all", "Wpływy" = "in", "Wydatki" = "out"),
          selected = "all"
        ),
        hr(),
        checkboxInput(
          "hideSingularCategories",
          "Ukryj kategorie występujące tylko u jednej osoby",
          value = TRUE
        ),
        width = 3
      ),
      mainPanel(
        plotOutput("balancePlot"),
        plotOutput("categorySumPlot")
      )
    )
  ),
  tabPanel(
    "Porównanie okresów",
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "select_person_Cmp",
          "Wybierz osobę:",
          list("Jaga J" = "jj","Jagna W" = "jw","Paweł B" = "pkb")
        ),
        dateRangeInput(
          "dateRange_Cmp1",
          "Przedział czasowy 1",
          start = min(df$date),
          end = max(df$date),
          min = min(df$date),
          max = max(df$date),
          format = "dd.mm.yyyy",
          startview = "year",
          weekstart = 1,
          language = "pl",
          separator = "do"
        ),
        dateRangeInput(
          "dateRange_Cmp2",
          "Przedział czasowy 2",
          start = min(df$date),
          end = max(df$date),
          min = min(df$date),
          max = max(df$date),
          format = "dd.mm.yyyy",
          startview = "year",
          weekstart = 1,
          language = "pl",
          separator = "do"
        ),
        radioButtons(
          "transactionType_Cmp",
          "Rodzaj transakcji",
          choices = list("Wszystkie" = "all", "Wpływy" = "in", "Wydatki" = "out"),
          selected = "all"
        )
      ),
      mainPanel(
        plotOutput("categorySumPlot_Cmp")
      )
    )
  )
)




server <- function(input, output) {
  
  current_data <- reactive({
    if(input$select_person == "jw") return(df_jw)
    if(input$select_person == "jj") return(df_jj)
    if(input$select_person == "pkb") return(df_pkb)
  })
  
  observeEvent(input$select_person, {
    df <- current_data()
    categories <- unique(df$category)
    updateCheckboxGroupInput(inputId = "categories",
                             choices = categories,
                             selected = categories)
    
    updateDateRangeInput(inputId = "dateRange",
                         start = min(df$date),
                         end = max(df$date),
                         min = min(df$date),
                         max = max(df$date))
    
  })
  
  observeEvent(input$selectAll, {
    df <- current_data()
    updateCheckboxGroupInput(
      inputId = "categories",    
      selected = unique(df$category)        
    )
  })
  
  observeEvent(input$deselect, {
    df <- current_data()
    updateCheckboxGroupInput(
      inputId = "categories",    
      selected = unique(df$category)[1]    
    )
  })
  
  observeEvent(input$invert, {
    df <- current_data()
    selected <- setdiff(unique(df$category), input$categories)
    print(selected)
    if (length(selected) == 0) selected = unique(df$category)[1] 
    updateCheckboxGroupInput(
      inputId = "categories",
      selected = selected
    )
  })
  
  
  output$githubPlot <- renderPlot({
    df <- current_data()
    
    allDays <- tibble(date = seq(min(df$date), max(df$date), by = "1 day"),
                      category = NA,
                      total = 0)
    
    data <- df %>%
      mutate(type = amount > 0) %>%
      group_by(date, category, type) %>%
      summarise(total = sum(amount)/100) %>%
      ungroup() %>%
      select(!type) %>%
      # TODO: think it through once again where's the best time to do this
      rbind(allDays) %>%
      complete(date, category, fill = list(total = 0)) %>%
      filter(category %in% input$categories,
             date >= input$dateRange[1] & date <= input$dateRange[2])
    
    validate(
      need(nrow(data) > 0, "Czekaj..")
    )
    
    data <- data  %>%
      mutate(month_idx = match(months(date), month.name),
             week = as.Date(cut.Date(date, breaks = "1 week")),
             weekday = factor(weekdays(date, abbr = TRUE), levels = weekday.names))
    
    
    plotMain <- function(data) data %>%
      ggplot(aes(x = week, y = weekday, fill = total)) +
      # geom_tile(data = . %>% filter(month_idx %% 2 == 1), fill = "gray") +
      geom_tile(width = 0.8*7, height = 0.8, color = "#888", linewidth = 0.2) +
      scale_fill_steps2(low = "red",
                        mid = "white",
                        high = "blue",
                        midpoint = 0,
                        trans = "pseudo_log",
                        breaks = c(-10^(3:0), 10^(0:3)),
                        labels = c(-10^(3:0), 10^(0:3)),
                        # limits are necessary, because otherwise there's an obscure cut() error
                        # when calculating color scale for all-zero data,
                        # when no selected categories have income/expense
                        limits = c(-10000, 10000)) +
      scale_x_date(expand = expansion(add = c(0.6, 0.6)),
                   date_breaks = "1 month",
                   date_labels = "%b %y",
      ) +
      scale_y_discrete(expand = expansion(add = c(0.6, 0.6))) +
      labs(x = "Tydzień",
           y = "Dzień tygodnia",
           fill = "Dzienna suma\nwpływów/wydatków") +
      # TODO: somehow make coord_fixed() play nicely with axes = "collect"
      # coord_fixed(ratio = 7) +
      theme(panel.background = element_blank(),
            axis.ticks.y = element_blank(),
            axis.text.x = element_text(angle = -45, hjust = 0, vjust = 0))
    
    noAxisX <- theme(axis.text.x = element_blank(),
                     axis.ticks.x = element_blank(),
                     axis.title.x = element_blank())
    noAxisY <- theme(axis.text.y = element_blank(),
                     axis.ticks.y = element_blank(),
                     axis.title.y = element_blank())
    commonTheme <- theme(legend.position = "none",
                         plot.margin = unit(rep(0.3, 4), "mm"))
    
    pMainIncome <- data %>%
      # mutate, because filtering leaves empty days where total was negative
      # TODO: maybe complete() it in a different way?
      mutate(total = pmax(total, 0)) %>%
      group_by(week, weekday) %>%
      summarise(total = sum(total)) %>%
      ungroup() %>%
      plotMain()
    
    pMainExpense <- data %>%
      mutate(total = pmin(total, 0)) %>%
      group_by(week, weekday) %>%
      summarise(total = sum(total)) %>%
      ungroup() %>%
      plotMain()
    
    plotWeeks <- function(data) data %>%
      ggplot(aes(x = week, y = total, fill = category)) +
      geom_col() +
      scale_fill_manual(values = category_colors) +
      scale_x_date(expand = expansion(add = c(0.6, 0.6)),
                   date_breaks = "1 month",
                   date_labels = "%b %y",
      ) +
      scale_y_continuous(labels = moneyLabels) +
      labs(x = "Tydzień",
           fill = "Kategoria") +
      theme_minimal() +
      theme(axis.ticks.y = element_blank(),
            axis.text.x = element_text(angle = -45, hjust = 0, vjust = 0))
    
    pTopIncome <- data %>%
      filter(total >= 0) %>%
      group_by(week, category) %>%
      summarise(total = sum(total)) %>%
      ungroup() %>%
      plotWeeks() +
      labs(y = "Suma wpływów")
    
    pBottomExpense <- data %>%
      filter(total <= 0) %>%
      group_by(week, category) %>%
      summarise(total = -sum(total)) %>%
      ungroup() %>%
      plotWeeks() +
      labs(y = "Suma wydatków") +
      # TODO: abs() + reverse axis here, or no abs() + reverse axis in rightExpense?
      scale_y_reverse(labels = moneyLabels)
    
    plotWeekdays <- function(data) data %>%
      ggplot(aes(x = total, y = weekday, fill = category)) +
      geom_col() +
      scale_fill_manual(values = category_colors) +
      scale_y_discrete(expand = expansion(add = c(0.6, 0.6))) +
      scale_x_continuous(labels = moneyLabels) +
      labs(y = "Dzień tygodnia",
           fill = "Kategoria") +
      theme_minimal() +
      theme(axis.ticks.y = element_blank(),
            axis.text.x = element_text(angle = 0, hjust = 0))
    
    pRightIncome <- data %>%
      filter(total >= 0) %>%
      group_by(weekday, category) %>%
      summarise(total = sum(total)) %>%
      ungroup() %>%
      plotWeekdays() +
      scale_x_continuous(position = "top", labels = moneyLabels) +
      labs(x = "Suma wpływów") +
      theme(axis.text.x = element_text(angle = 45))
    
    pTopSpacer <- data %>%
      filter(total >= 0) %>%
      group_by(weekday) %>%
      summarise(total = sum(total)) %>%
      summarise(total = max(total)) %>%
      rbind(tibble(total = 0)) %>%
      ggplot(aes(x = total)) +
      geom_blank() +
      scale_x_continuous(position = "top", labels = moneyLabels) +
      labs(x = "Suma wpływów") +
      theme(panel.background = element_blank(),
            axis.text.x = element_text(angle = 45, hjust = 0)) +
      noAxisY
    
    pRightExpense <- data %>%
      filter(total <= 0) %>%
      group_by(weekday, category) %>%
      summarise(total = -sum(total)) %>%
      ungroup() %>%
      plotWeekdays() +
      labs(x = "Suma wydatków") +
      theme(axis.text.x = element_text(angle = -45))
    
    pBottomSpacer <- data %>%
      filter(total <= 0) %>%
      group_by(weekday) %>%
      summarise(total = -sum(total)) %>%
      summarise(total = max(total)) %>%
      rbind(tibble(total = 0)) %>%
      ggplot(aes(x = total)) +
      geom_blank() +
      scale_x_continuous(position = "bottom", labels = moneyLabels) +
      labs(x = "Suma wydatków") +
      theme(panel.background = element_blank(),
            axis.text.x = element_text(angle = -45, hjust = 0)) +
      noAxisY
    
    legendMain <- get_legend(pMainIncome)
    legendCol <- get_legend(pTopIncome)
    pTopIncome <- pTopIncome + commonTheme + noAxisX
    pMainIncome <- pMainIncome + commonTheme + noAxisX
    pMainExpense <- pMainExpense + commonTheme + noAxisX
    pBottomExpense<- pBottomExpense + commonTheme
    pRightIncome <- pRightIncome + commonTheme + noAxisX + noAxisY
    pRightExpense <- pRightExpense + commonTheme + noAxisX + noAxisY
    
    plot_grid(
      plot_grid(
        plot_grid(pTopIncome, plot_grid(NULL, pTopSpacer, ncol = 1), ncol = 2, rel_widths = c(4, 1)),
        plot_grid(pMainIncome, pRightIncome, ncol = 2, rel_widths = c(4, 1)),
        plot_grid(pMainExpense, pRightExpense, ncol = 2, rel_widths = c(4, 1)),
        plot_grid(pBottomExpense, plot_grid(pBottomSpacer, NULL, ncol = 1, rel_heights = c(0.5, 0.9)), ncol = 2, rel_widths = c(4, 1)),
        ncol = 1,
        rel_heights = c(1, 1, 1, 1.4),
        align = "hv"
      ),
      NULL,
      plot_grid(
        NULL,
        legendMain,
        legendCol,
        NULL,
        ncol = 1,
        rel_heights = c(0.1, 1, 3, 0.1),
        align = "v"
      ),
      ncol = 3,
      rel_widths = c(4, 0.2, 1)
    )
  })
  
  
  current_data_sankey <- reactive({
    if(input$select_person_sankey == "jw") return(df_jw)
    if(input$select_person_sankey == "jj") return(df_jj)
    if(input$select_person_sankey == "pkb") return(df_pkb)
  })
  
  output$statsTable <- renderTable({
    df <- df <- current_data_sankey()
    table <-
    df %>% group_by(category) %>% summarise(Total = sum(amount/100)) %>% arrange(Total)
    colnames(table) <- c("Kategoria","Suma")
    table
  })
  
  output$sankey <- renderSankeyNetwork({
    df <- current_data_sankey()
    
    links <- df %>%
      filter(amount > 0) %>%
      group_by(category) %>%
      summarise(total = sum(amount)/100) %>%
      mutate(target = "") %>%
      rename(source = category, value = total) %>%
      mutate(group = source)
    
    links <- df %>%
      filter(amount < 0) %>%
      group_by(category) %>%
      summarise(total = -sum(amount)/100) %>%
      mutate(source = "") %>%
      rename(target = category, value = total) %>%
      mutate(group = target) %>%
      rbind(links)
    
    nodes <- data.frame(
      name=c(as.character(links$source),
             as.character(links$target)) %>% unique()
    )
    
    links$IDsource <- match(links$source, nodes$name)-1
    links$IDtarget <- match(links$target, nodes$name)-1
    
    sn <-
      sankeyNetwork(Links = links,
                    Nodes = nodes,
                    Source = "IDsource",
                    Target = "IDtarget",
                    Value = "value",
                    NodeID = "name",
                    LinkGroup = "group",
                    sinksRight=FALSE,
                    fontSize = 10,
                    nodeWidth = 30,
                    nodePadding = 15,
                    margin = list(top = 20, right = 20, bottom = 100, left = 20))
    
    onRender(sn, '
      function(el, x) {
        d3.select(el).selectAll("title").remove();
        
        d3.select(el).selectAll(".node text")
          .style("font-weight", "bold")
         
        if (document.getElementById("custom-tooltip-style") === null) {
          var style = document.createElement("style");
          style.id = "custom-tooltip-style";
          style.innerHTML = `
            .sankey-tooltip {
              position: absolute;
              text-align: left;
              padding: 0.25em 0.5em;
              font-family: "Segoe UI", Arial, sans-serif;
              font-size: 1em;
              background: white;
              color: #333;
              border-radius: 0.5em;
              pointer-events: none;
              box-shadow: 0px 4px 12px rgba(0,0,0,0.3);
              border: 1px solid #ddd;
              z-index: 9999;
              max-width: 300px;
            }
            .tooltip-header { font-weight: bold; margin-bottom: 5px; font-size: 15px; }
            .tooltip-value { color: #2c3e50; font-weight: 600; font-size: 16px; }
          `;
          document.head.appendChild(style);
        }

        var tooltip = d3.select("body").append("div")
          .attr("class", "sankey-tooltip")
          .style("opacity", 0);

        var formatMoney = function(d) {
          return d3.format(",.0f")(d).replace(/,/g, " ") + " zł";
        };

        d3.selectAll(".link")
          .on("mouseover", function(d) {
            tooltip.transition().duration(200).style("opacity", 1);
            const category = d.source.name === "" ? d.target.name : d.source.name;
            tooltip.html(
              `<div class="tooltip-value">${category}: ${formatMoney(d.value)}</div>`
            );
          })
          .on("mousemove", function() {
            tooltip
              .style("left", (d3.event.pageX + 15) + "px")
              .style("top", (d3.event.pageY - 28) + "px");
          })
          .on("mouseout", function() {
            tooltip.transition().duration(500).style("opacity", 0);
          });
      }
    ')
  })
  
  output$balancePlot <- renderPlot({
    df1 <- df_jj %>%
      select(category, amount, date) %>%
      mutate(person = "jj")
    df2 <- df_jw %>%
      select(category, amount, date) %>%
      mutate(person = "jw")
    df3 <- df_pkb %>%
      select(category, amount, date) %>%
      mutate(person = "pkb")
    
    data <- rbind(df1, df2, df3) %>%
      filter(person %in% input$persons)
    
    if (input$transactionType == "in") {
      data <- data %>% filter(amount > 0)
    } else if (input$transactionType == "out") {
      data <- data %>% filter(amount < 0)
    }
    
    data <- data %>%
      arrange(date) %>%
      group_by(person) %>%
      mutate(balance = cumsum(amount)/100) %>%
      ungroup()
    
    labelText <- case_match(
      input$transactionType,
      "in" ~ "wpływy",
      "out" ~ "wydatki",
      .default = "wpływy i wydatki"
    )
    
    rect <- tibble(xmin = c(-Inf, input$dateRangePersonCmp[2]),
                   xmax = c(input$dateRangePersonCmp[1], Inf),
                   ymin = -Inf,
                   ymax = Inf)
    
    ggplot() +
      geom_rect(data = rect,
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = "gray50",
                alpha = 0.4) +
      geom_line(data = data, aes(x = date, y = balance, color = person))+
      labs(
        title = "Saldo w czasie",
        subtitle = paste("Skumulowane", labelText),
        x = "Data",
        y = "Saldo [zł]",
        color = "Osoba:"
      )+
      scale_color_manual(
        values = c(
          "jj" = "#1b9e77",
          "jw" = "#d95f02",
          "pkb" = "#7570b3"
        ),
        labels = c(
          "jj" = "Jaga J",
          "jw" = "Jagna W",
          "pkb" = "Paweł B"
        )
      )+
      scale_x_date(date_breaks = "1 month",
                   date_labels = "%b %y",
                   date_minor_breaks = "1 month") +
      scale_y_continuous(labels = moneyLabels) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = -45, hjust = 0, vjust = 0))
  })
  
  output$categorySumPlot <- renderPlot({
    df1 <- df_jj %>%
      select(category, amount, date) %>%
      mutate(person = "jj")
    df2 <- df_jw %>%
      select(category, amount, date) %>%
      mutate(person = "jw")
    df3 <- df_pkb %>%
      select(category, amount, date) %>%
      mutate(person = "pkb")
    
    data <- rbind(df1, df2, df3) %>%
      filter(person %in% input$persons,
             date >= input$dateRangePersonCmp[1] & date <= input$dateRangePersonCmp[2]) %>%
      mutate(positive = amount > 0) %>%
      group_by(category, person, positive) %>%
      summarise(total = sum(amount)/100) %>%
      ungroup()
    
    if (input$transactionType == "in") {
      data <- data %>% filter(positive)
    } else if (input$transactionType == "out") {
      data <- data %>% filter(!positive)
    }
    
    if (input$hideSingularCategories & length(input$persons) > 1) {
      categories <- categoryPerson %>%
        filter(person %in% input$persons) %>%
        group_by(category) %>%
        summarise(count = n()) %>%
        filter(count >= 2) %>%
        .$category
      data <- data %>% filter(category %in% categories)
    }
    
    labelText <- case_match(
      input$transactionType,
      "in" ~ "wpływów",
      "out" ~ "wydatków",
      .default = "wpływów i wydatków"
    )
    
    ggplot() +
      geom_col(data = data %>%
                 group_by(category, person) %>%
                 summarise(total = sum(total)) %>%
                 ungroup(),
               aes(y = category, x = total, fill = person),
               width = 0.8,
               position = position_dodge(width = 0.8)) +
      geom_linerange(data = data,
                     aes(y = category, xmin = 0, xmax = total, color = person),
                     position = position_dodge(width = 0.8)) +
      scale_fill_manual(
        values = c(
          "jj" = "#1b9e77",
          "jw" = "#d95f02",
          "pkb" = "#7570b3"
        ),
        labels = c(
          "jj" = "Jaga J",
          "jw" = "Jagna W",
          "pkb" = "Paweł B"
        )
      ) +
      scale_color_manual(
        values = c(
          "jj" = "#1b9e77",
          "jw" = "#d95f02",
          "pkb" = "#7570b3"
        ),
        labels = c(
          "jj" = "Jaga J",
          "jw" = "Jagna W",
          "pkb" = "Paweł B"
        )
      ) +
      scale_x_continuous(labels = moneyLabels) +
      labs(
        title = paste("Suma", labelText, "według kategorii"),
        subtitle = "Porównanie dla różnych osób",
        x = "Kwota [zł]",
        y = "Kategoria",
        color = "Osoba:",
        fill = "Osoba:"
      ) +
      theme_minimal()
    
    
  })
  
  current_dataCmp <- reactive({
    if(input$select_person_Cmp == "jw") return(df_jw)
    if(input$select_person_Cmp == "jj") return(df_jj)
    if(input$select_person_Cmp == "pkb") return(df_pkb)
  })
  
  observeEvent(input$select_person_Cmp, {
    df <- current_dataCmp()
    categories <- unique(df$category)
    updateDateRangeInput(inputId = "dateRange_Cmp1",
                         start = min(df$date),
                         end = max(df$date),
                         min = min(df$date),
                         max = max(df$date))
    updateDateRangeInput(inputId = "dateRange_Cmp2",
                         start = min(df$date),
                         end = max(df$date),
                         min = min(df$date),
                         max = max(df$date))
  })
  
  output$categorySumPlot_Cmp <- renderPlot({
    data <- current_dataCmp()
    
    df1 <- data %>%
      filter(date >= input$dateRange_Cmp1[1] & date <= input$dateRange_Cmp1[2]) %>%
      mutate(period = "1")
    
    df2 <- data %>%
      filter(date >= input$dateRange_Cmp2[1] & date <= input$dateRange_Cmp2[2]) %>%
      mutate(period = "2")
    
    data <- rbind(df1, df2) %>%
      mutate(positive = amount > 0) %>%
      group_by(category, period, positive) %>%
      summarise(total = sum(amount)/100) %>%
      ungroup()
    
    if (input$transactionType_Cmp == "in") {
      data <- data %>% filter(positive)
    } else if (input$transactionType_Cmp == "out") {
      data <- data %>% filter(!positive)
    }
    
    labelText <- case_match(
      input$transactionType,
      "in" ~ "wpływów",
      "out" ~ "wydatków",
      .default = "wpływów i wydatków"
    )
    
    ggplot() +
      geom_col(data = data %>%
                 group_by(category, period) %>%
                 summarise(total = sum(total)) %>%
                 ungroup(),
               aes(y = category, x = total, fill = period),
               width = 0.8,
               position = position_dodge(width = 0.8)) +
      geom_linerange(data = data,
                     aes(y = category, xmin = 0, xmax = total, color = period),
                     position = position_dodge(width = 0.8)) +
      scale_x_continuous(labels = moneyLabels) +
      labs(
        title = paste("Suma", labelText, "według kategorii"),
        subtitle = "Porównanie różnych okresów",
        x = "Kwota [zł]",
        y = "Kategoria",
        color = "Przedział czasowy:",
        fill = "Przedział czasowy:"
      ) +
      scale_fill_manual(values = c("1" = "#BC80BD", "2" = "#A6CEE3"))+
      scale_color_manual(values = c("1" = "#BC80BD", "2" = "#A6CEE3"))+
      theme_minimal()
  })

}

shinyApp(ui = ui, server = server)

