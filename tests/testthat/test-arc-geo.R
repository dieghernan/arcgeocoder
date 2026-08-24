test_that("arc_geo() returns missing coordinates for unmatched addresses", {
  calls <- local_mock_arc_api("empty-candidates.json")

  expect_snapshot(obj <- arc_geo("alsksjdhfg 561bata lorem ipsum"))

  expect_identical(
    obj,
    dplyr::tibble(
      query = "alsksjdhfg 561bata lorem ipsum",
      lat = NA_real_,
      lon = NA_real_
    )
  )

  expect_snapshot(
    obj_renamed <- arc_geo(
      "alsksjdhfg 561bata lorem ipsum",
      lat = "lata",
      long = "longa"
    )
  )

  expect_named(obj_renamed, c("query", "lata", "longa"))
  expect_length(calls$url, 2)
})

test_that("arc_geo() reports capped limits and verbose requests", {
  local_mock_arc_api()

  expect_snapshot(out <- arc_geo("Madrid", limit = 200))
  expect_snapshot(out <- arc_geo("Madrid", verbose = TRUE))
})

test_that("arc_geo() controls basic output columns", {
  local_mock_arc_api()

  result <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_named(result, c("query", "at", "ong"))
  expect_identical(result$at, 40.4168)
  expect_identical(result$ong, -3.7038)
})

test_that("arc_geo() returns stable full-result fields", {
  calls <- local_mock_arc_api()

  result <- arc_geo("Madrid", full_results = TRUE)

  expect_contains(
    names(result),
    c("query", "lat", "lon", "address", "Country", "LongLabel")
  )
  expect_identical(result$Country, "ESP")
  expect_match(calls$url, "outFields=*", fixed = TRUE)
})

test_that("arc_geo() adds request parameters consistently", {
  calls <- local_mock_arc_api()

  arc_geo(
    "Burger King",
    limit = 10,
    sourcecountry = "ES",
    outsr = 102100,
    langcode = "es",
    category = "Restaurant",
    custom_query = list(outFields = "PlaceName", custom = "value")
  )

  expect_identical(
    calls$url,
    paste0(
      arc_endpoint_url("findAddressCandidates"),
      "SingleLine=Burger King&f=json&maxLocations=10&",
      "outFields=PlaceName&custom=value&sourceCountry=ES&",
      "outSR=102100&langCode=es&category=Restaurant"
    )
  )
})

test_that("arc_geo() deduplicates requests and restores input rows", {
  calls <- local_mock_arc_api()
  addresses <- rep(c("Pentagon", "Barcelona"), 50)

  result <- arc_geo(addresses, progressbar = FALSE)

  expect_length(calls$url, 2)
  expect_equal(nrow(result), 100)
  expect_identical(result$query, addresses)
})

test_that("arc_geo() displays progress only for multiple addresses", {
  local_mock_arc_api()

  expect_silent(arc_geo("Madrid"))
  expect_silent(arc_geo("Madrid", progressbar = TRUE))
  expect_output(arc_geo(c("Madrid", "Barcelona")))
  expect_silent(arc_geo(c("Madrid", "Barcelona"), progressbar = FALSE))
})

test_that("arc_geo() filters results by category", {
  calls <- local_mock_arc_api()

  expect_snapshot(
    out <- arc_geo(
      "",
      category = "Gas Station",
      custom_query = list(
        outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"
      ),
      verbose = TRUE
    )
  )

  expect_snapshot(
    out2 <- arc_geo(
      "",
      category = "Restaurant",
      custom_query = list(
        outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"
      ),
      verbose = TRUE
    )
  )

  expect_match(calls$url[[1]], "category=Gas Station", fixed = TRUE)
  expect_match(calls$url[[2]], "category=Restaurant", fixed = TRUE)
})

test_that("arc_geo() returns missing coordinates when the API request fails", {
  local_mocked_bindings(arc_api_call = function(...) FALSE)

  expect_snapshot(obj <- arc_geo("Madrid"))

  expect_identical(
    obj,
    dplyr::tibble(query = "Madrid", lat = NA_real_, lon = NA_real_)
  )
})

test_that("arc_geo() reaches the ArcGIS service", {
  skip_on_cran()
  skip_if_no_api_server()

  result <- arc_geo("Madrid")

  expect_s3_class(result, "tbl")
  expect_contains(names(result), c("query", "lat", "lon", "address"))
})
