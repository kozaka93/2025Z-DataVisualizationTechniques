library(dplyr)
library(pdftools)
library(ggplot2)
library(tidyr)
library(zoo)

setwd("data/wyciagi")
files <- list.files(pattern = "pdf$")
files <- lapply(files, pdf_text)
setwd("../..")

getFileDate <- function(file) {
  file[1] %>%
    strsplit("\n") %>%
    unlist() %>%
    grep(pat = "Data wyciągu", value = TRUE) %>%
    strsplit("\\s+") %>%
    unlist() %>%
    last()
}

files <- files %>%
  sort_by(files %>%
            sapply(getFileDate))

transactions <- files %>%
  unlist() %>% # unlist to character vector of pages
  strsplit("\n{2,}") %>% # split paragraphs
  unlist() %>%
  strsplit("\n") %>% # split lines
  .[grepl("^\\d{4}\\.\\d{2}\\.\\d{2}\\s+", lapply(., first))] # filter paragraphs where first line starts with date

parseTransaction <- function(t) {
  date <- t[2] %>%
    substr(1, 10) %>%
    as.Date(format = "%Y.%m.%d")
  
  row1 <- t[1] %>% strsplit("\\s{4,}") %>% unlist()
  
  datePosted <- row1[1] %>%
    as.Date(format = "%Y.%m.%d")
  
  title <- row1[2] # title
  
  amount <- row1[3] %>%
    gsub(pat = "[, ]", rep = "") %>%
    as.integer()
  
  balance <- row1[4] %>%
    gsub(pat = "[ ,]", rep = "") %>%
    as.integer()
  
  description <- t[3:length(t)] %>%
    sub(pat = "^\\s+", rep = "") %>%
    sub(pat = "\\s+$", rep = "") %>%
    paste(collapse = " ")
  
  return(tibble(date = date,
                datePosted = datePosted,
                amount = amount,
                balance = balance,
                title = title,
                description = description))
}

df <- transactions %>%
  lapply(parseTransaction) %>%
  bind_rows()

# confirm that amounts and balances are read correctly and transactions are in the right order
initialBalance <- df$balance[1] - df$amount[1]
all(initialBalance + cumsum(df$amount) - df$balance == 0)

# calculate balance in the order of payment, not posting - that's what I need
df <- df %>%
  arrange(date) %>%
  mutate(balancePosted = balance,
         balance = initialBalance + cumsum(amount),
         .after = balance)

df %>%
  ggplot(aes(x = date, y = balance/100)) +
  geom_line() +
  labs(y = "balance [PLN]")

df %>%
  mutate(category = ifelse(amount > 0, "income", "expense"),
         amount = abs(amount)) %>%
  group_by(category) %>%
  mutate(cumulated = cumsum(amount)/100) %>%
  ggplot(aes(x = date, y = cumulated, color = category)) +
  geom_line() +
  labs(title = "cumulative expenses and income",
       y = "PLN")

df %>%
  filter(abs(amount) < 200*100) %>%
  mutate(expenses = -cumsum(amount)/100) %>%
  ggplot(aes(x = date, y = expenses)) +
  geom_line() +
  labs(title = "cumulative small transactions (less than 200 PLN at once)",
       y = "PLN")

df$description %>% unique()

categories <- c(
  "SPOLDZIELNIA DOBRZE" = "Jedzenie",
  "CARREFOUR PLA546" = "Jedzenie",
  "POLNY BAR MLECZNY" = "Gotowe jedzenie",
  "BISTRO PROPORCJA" = "Gotowe jedzenie",
  "Mobile Traffic DATA Sp. z o.o." = "Komunikacja miejska",
  "Pranie w Akademiku" = "Pranie",
  "intercity.pl" = "Pociągi",
  "www.koleo.pl" = "Pociągi",
  "AUTOMATY UVP MOSCISKA" = "Gotowe jedzenie",
  "HM PL0110" = "Odzież i obuwie",
  "APTEKA PRZY RIVIERZE" = "Inne",
  "BKM BIALYSTOK BYDGOSZCZ" = "Komunikacja miejska",
  "Opłata podstawowa za kartę: 5.00" = "Inne",
  "Pielmieni Szefa Warszawa" = "Gotowe jedzenie",
  "Księgowanie wpłatomat" = "Wypłata gotówki",
  "KANTYNA WARSZAWA" = "Gotowe jedzenie",
  "PIEKARNIA 'NA POLNEJ'" = "Gotowe jedzenie",
  "POLITECHNIKA WARSZAWSKA" = "Politechnika",
  "Politechnika Warszawska" = "Politechnika",
  "Ministerstwo Edukacji Narodowej" = "Politechnika",
  "STOKROTKA NR 1159" = "Jedzenie",
  "BILETOMAT" = "Komunikacja miejska",
  "ROSSMANN" = "Środki czystości",
  "ZABKA" = "Jedzenie",
  "botland.com.pl" = "Elektronika",
  "www.tme.eu" = "Elektronika",
  "Zeccer Express" = "Inne",
  "infopigula.pl" = "Inne",
  "pyszne.pl" = "Gotowe jedzenie",
  "www.galeriaplakatu.com" = "Inne",
  "planeta.azs.pl" = "Inne",
  "xtb.com" = "Inne",
  "vellees.pl" = "Inne",
  "Kwota w walucie rozliczeniowej: Kod MCC:" = "Inne",
  "BLIK" = "Zwrot pieniędzy",
  "Nowa Bankowość Mobilna" = "Zwrot pieniędzy",
  "Korzyść" = "Inne"
)

categories_order <- c(
  "Pranie",
  "Komunikacja miejska",
  "Pociągi",
  "Gotowe jedzenie",
  "Jedzenie i środki czystości",
  "Zwrot pieniędzy",
  "Inne",
  "Politechnika",
  "Wypłata gotówki",
  "Elektronika",
  "Ubrania"
)

df$matched_category <- df$description %>%
  sapply(function(desc) {
    matched <- names(categories)[sapply(names(categories), function(pat) {grepl(pat, desc)})]
    if (length(matched) > 1) warning(paste("matched more than 1 category:", paste(matched, collapse = ", ")))
    matched[1]
  })

df$category <- categories[df$matched_category]

df$category <- ifelse(df$category %in% c("Jedzenie", "Środki czystości"), "Jedzenie i środki czystości", df$category)

df$category %>%
  table(useNA = "always")

df %>%
  write.csv("data/parsed_transactions.csv", row.names = FALSE)

df %>%
  select(date, datePosted, amount, category) %>%
  write.csv("data_final/pkb/df.csv", row.names = FALSE)

df %>%
  filter(is.na(category)) %>%
  select(description) %>%
  View()

df %>%
  filter(category == "BLIK") %>%
  select(description) %>%
  View()

df %>%
  filter(category == "Inne") %>%
  select(description, amount) %>%
  arrange(-abs(amount)) %>%
  View()

df %>%
  group_by(category) %>%
  summarise(sum = sum(amount)) %>%
  arrange(sum)

df %>%
  group_by(matched_category) %>%
  summarise(sum = sum(amount)) %>%
  arrange(sum) %>%
  View()

df %>%
  filter(category == "Inne") %>%
  group_by(matched_category) %>%
  summarise(sum = sum(amount)) %>%
  arrange(sum)

df %>%
  filter(amount < 0 & amount > -100*1000) %>%
  filter(!is.na(category)) %>%
  mutate(category = factor(category, rev(categories_order))) %>%
  mutate(week = as.Date(cut.Date(date, breaks = "1 week"))) %>%
  group_by(week, category) %>%
  summarise(total = sum(-amount)/100) %>%
  ungroup() %>%
  complete(week, category, fill = list(total = 0)) %>%
  group_by(category) %>%
  mutate(total = rollmeanr(total, 4, fill = NA)) %>%
  ungroup() %>%
  ggplot(aes(x = week, y = total, fill = category, group = category)) +
  geom_area()

df %>%
  filter(amount < 0 & abs(amount) < 100*1000) %>%
  filter(!is.na(category)) %>%
  filter(!(category %in% c("Stypendium", "Wpłata gotówki"))) %>%
  mutate(month = as.Date(cut.Date(date, breaks = "1 month"))) %>%
  group_by(month, category) %>%
  summarise(total = sum(-amount)/100) %>%
  ungroup() %>%
  complete(month, category, fill = list(total = 0)) %>%
  mutate(category = factor(category, rev(categories_order))) %>%
  ggplot(aes(x = month, y = total, fill = category, group = category)) +
  geom_area()

setdiff(df$category, categories_order)

df %>%
  mutate(direction = ifelse(amount > 0, "income", "expense")) %>%
  mutate(category = ifelse(category == "Stypendium", "Politechnika", category)) %>%
  group_by(direction, category) %>%
  summarise(total = abs(sum(amount))/100) %>%
  ggplot(aes(x = direction, y = total, fill = category)) +
  geom_col()

df %>%
  group_by(category) %>%
  summarise(total = sum(amount)/100) %>%
  arrange(total)

weekday.names <- weekdays(seq(as.Date("2026-01-05"), as.Date("2026-01-11"), by = "1 day"))

df %>%
  # filter(amount < 0) %>%
  group_by(date, category) %>%
  summarise(total = sum(amount)/100) %>%
  ungroup() %>%
  rbind(tibble(date = seq(min(.$date), max(.$date), by = "1 day"),
               category = .$category[1],
               total = 0)) %>%
  complete(date, category, fill = list(total = 0)) %>%
  group_by(date) %>%
  summarise(total = sum(total)) %>%
  ungroup() %>%
  mutate(month_idx = match(months(date), month.name),
         week = as.Date(cut.Date(date, breaks = "1 week")),
         weekday = factor(weekdays(date), levels = weekday.names)) %>%
  ggplot(aes(x = week, y = weekday, fill = total)) +
  # geom_tile(data = . %>% filter(month_idx %% 2 == 1), fill = "gray") +
  geom_tile(width = 0.8*7, height = 0.8, color = "#888", linewidth = 0.1) +
  scale_fill_steps2(low = "red",
                    mid = "white",
                    high = "blue",
                    midpoint = 0,
                    trans = "pseudo_log",
                    breaks = c(-10^(3:0), 10^(0:3)),
                    labels = c(-10^(3:0), 10^(0:3))) +
  scale_x_date(expand = c(0, 0),
               date_breaks = "1 month",
               date_labels = "%b %y",
               ) +
  scale_y_discrete(expand = c(0, 0)) +
  coord_fixed(ratio = 7) +
  theme(panel.background = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(angle = 0, hjust = 0))
