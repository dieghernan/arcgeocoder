test_that("Check access", {
  t <- expect_silent(arcgeocoder_check_access())

  expect_type(t, "logical")
})

test_that("Mock arc_download_file", {
  skip_on_cran()
  skip_if_api_server()

  my_fn <- arc_download_file
  local_mocked_bindings(
    arc_download_file = function(...) {
      FALSE
    }
  )

  api <- arc_endpoint_url("reverseGeocode")
  url <- paste0(api, "location=0,0&f=json")
  destfile <- tempfile(fileext = ".json")
  expect_silent(ss <- arc_api_call(url, destfile, TRUE))
  expect_false(ss)
  expect_false(arcgeocoder_check_access())
  expect_snapshot(arc_api_call(url, destfile, FALSE))

  # Restore mocked binding.
  local_mocked_bindings(arc_download_file = my_fn)

  expect_identical(arc_download_file, my_fn)
  expect_true(arcgeocoder_check_access())
})
