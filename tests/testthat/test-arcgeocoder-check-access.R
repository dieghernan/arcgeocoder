test_that("arcgeocoder_check_access() validates the ArcGIS response", {
  withr::local_envvar(NOT_CRAN = "true")
  calls <- local_mock_arc_api("check-access.json")

  expect_true(arcgeocoder_check_access())
  expect_length(calls$url, 1)
})

test_that("arcgeocoder_check_access() stops before requests on CRAN", {
  withr::local_envvar(NOT_CRAN = "false")
  local_mocked_bindings(arc_api_call = function(...) {
    stop("API request should not be made")
  })

  expect_false(arcgeocoder_check_access())
})

test_that("arcgeocoder_check_access() handles failed API requests", {
  withr::local_envvar(NOT_CRAN = "true")
  local_mocked_bindings(arc_api_call = function(...) FALSE)

  expect_false(arcgeocoder_check_access())
})

test_that("arc_api_call() retries failed downloads once", {
  downloads <- 0L
  local_mocked_bindings(arc_download_file = function(...) {
    downloads <<- downloads + 1L
    FALSE
  })

  api <- arc_endpoint_url("reverseGeocode")
  url <- paste0(api, "location=0,0&f=json")
  destfile <- withr::local_tempfile(fileext = ".json")

  expect_snapshot(arc_api_call(url, destfile, FALSE, wait = function(...) NULL))
  expect_equal(downloads, 2L)
})

test_that("arc_api_call() succeeds when the retry succeeds", {
  downloads <- 0L
  local_mocked_bindings(arc_download_file = function(...) {
    downloads <<- downloads + 1L
    downloads == 2L
  })

  destfile <- withr::local_tempfile(fileext = ".json")

  expect_true(arc_api_call(
    "https://example.com",
    destfile,
    TRUE,
    wait = function(...) NULL
  ))
  expect_equal(downloads, 2L)
})

test_that("on_cran() follows NOT_CRAN", {
  withr::local_envvar(NOT_CRAN = "false")

  expect_true(on_cran())

  withr::local_envvar(NOT_CRAN = "true")

  expect_false(on_cran())

  withr::local_envvar(NOT_CRAN = NA)

  expect_identical(on_cran(), !interactive())
})

test_that("arcgeocoder_check_access() reaches the ArcGIS service", {
  skip_on_cran()
  skip_if_no_api_server()

  expect_true(arcgeocoder_check_access())
})
