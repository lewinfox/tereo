# These functions are used to scrape dictionary entries from maoridictionary.co.nz and are not part
# of the package API.

get_word_page <- function(n) {
  BASE_URL <- "https://maoridictionary.co.nz/word/"
  url <- paste0(BASE_URL, n)
  page <- try(xml2::read_html(url), silent = TRUE)
  if (inherits(page, "try-error")) {
    msg <- glue::glue("Failed to fetch {url}")
    rlang::abort(msg, "tereo_page_load_failure")
  }
  if (!is_valid_word(page)) {
    rlang::abort("Page is not valid", "tereo_page_not_valid")
  }
  page
}

get_word <- function(n) {
  parse_word(get_word_page(n))
}

is_valid_word <- function(page) {
  titles <- rvest::html_nodes(page, "h2.title")
  !(length(titles) == 1 && rvest::html_text(titles[[1]]) == "Found 0 matches")
}

#' Parse a word object into a list
#'
#' Given an input word from the `get_word()` function, parse it into a list object
#'
#' @param word A word object returned from `get_word()`
#'
#' @return A list
parse_word <- function(word) {
  # Get the "result" div
  result <- rvest::html_node(word, "div.result > section")

  # Extract and clean the word
  word_node <- rvest::html_node(result, "h2")
  word <- trimws(stringr::str_extract(rvest::html_text(word_node), "^.+(?=\n)"))
  if (is.na(word)) {
    rlang::abort("Not a valid page", "tereo_page_not_valid")
  }

  # Get the entries
  entries <- rvest::html_nodes(result, "div.detail")
  entries_list <- lapply(entries, parse_entry)

  list(word = word, entries = entries_list)
}


#' Parse an entry
#'
#' Each word in the dictionary may have multiple entries where there are multiple meanings (e.g.
#' verbs and nouns, or different uses of the word). This function parses those and returns a data
#' structure containing the relevant information
#'
#' @param entry A dictionary entry parsed by [rvest::html_node()]
#'
#' @return A list
parse_entry <- function(entry) {
  # An entry has:
  # - A <p> containing:
  #   - A number (the first <strong>)
  #   - A part of speech tag (the second <strong>)
  #   - A definition (the rest of the <p>)
  # - Another <p> containing an example usage

  definition <- rvest::html_node(entry, "p:first-of-type")
  example <- rvest::html_node(entry, "p.example")
  example_text <- trim_multiple_whitespace(rvest::html_text(example))

  strongs <- rvest::html_nodes(definition, "strong")

  # Numeric entry index
  num <- trim_multiple_whitespace(rvest::html_text(strongs[[1]]))

  # POS = Part Of Speech (verb, noun etc.)
  if (length(strongs) > 1) {
    pos <- trim_multiple_whitespace(rvest::html_text(strongs[[2]]))
  } else {
    pos <- NULL
  }

  # Remove POS and number from definition string
  p_text <- trim_multiple_whitespace(rvest::html_text(definition))
  p_text <- stringr::str_remove(p_text, stringr::fixed(num))
  p_text <- trimws(stringr::str_remove(p_text, stringr::fixed(pos)))

  # Clean up `num` and `pos` to make them more reuseable
  pos <- stringr::str_extract(pos, "[[:alpha:]]+")

  list(part_of_speech = pos, definition = p_text, example = example_text)
}

#' Remove repeated whitespace characters from a string
#'
#' @param text A character vector
#'
#' @return `text` but with repeated whitespace and newlines removed
trim_multiple_whitespace <- function(text) {
  trimws(gsub("[[:space:]]+", " ", text))
}
