test_that("Check access", {
  t <- expect_silent(arcgeocoder_check_access())

  expect_type(t, "logical")
})
