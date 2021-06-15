Dictionary <- R6::R6Class(
  classname = "Dictionary",
  public = list(
    initialize = function() {
      # Determine a list of all the entries
      data_path <- dirname(system.file("extdata", "README.md", package = "tereo", mustWork = TRUE))
      private$files <- list.files(data_path, ".rda")
      private$indices <- stringr::str_extract(private$files, "^[0-9]+")
      private$words <- trimws(stringr::str_extract(private$files, "(?<=-).*(?=\\.rda$)"))
      ord <- order(private$words)
      private$files <- private$files[ord]
      private$indices <- private$indices[ord]
      private$words <- private$words[ord]
    },
    print = function() {
      cat("Te Reo Māori dictionary\n")
      cat("  ", length(private$files), "entries\n")
    },
    search = function(what) {
      if (is.numeric(what)) {
        return(private$read_entry(index = what))
      }
      return(private$read_entry(word = what))
    },
    get_words = function() private$words
  ),
  private = list(
    files = character(),
    words = character(),
    indices = character(),
    read_entry = function(index = NULL, word = NULL) {
      if (is.null(index)) {
        index <- which(grepl(word, private$words, perl = TRUE))
        if (!length(index)) {
          index <- which(grepl(str_remove_macrons(word), str_remove_macrons(private$words), perl = TRUE))
        }
        if (!length(index)) {
          cli::cli_alert_warning("No entry found")
          return(NULL)
        }
      }
      file <- system.file("extdata", private$files[index], package = "tereo", mustWork = TRUE)
      res <- lapply(file, readRDS)
      names(res) <- private$words[index]
      if (length(res) > 1) {
        words <- glue::glue_collapse(paste0("{.var ", private$words[index], "}"), sep = ", ", last = " and ")
        msg <- glue::glue("{length(res)} results found: {words}")
        cli::cli_alert_info(msg)
      }
      res
    }
  )
)
