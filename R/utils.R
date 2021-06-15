str_remove_macrons <- function(x) {
  replacements <- c(
    Ā = "A", ā = "a",
    Ē = "E", ē = "e",
    Ī = "I", ī = "i",
    Ō = "O", ō = "o",
    Ū = "U", ū = "u")
  stringr::str_replace_all(x, replacements)
}
