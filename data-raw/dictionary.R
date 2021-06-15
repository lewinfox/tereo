#' Scrapes www.maoridictionary.co.nz and saves the entries
#'
#' Each word can be found at http://www.maoridictionary.co.nz/word/{index}. The range of valid
#' indices may vary, but at the moment it seems to be from 0 to around 48,000. The whole process
#' will take several hours. There is no guarantee that the collection is currently complete or that
#' this function will fully capture future additions.
#'
#' @param index Integer in the range 0 - 50,000 (roughly).
#'
#' @return The function does not return anything, but writes .rda files to `inst/extdata/`.
scrape_te_reo_dictionary <- function(index = NULL) {
  word_idx <- seq(0L, 50000L)
  bad_word_file <- system.file("extdata", "bad_indices.txt", package = "tereo", mustWork = TRUE)
  bad_words <- as.integer(readLines(bad_word_file))
  word_idx <- setdiff(word_idx, bad_words)
  files <- list.files(file.path("inst", "extdata"), pattern = ".rda")
  nums <- as.numeric(stringr::str_extract(files, "[0-9]+"))
  word_idx <- setdiff(word_idx, nums)
  success <- rep(FALSE, length(word_idx))
  while (!all(success)) {
    if (is.null(index)) {
      index <- min(which(!success))
    }
    while (index <= length(word_idx)) {
      if (success[index]) {
        break
      }
      message("Trying ", word_idx[index])
      next_to_do <- word_idx[index]
      entry <- tryCatch({
        entry <- get_word(next_to_do)
        word <- entry$word
        word <- stringr::str_replace_all(word, "/", "-")
        filename <- paste0(next_to_do, "-", word, ".rda")
        filename <- system.file("extdata", filename, package = "tereo")
        saveRDS(entry, filename)
        tmp <- readRDS(filename)  # Make sure it can be read back in
        success[index] <- TRUE
        message("Successfully processed ", word)
        },
        tereo_page_not_valid = function(e) {
          cat(next_to_do, "\n", file = bad_word_file, append = TRUE, sep = "")
          bad_words <- as.integer(readLines(bad_word_file))
          word_idx <- setdiff(word_idx, bad_words)
        },
        tereo_page_load_failure = function(e) cli::cli_alert_info(e),
        error = function(e) cli::cli_alert_warning("Something broke")
      )
      index <- index + 1L
      Sys.sleep(0.5) # To avoid hammering the server too much
    }
  }
  message("Finished")
}

scrape_te_reo_dictionary()

files <- list.files(file.path("inst", "extdata"), pattern = ".rda", full.names = TRUE)
names <- stringr::str_extract(files, "(?<=-)[^0-9]+(?=\\.rda$)")

# Group duplicates
dupes <- split(files, names)
dupes <- dupes[sapply(dupes, length) > 1]

# Remove any that produce identical objects
remove_duplicates <- function(x) {
  old_idx <- 1
  seen_hashes <- digest::digest(readRDS(x[[1]]))
  for (i in 2:length(x)) {
    if (!is.na(x[[i]]) && file.exists(x[[i]])) {
      message("reading ", x[[i]])
      new_hash <- digest::digest(readRDS(x[[i]]))
      if (new_hash %in% seen_hashes) {
        message("removing ", x[[i - 1]])
        file.remove(x[[i - 1]])
      }
      seen_hashes <- union(seen_hashes, new_hash)
    }
  }
}

x <- sapply(dupes, remove_duplicates)

# now that we have all the files downloaded, bucket them into something sensible. First three
# letters gives a reasonable spacing although there are a couple of long ones.

regex_macrons <- "āĀēĒīĪōŌūŪ"
files <- list.files(file.path("inst", "extdata"), pattern = ".rda", full.names = TRUE)
x <- split(files, stringr::str_extract(tolower(basename(files)), "[[:alpha:]]{1,3}"))

word_from_filename <- function(filename) {
  stringr::str_extract(filename, "(?<=-)[^0-9]+(?=\\.rda$)")
}

bucket_word <- function(word) {
  stringr::str_extract(tolower(str_remove_macrons(files)), "[a-z]{1,3}")
}

do_list <- function(x, prefix) {
  browser()
  words <- word_from_filename(x[[prefix]])
  res <- lapply(x[[prefix]], readRDS)
  names(res) <- words
  outfile <- file.path("data", paste0(prefix, ".rda"))
  saveRDS(res, outfile)
}

one <- do_list(x, "a")
