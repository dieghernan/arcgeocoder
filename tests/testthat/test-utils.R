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
