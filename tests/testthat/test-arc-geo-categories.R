test_that("arc_geo_categories() validates locations and reserved arguments", {
  expect_snapshot(error = TRUE, arc_geo_categories("Food"))
  expect_snapshot(error = TRUE, arc_geo_categories("Food", "a", "a"))
  expect_snapshot(
    error = TRUE,
    arc_geo_categories("Food", 0, 0, address = "Error")
  )
  expect_snapshot(
    error = TRUE,
    arc_geo_categories("Food", 0, 0, progressbar = TRUE)
  )
  expect_snapshot(
    error = TRUE,
    arc_geo_categories("Food", 0, 0, return_addresses = TRUE)
  )
})

test_that("arc_geo_categories() reports adjusted and incomplete locations", {
  local_mock_arc_api()

  expect_snapshot(out <- arc_geo_categories("POI", 200, 0))

  local_mock_arc_api("empty-candidates.json")
  expect_snapshot(
    out <- arc_geo_categories("Address,Postal,Coordinate System,POI", 0, 200)
  )

  local_mock_arc_api()
  expect_snapshot(
    out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, verbose = TRUE)
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = 3.7242,
      bbox = c(-3.8, 40.3, -3.65, 40.5)
    )
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      y = 3.7242,
      bbox = c(-3.8, 40.3, -3.65, 40.5)
    )
  )
})

test_that("arc_geo_categories() validates and caps bounding boxes", {
  local_mock_arc_api()

  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = -3.7242,
      y = 40.39094,
      bbox = "uno",
      verbose = TRUE
    )
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = -3.7242,
      y = 40.39094,
      bbox = c("uno", NA),
      verbose = TRUE
    )
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = -3.7242,
      y = 40.39094,
      bbox = LETTERS[1:4],
      verbose = TRUE
    )
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = -3.7242,
      y = 40.39094,
      bbox = c(-200, -89, 200, 89),
      verbose = TRUE
    )
  )
  expect_snapshot(
    out <- arc_geo_categories(
      "POI",
      x = -3.7242,
      y = 40.39094,
      bbox = c(-100, -95, 100, 95),
      verbose = TRUE
    )
  )
})

test_that("arc_geo_categories() adds query parameters consistently", {
  calls <- local_mock_arc_api("find-address-longlabel.json")

  expect_snapshot(
    out <- arc_geo_categories(
      "POI,Address",
      x = -3.7242,
      y = 40.39094,
      name = "Bar",
      limit = 20,
      lon = "aaaa",
      lat = "bbbb",
      bbox = c(-3.8, 40.3, -3.65, 40.5),
      sourcecountry = "ES",
      verbose = TRUE,
      outsr = 102100,
      langcode = "ES",
      custom_query = list(outFields = "LongLabel")
    )
  )

  expect_length(calls$url, 2)
  expect_match(calls$url[[1]], "category=POI", fixed = TRUE)
  expect_match(calls$url[[2]], "category=Address", fixed = TRUE)
  expect_contains(names(out), c("bbbb", "aaaa", "LongLabel"))
  expect_false("query" %in% names(out))
  expect_false(any(grepl("Country", names(out), fixed = TRUE)))
})

test_that("arc_geo_categories() returns stable full-result fields", {
  local_mock_arc_api()

  result <- arc_geo_categories(
    "POI,Bakery",
    x = -3.7242,
    y = 40.39094,
    limit = 2,
    lon = "aaaa",
    lat = "bbbb",
    bbox = c(-3.8, 40.3, -3.65, 40.5),
    full_results = TRUE,
    sourcecountry = "ES",
    outsr = 102100,
    langcode = "ES",
    custom_query = list(outFields = "LongLabel")
  )

  expect_contains(names(result), c("bbbb", "aaaa", "LongLabel", "Country"))
  expect_false("query" %in% names(result))
  expect_equal(nrow(result), 2)
  expect_identical(result$q_category, c("POI", "Bakery"))
})

test_that("arc_geo_categories() reaches the ArcGIS service", {
  skip_on_cran()
  skip_if_no_api_server()

  result <- arc_geo_categories("POI", x = -3.7242, y = 40.39094)

  expect_s3_class(result, "tbl")
  expect_contains(names(result), c("q_category", "lat", "lon"))
})
