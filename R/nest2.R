#'Performs the same operation as \code{\link[tidyr:nest]{tidyr::nest()}}, but
#'allows for preexisting list-columns to be used to index rows. This allows
#'or creating multiple nested columns (which are list-columns).
#'
#'  See \code{\link[tidyr:nest]{tidyr::nest()}} for additional documentation
#'
#'@importFrom purrr map_lgl map_chr
#'@importFrom rlang quo_name enexpr is_empty syms :=
#'@importFrom tidyselect vars_select
#'@importFrom dplyr is_grouped_df group_vars setdiff ungroup select mutate_at vars group_indices slice funs
#'@importFrom tibble tibble
#'@importFrom digest digest
#'
#'@param data A data frame.
#'@param ... A selection of columns. If empty, all variables are selected. You
#'can supply bare variable names, select all variables between x and z with
#'`x:z`, exclude y with `-y`. For more options, see the
#'\code{\link[dplyr:select]{dplyr::select()}} documentation. See also the
#'section on selection rules for \code{\link[tidyr:nest]{tidyr::nest()}}.
#'@param .key The name of the new column, as a string or symbol.
#'
#'@export
#'
#'@examples
#'#Nest a column with a list column already present
#'
#'library(tidyr)
#'library(dplyr)
#'library(tibble)
#'
#'as_tibble(iris) %>%
#'  rowid_to_column("rowid") %>%
#'  nest2(starts_with("Sepal"), .key = "Sepal") %>%
#'  nest2(starts_with("Petal"), .key = "Petal")
#'
#'#This does not work with tidyr::nest()
#'
#'\dontrun{
#'
#'as_tibble(iris) %>%
#'  rowid_to_column("rowid") %>%
#'  nest(starts_with("Sepal"), .key = "Sepal") %>%
#'  nest(starts_with("Petal"), .key = "Petal")
#'}

nest2 <- function(data, ..., .key = "data") {
  UseMethod("nest2")
}

#'@export

nest2.data.frame <- function(data, ..., .key = "data") {
  listcols <- unclass(data[map_lgl(data, ~is.list(.x))])
  listcol_names <- names(listcols)
  key_var <- quo_name(enexpr(.key))
  nest_vars <- unname(vars_select(names(data), ...))
  if (is_empty(nest_vars)) {
    nest_vars <- names(data)
  }
  if (is_grouped_df(data)) {
    group_vars <- group_vars(data)
  }
  else {
    group_vars <- setdiff(names(data), nest_vars)
  }
  nest_vars <- setdiff(nest_vars, group_vars)
  data <- ungroup(data)
  if (is_empty(group_vars)) {
    return(tibble(`:=`(!!key_var, list(data))))
  }
  out <- select(data, !!!syms(group_vars))
  digested_data <- mutate_at(data, vars(!!listcol_names),
                             funs(map_chr(., ~digest(.x, algo = "md5"))))
  idx <- group_indices(digested_data, !!!syms(group_vars))
  representatives <- which(!duplicated(idx))
  out <- slice(out, representatives)
  out[[key_var]] <- unname(split(data[nest_vars], idx))[unique(idx)]
  out
}
