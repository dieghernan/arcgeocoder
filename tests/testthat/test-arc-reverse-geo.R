test_that("arc_reverse_geo() validates coordinate inputs", {
  expect_snapshot(error = TRUE, arc_reverse_geo(0, c(2, 3)))
  expect_snapshot(error = TRUE, arc_reverse_geo("a", "a"))
})

test_that("arc_reverse_geo() reports capped coordinates and verbose requests", {
  local_mock_arc_api("reverse-geocode.json")

  expect_snapshot(out <- arc_reverse_geo(200, 0))
  expect_snapshot(out <- arc_reverse_geo(0, 200))
  expect_snapshot(out <- arc_reverse_geo(0, 90, verbose = TRUE))
})

test_that("arc_reverse_geo() returns missing addresses for unmatched points", {
  calls <- local_mock_arc_api("reverse-error.json")

  expect_snapshot(
    obj <- arc_reverse_geo(179.9999, 89.999999, featuretypes = "StreetInt")
  )

  expect_identical(
    obj,
    dplyr::tibble(x = 179.9999, y = 89.999999, address = NA_character_)
  )

  expect_snapshot(
    obj_renamed <- arc_reverse_geo(
      179.9999,
      89.999999,
      address = "adddata",
      featuretypes = "StreetInt"
    )
  )

  expect_named(obj_renamed, c("x", "y", "adddata"))
  expect_length(calls$url, 2)
})

test_that("arc_reverse_geo() controls basic output columns", {
  local_mock_arc_api("reverse-geocode.json")

  result <- arc_reverse_geo(
    -3.6687109,
    40.4207414,
    address = "addrs",
    return_coords = FALSE
  )

  expect_named(result, "addrs")
  expect_identical(result$addrs, "Madrid, Spain")
})

test_that("arc_reverse_geo() returns stable full-result fields", {
  local_mock_arc_api("reverse-geocode.json")

  result <- arc_reverse_geo(
    -3.6687109,
    40.4207414,
    address = "addrs",
    full_results = TRUE
  )

  expect_contains(
    names(result),
    c("x", "y", "addrs", "lat", "lon", "City", "CountryCode", "wkid")
  )
  expect_identical(result$addrs, "Madrid, Spain")
  expect_identical(result$wkid, 4326L)
})

test_that("arc_reverse_geo() adds request parameters consistently", {
  calls <- local_mock_arc_api("reverse-geocode.json")

  arc_reverse_geo(
    -3.6687109,
    40.4207414,
    outsr = 102100,
    langcode = "es",
    featuretypes = c("POI", "StreetInt"),
    locationtype = "rooftop",
    custom_query = list(custom = "value")
  )

  expect_identical(
    calls$url,
    paste0(
      arc_endpoint_url("reverseGeocode"),
      "location=-3.6687109,40.4207414&f=json&custom=value&",
      "outSR=102100&langCode=es&featureTypes=POI,StreetInt&",
      "locationType=rooftop"
    )
  )
})

test_that("arc_reverse_geo() unnests full results with stable types", {
  local_mock_arc_api("reverse-geocode.json")

  result <- arc_reverse_geo(
    x = c(-73.98586, -3.188375),
    y = c(40.75728, 55.95335),
    full_results = TRUE,
    progressbar = FALSE
  )

  expect_s3_class(result, "tbl")
  expect_equal(nrow(result), 2)
  expect_type(result$x, "double")
  expect_type(result$y, "double")
  expect_type(result$lat, "double")
  expect_type(result$lon, "double")
})

test_that("arc_reverse_geo() deduplicates requests and restores input rows", {
  calls <- local_mock_arc_api("reverse-geocode.json")
  lats <- rep(c(40.75728, 55.95335), 50)
  longs <- rep(c(-73.98586, -3.188375), 50)

  result <- arc_reverse_geo(longs, lats, progressbar = FALSE)

  expect_length(calls$url, 2)
  expect_equal(nrow(result), 100)
  expect_identical(result$x, longs)
  expect_identical(result$y, lats)
})

test_that("arc_reverse_geo() displays progress only for multiple points", {
  local_mock_arc_api("reverse-geocode.json")
  lat <- c(40.75728, 55.95335)
  long <- c(-73.98586, -3.188375)

  expect_silent(arc_reverse_geo(long[1], lat[1]))
  expect_silent(arc_reverse_geo(long[1], lat[1], progressbar = TRUE))
  expect_output(arc_reverse_geo(long, lat), "50")
  expect_silent(arc_reverse_geo(long, lat, progressbar = FALSE))
})

test_that("arc_reverse_geo() returns missing data when the API request fails", {
  local_mocked_bindings(arc_api_call = function(...) FALSE)

  expect_snapshot(obj <- arc_reverse_geo(-3.6687109, 40.4207414))

  expect_identical(
    obj,
    dplyr::tibble(x = -3.6687109, y = 40.4207414, address = NA_character_)
  )
})

test_that("arc_reverse_geo() reaches the ArcGIS service", {
  skip_on_cran()
  skip_if_no_api_server()

  result <- arc_reverse_geo(-3.6687109, 40.4207414)

  expect_s3_class(result, "tbl")
  expect_named(result, c("x", "y", "address"))
})
