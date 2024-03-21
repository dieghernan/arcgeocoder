test_that("Errors", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_error(
    arc_geo_categories("Food"),
    "valid combination of x,y parameters or a valid bbox"
  )
  expect_error(
    arc_geo_categories("Food", "a", "a"),
    "must be numeric"
  )
  expect_error(
    arc_geo_categories("Food", 0, 0, address = "Error")
  )

  expect_error(
    arc_geo_categories("Food", 0, 0, progressbar = TRUE)
  )
  expect_error(
    arc_geo_categories("Food", 0, 0, return_addresses = TRUE)
  )
})

test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(
    out <- arc_geo_categories("POI", 200, 0),
    "longitudes have been restricted"
  )
  expect_message(
    out <- arc_geo_categories(
      "Address,Postal,Coordinate System,POI",
      0, 200
    ),
    "latitudes have been restricted"
  )


  expect_snapshot(
    out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, verbose = TRUE)
  )

  expect_message(
    out <- arc_geo_categories("POI",
      x = 3.7242,
      bbox = c(-3.8, 40.3, -3.65, 40.5)
    ),
    "Either x or y are missing"
  )

  expect_message(
    out <- arc_geo_categories("POI",
      y = 3.7242,
      bbox = c(-3.8, 40.3, -3.65, 40.5)
    ),
    "Either x or y are missing"
  )
})

test_that("Messages bbox", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()



  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = "uno",
      verbose = TRUE
    )
  )


  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = c("uno", NA),
      verbose = TRUE
    )
  )

  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = LETTERS[1:4],
      verbose = TRUE
    )
  )

  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = c(-200, -89, 200, 89),
      verbose = TRUE
    )
  )

  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = c(-200, -89, 200, 89),
      verbose = TRUE
    )
  )

  expect_snapshot(
    out <- arc_geo_categories("POI",
      x = -3.7242, y = 40.39094,
      bbox = c(-100, -95, 100, 95),
      verbose = TRUE
    )
  )
})

test_that("Test with all params", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()



  expect_snapshot(
    out <- arc_geo_categories("POI,Address",
      x = -3.7242, y = 40.39094,
      name = "Bar",
      limit = 20,
      lon = "aaaa",
      lat = "bbbb",
      bbox = c(-3.8, 40.3, -3.65, 40.5),
      sourcecountry = "ES",
      verbose = TRUE,
      outsr = 102100,
      langcode = "ES",
      custom_query = list(
        outFields = "LongLabel"
      )
    )
  )

  expect_true("bbbb" %in% names(out))
  expect_true("aaaa" %in% names(out))
  expect_true("LongLabel" %in% names(out))
  expect_false("query" %in% names(out))
  expect_false(any(grepl("Country", names(out))))

  # Full results
  out2 <- arc_geo_categories("POI,Bakery",
    x = -3.7242, y = 40.39094,
    limit = 2,
    lon = "aaaa",
    lat = "bbbb",
    bbox = c(-3.8, 40.3, -3.65, 40.5),
    full_results = TRUE,
    sourcecountry = "ES",
    outsr = 102100,
    langcode = "ES",
    custom_query = list(
      outFields = "LongLabel"
    )
  )

  expect_true("bbbb" %in% names(out2))
  expect_true("aaaa" %in% names(out2))
  expect_true("LongLabel" %in% names(out2))
  expect_false("query" %in% names(out))
  expect_true(any(grepl("Country", names(out2))))
  expect_gt(ncol(out2), ncol(out))
  # Vectorized
  expect_gt(nrow(out2), 2)
})
