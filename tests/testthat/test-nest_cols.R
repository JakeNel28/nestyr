context("test-nest_cols")
library(tibble)
library(rlang)
library(tidyr)
library(dplyr)

test_that("Preserves rows, but nests columns", {
  df <- tibble(a_1 = c(1,2,3), a_2 = c(1,2,3), b = c(1,2,2))
  nested <- nest_cols(df, a_1, a_2, .key = "a")
  expect_equal(dim(nested), c(3,2))
  expect_equal(names(nested), c("b", "a"))
  expect_true(is_bare_list(nested[["a"]]))
})

test_that("groups don't affect nest, preserves groups", {
  df <- tibble(a_1 = c(1,2,3), a_2 = c(1,2,3), b = c(1,2,2)) %>%
    group_by(b)
  nested <- nest_cols(df, a_1, a_2, .key = "a")
  expect_equal(dim(nested), c(3,2))
  expect_equal(names(nested), c("b", "a"))
  expect_true(is_bare_list(nested[["a"]]))
  expect_true(is_grouped_df(nested))
  expect_equal(group_vars(nested), "b")
})

test_that("multiple nesting works", {
  df <- tibble(a_1 = c(1,2,3), a_2 = c(1,2,3), b = c(1,2,2), c_1 = c(1,1,NA),
               c_2 = c(2,NA,2))
  nested <- df %>%
    nest_cols(starts_with("a"), .key = "a") %>%
    nest_cols(starts_with("c"), .key = "c")
  expect_true(is.list(nested[["a"]]) & is.list(nested[["c"]]))
})

test_that("grouping variables can't be used to nest", {
  df <- tibble(a_1 = c(1,1,3), a_2 = c(1,2,3), b = c(1,2,2)) %>%
    group_by(a_1)
  expect_error(nest_cols(df, starts_with("a")))
})
