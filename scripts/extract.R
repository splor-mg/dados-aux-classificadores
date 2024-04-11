
source("scripts/utils.R")

gmailr::gm_auth(token = gmailr::gm_token_read(
  path = "gmail.rds",
  key = "GMAILR_KEY"
))

current_date = Sys.Date()

search_query_new = paste0("subject:(aux)"," after: ", current_date, " filename:.csv")

gmailr::gm_messages(search_query_new) |>
gmailr::gm_id() |>
purrr::walk(write_attachment)






  




