source("quiz/questions.R")

make_quiz <- function(n_questions = 8) {
  
  selected <- sample(
    quiz_questions,
    size = min(n_questions, length(quiz_questions)),
    replace = FALSE
  )
  
  messages <- create_messages(
    message_correct = "Świetnie!",
    message_wrong   = "Spróbuj jeszcze raz",
    message_skipped = "Quiz przerwany"
  )
  
  create_quiz(
    selected,
    options = set_quiz_options(
      sandbox = FALSE,
      messages = messages,
      allow_skip = TRUE,
      force_radio = TRUE
    )
  )
}