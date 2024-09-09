#' Columns wrappers
#'
#' Wrapper around `column(12, ...)`.
#' `golem::use_utils_ui()` provides more wrappers.
#'
#' @noRd
#'
#' @importFrom shiny column
col_6 <- function(...) {
  column(6, ...)
}

#' List all the countries in the dataset
#' @noRd
#' @importFrom rlang sym
#' @importFrom dplyr distinct mutate_if pull
list_countries <- function() {
  out <- list()

  daux <- freedomhouse::country_rating_status %>%
    distinct(
      !!sym("continent"),
      !!sym("country")
    ) %>%
    mutate_if(is.factor, as.character)

  continents <- unique(daux$continent)

  for (i in seq_along(continents)) {
    out[[i]] <- daux %>%
      filter(!!sym("continent") == continents[i]) %>%
      pull(!!sym("country"))
  }

  names(out) <- continents

  return(out)
}
