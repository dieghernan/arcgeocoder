test_that("Custom query", {
  res <- add_custom_query(list(a = 1, b = 2), url = "an_url")
  expect_identical(res, "an_url&a=1&b=2")
  res2 <- add_custom_query(list(a = c(1, 2), b = 3), url = "an_url")
  expect_identical(res2, "an_url&a=1,2&b=3")
})

test_that("urls", {
  s <- arcurl("cand")
  expect_true(is.character(s))
})


test_that("names", {
  l <- list(a = "f", b = "a")
  expect_true(is_named(l))

  l <- list(a = "f", NULL)
  expect_false(is_named(l))

  l <- list(a = "f", NA)
  expect_false(is_named(l))

  l <- list(a = "f", "b")
  expect_false(is_named(l))

  l <- list("b")
  expect_false(is_named(l))

  l <- list(NULL)
  expect_false(is_named(l))

  l <- list(NA)
  expect_false(is_named(l))
})

test_that("multi-field query rows", {
  row <- dplyr::tibble(
    address = "Calle Mayor",
    city = NA_character_,
    countryCode = "ESP"
  )
  expect_identical(
    multi_row_query(row),
    "address=Calle Mayor&countryCode=ESP"
  )

  empty_row <- dplyr::tibble(
    address = NA_character_,
    city = NA_character_
  )
  expect_identical(multi_row_query(empty_row), NA_character_)
})
