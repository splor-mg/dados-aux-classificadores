

write_attachment <- function(message_id) {
  message <- gmailr::gm_message(message_id)
  attachments <- gmailr::gm_attachments(message)
  logger::log_info('Extracting attachment {attachments[["filename"]]}')
  filename <- stringr::str_remove(attachments[["filename"]], "-\\d{4}-\\d{2}-\\d{2}-\\d{2}-\\d{2}-\\d{2}")
  filename <- gsub("-", "_", filename)
  attachment_id <- attachments[["id"]]
  result <- gmailr::gm_attachment(attachment_id, message_id)
  gmailr::gm_save_attachment(result, paste0("data-raw/", filename))
}
