context("test-nest2")
library(tibble)
library(rlang)
library(tidyr)
library(dplyr)

test_that("Multiple nesting works", {
  df <- tibble(a_1 = c(1,2,3),
               a_2 = c(1,2,3),
               b = list(
                 tibble(c_1 = 1, c_2 = 0),
                 tibble(c_1 = 0, c_2 = 1),
                 tibble(c_1 = 2, c_2 = 2)
               )
  )
  nested <- nest2(df, starts_with("a"), .key = "a")
  expect_equal(names(nested), c("b", "a"))
  expect_true(all(map_lgl(nested, ~is.list(.x))))
})

test_that("nest turns grouped values into one list-df", {
  df <- tibble(x = c(1, 1, 1), y = 1:3)
  out <- nest(df, y)
  expect_equal(out$x, 1)
  expect_equal(out$data, list(data.frame(y = 1:3)))
})

test_that("can control output column name", {
  df <- tibble(x = c(1, 1, 1), y = 1:3)
  out <- nest(df, y, .key = y)
  expect_equal(names(out), c("x", "y"))
})

test_that("nest doesn't include grouping vars in nested data", {
  df <- tibble(x = c(1, 1, 1), y = 1:3)
  out <- df %>% dplyr::group_by(x) %>% nest()
  expect_equal(out$data[[1]], data.frame(y = 1:3))
})

test_that("can restrict variables in grouped nest", {
  df <- tibble(x = 1, y = 2, z = 3) %>% group_by(x)
  out <- df %>% nest(y)
  expect_equal(names(out$data[[1]]), "y")
})

test_that("puts data into the correct row", {
  df <- tibble(x = 1:3, y = c("B", "A", "A"))
  out <- nest(df, x) %>% dplyr::filter(y == "B")
  expect_equal(out$data[[1]]$x, 1)
})

test_that("nesting everything yields a simple data frame", {
  df <- tibble(x = 1:3, y = c("B", "A", "A"))
  out <- nest(df, x, y)
  expect_equal(out$data, list(df))
})

test_that("nesting works for empty data frames", {
  df <- tibble(x = 1:3, y = c("B", "A", "A"))[0, ]

  out <- nest(df, x)
  expect_equal(names(out), c("y", "data"))
  expect_equal(nrow(out), 0)
  expect_equal(out$data, list())
  # unnest(out) is missing the x column

  out <- nest(df, x, y)
  expect_equal(out$data, list(df))
})
