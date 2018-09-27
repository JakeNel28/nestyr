#'Nest columns together, preserving rows
#'
#'@description
#'
#'Nest specified columns together, while preserving rows.
#'
#'@importFrom tidyselect vars_select
#'@importFrom rlang !!! quos quo_name enexpr is_empty syms
#'@importFrom assertthat assert_that
#'@importFrom dplyr setdiff select group_by vars is_grouped_df group_vars ungroup
#'
#'@param data A data frame.
#'@param ... A selection of columns to nest together. See the
#'  \code{\link[dplyr:select]{dplyr::select()}} documentation for more options.
#'  Cannot include variable used in grouping.
#'@param .key The name of the new column, as a string or symbol.
#'
#'@examples
#'library(dplyr)
#'
#'#Place "Sepal" and "Petal" columns into nests
#'
#'iris %>%
#'  nest_cols(starts_with("Sepal"), .key = "Sepal") %>%
#'  nest_cols(starts_with("Petal"), .key = "Petal")
#'
#'@export


nest_cols <- function(data, ..., .key = "data") {
  UseMethod("nest_cols")
}

#'@export

nest_cols.data.frame <- function(data, ..., .key = "data") {
  key_var <- quo_name(enexpr(.key))
  nest_vars <- vars_select(names(data), ...)
  if(is_empty(nest_vars)) {
    nest_vars <- names(data)
  }
  grouped <- is_grouped_df(data)
  if(grouped) {
    groups <- group_vars(data)
    assert_that(!groups %in% nest_vars,
                msg = "Cannot nest a variable used in grouping")
    data <- ungroup(data)
  }
  out <- select(data, setdiff(names(data), nest_vars))
  idx <- 1:nrow(data)
  out[[key_var]] <- unname(split(data[nest_vars], idx))
  if(grouped) {
    out <- group_by(out, !!!syms(groups))
  }
  out
}


