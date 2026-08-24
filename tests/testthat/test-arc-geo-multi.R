test_that("arc_geo_multi() validates address components", {
  expect_snapshot(error = TRUE, arc_geo_multi())
  expect_snapshot(error = TRUE, arc_geo_multi("a", c("a", "b")))
  expect_snapshot(error = TRUE, arc_geo_multi(NA))
})

test_that("arc_geo_multi() accepts missing values across address components", {
  local_mock_arc_api()

  result <- arc_geo_multi(
    c(NA, "Plaza Mayor"),
    address2 = c("Guanajuato", NA),
    progressbar = FALSE
  )

  expect_s3_class(result, "tbl")
  expect_equal(nrow(result), 2)
  expect_identical(result$q_address, c(NA_character_, "Plaza Mayor"))
  expect_identical(result$q_address2, c("Guanajuato", NA_character_))
})

test_that("arc_geo_multi() reports capped limits and verbose requests", {
  local_mock_arc_api()

  expect_snapshot(out <- arc_geo_multi("Madrid", limit = 200))
  expect_snapshot(
    out <- arc_geo_multi(
      address = "Calle Mayor",
      city = "Madrid",
      countrycode = "ESP",
      verbose = TRUE
    )
  )
})

test_that("arc_geo_multi() controls basic output columns", {
  local_mock_arc_api()

  result <- arc_geo_multi(
    address = "Calle Mayor",
    city = "Madrid",
    countrycode = "ESP",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_named(
    result,
    c("q_address", "q_city", "q_countrycode", "query", "at", "ong")
  )
  expect_identical(result$at, 40.4168)
  expect_identical(result$ong, -3.7038)
})

test_that("arc_geo_multi() returns stable full-result fields", {
  calls <- local_mock_arc_api()

  result <- arc_geo_multi("Madrid", full_results = TRUE)

  expect_contains(
    names(result),
    c("q_address", "query", "lat", "lon", "Country", "LongLabel")
  )
  expect_identical(result$Country, "ESP")
  expect_match(calls$url, "outFields=*", fixed = TRUE)
})

test_that("arc_geo_multi() adds request parameters consistently", {
  calls <- local_mock_arc_api()

  arc_geo_multi(
    address = "Calle Mayor",
    city = "Madrid",
    countrycode = "ESP",
    limit = 10,
    outsr = 102100,
    langcode = "es",
    category = "Address",
    custom_query = list(outFields = "PlaceName", custom = "value")
  )

  expect_identical(
    calls$url,
    paste0(
      arc_endpoint_url("findAddressCandidates"),
      "address=Calle Mayor&city=Madrid&countryCode=ESP&",
      "f=json&maxLocations=10&outFields=PlaceName&custom=value&",
      "outSR=102100&langCode=es&category=Address"
    )
  )
})

test_that("arc_geo_multi() deduplicates requests and restores input rows", {
  calls <- local_mock_arc_api()
  addresses <- rep(c("Pentagon", "Barcelona"), 50)

  result <- arc_geo_multi(addresses, progressbar = FALSE)

  expect_length(calls$url, 2)
  expect_equal(nrow(result), 100)
  expect_identical(
    result$query,
    rep(c("address=Pentagon", "address=Barcelona"), 50)
  )
})

test_that("arc_geo_multi() displays progress only for multiple addresses", {
  local_mock_arc_api()

  expect_silent(arc_geo_multi("Madrid"))
  expect_silent(arc_geo_multi("Madrid", progressbar = TRUE))
  expect_output(arc_geo_multi(c("Madrid", "Barcelona")))
  expect_silent(arc_geo_multi(c("Madrid", "Barcelona"), progressbar = FALSE))
})

test_that("arc_geo_multi() filters results by category", {
  calls <- local_mock_arc_api()

  expect_snapshot(
    out <- arc_geo_multi(
      address = "Atocha",
      city = "Madrid",
      countrycode = "ESP",
      category = "POI",
      custom_query = list(
        outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"
      ),
      verbose = TRUE
    )
  )

  expect_snapshot(
    out2 <- arc_geo_multi(
      address = "Atocha",
      city = "Madrid",
      countrycode = "ESP",
      category = "Address",
      custom_query = list(
        outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"
      ),
      verbose = TRUE
    )
  )

  expect_match(calls$url[[1]], "category=POI", fixed = TRUE)
  expect_match(calls$url[[2]], "category=Address", fixed = TRUE)
})

test_that("arc_geo_multi() reaches the ArcGIS service", {
  skip_on_cran()
  skip_if_no_api_server()

  result <- arc_geo_multi(address = "Calle Mayor", city = "Madrid")

  expect_s3_class(result, "tbl")
  expect_contains(names(result), c("q_address", "q_city", "lat", "lon"))
})
