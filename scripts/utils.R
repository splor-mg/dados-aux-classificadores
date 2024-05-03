

write_attachment <- function(message_id) {
  message <- gmailr::gm_message(message_id)
  attachments <- gmailr::gm_attachments(message)
  logger::log_info('Extracting attachment {attachments[["filename"]]}')
  filename <- stringr::str_remove(attachments[["filename"]], "-\\d{4}-\\d{2}-\\d{2}-\\d{2}-\\d{2}-\\d{2}")
  attachment_id <- attachments[["id"]]
  result <- gmailr::gm_attachment(attachment_id, message_id)
  gmailr::gm_save_attachment(result, paste0("data-raw/", filename))
  unzip(paste0("data-raw/", filename), exdir = "data-raw/")
  file.remove(paste0("data-raw/", filename)) # deleta arquivos .zip
  old_filename <- sub("\\.zip$", ".csv", filename)
  new_filename <- gsub("-", "_", old_filename)
  file.rename(paste0("data-raw/", old_filename), paste0("data-raw/", new_filename))
  lines <- readLines(paste0("data-raw/", new_filename))
  last_non_blank_index <- max(which(nchar(lines) > 0))
  writeLines(lines[1:last_non_blank_index], paste0("data-raw/", new_filename))
}



#filename <- gsub("-", "_", filename)
