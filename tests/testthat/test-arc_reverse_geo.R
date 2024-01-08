test_that("Errors", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_error(
    arc_reverse_geo(0, c(2, 3)),
    "lat and long should have the same number"
  )
  expect_error(
    arc_reverse_geo("a", "a"),
    "must be numeric"
  )
})

test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(out <- arc_reverse_geo(0, 200))
  chk <- dplyr::tibble(lat = 0, lon = 180)
  expect_identical(out[, c("lat", "lon")], chk)

  expect_message(out <- arc_reverse_geo(200, 0))
  chk <- dplyr::tibble(lat = 90, lon = 0)
  expect_identical(out[, c("lat", "lon")], chk)
})

test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- arc_reverse_geo(89.999999, 179.9999,
      custom_query =
        list(featureTypes = "StreetInt")
    ),
    "No results for query lon"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$lat == 89.999999)
  expect_true(obj$lon == 179.9999)
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("address", "lat", "lon"))
  expect_true(all(
    vapply(obj, class, FUN.VALUE = character(1))
    == c("character", rep("numeric", 2))
  ))
  expect_true(is.na(obj$address))

  expect_message(
    obj_renamed <- arc_reverse_geo(89.999999, 179.9999,
      address = "adddata",
      custom_query =
        list(featureTypes = "StreetInt")
    ),
    "No results for"
  )

  expect_identical(names(obj_renamed), c("adddata", "lat", "lon"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  obj <- arc_reverse_geo(0, 0)
  expect_s3_class(obj, "tbl")
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- arc_reverse_geo(40.4207414, -3.6687109)
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)

  expect_identical(names(obj), c("address", "lat", "lon"))

  # Same with option
  obj_zoom <- arc_reverse_geo(40.4207414, -3.6687109,
    custom_query = list(featureTypes = "StreetInt")
  )


  expect_s3_class(obj_zoom, "tbl")
  expect_equal(nrow(obj_zoom), 1)
  expect_false(identical(obj, obj_zoom))

  # Several coordinates
  sev <- arc_reverse_geo(
    lat = c(40.75728, 55.95335),
    long = c(-73.98586, -3.188375)
  )

  expect_equal(nrow(sev), 2)
  expect_s3_class(sev, "tbl")

  # Check opts
  obj <- arc_reverse_geo(40.4207414, -3.6687109,
    address = "addrs"
  )

  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)

  expect_identical(names(obj), c("addrs", "lat", "lon"))


  # Check opts
  obj <- arc_reverse_geo(40.4207414, -3.6687109,
    address = "addrs", return_coords = FALSE
  )

  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), "addrs")

  obj <- arc_reverse_geo(40.4207414, -3.6687109,
    address = "addrs", return_coords = FALSE,
    full_results = TRUE
  )

  expect_s3_class(obj, "tbl")
  expect_identical(names(obj)[1:3], c("addrs", "lat", "lon"))
  expect_gt(ncol(obj), 5)

  obj2 <- arc_reverse_geo(40.4207414, -3.6687109,
    address = "addrs", return_coords = TRUE,
    full_results = TRUE
  )

  expect_identical(obj, obj2)
})


test_that("Check unnesting", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()



  # Several coordinates
  sev <- arc_reverse_geo(
    lat = c(40.75728, 55.95335),
    long = c(-73.98586, -3.188375),
    full_results = TRUE
  )

  expect_s3_class(sev, "tbl")
  expect_equal(nrow(sev), 2)


  # Classes of all cols

  colclass <- vapply(sev, class, FUN.VALUE = character(1))

  # Rest of columns not list
  expect_false(any(grepl("list", colclass["boundingbox" != names(colclass)])))
})

test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes

  lats <- rep(c(40.75728, 55.95335), 50)
  longs <- rep(c(-73.98586, -3.188375), 50)

  expect_silent(dup <- arc_reverse_geo(lats, longs, progressbar = FALSE))

  expect_equal(nrow(dup), 100)

  nms <- unique(as.character(dup$address))
  expect_length(nms, 2)
  expect_equal(as.character(dup$address), rep(nms, 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$address), nms)
})

test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  lat <- c(40.75728, 55.95335)
  long <- c(-73.98586, -3.188375)

  # No pbar
  expect_silent(arc_reverse_geo(lat[1], long[1]))
  expect_silent(arc_reverse_geo(lat[1], long[1], progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- arc_reverse_geo(lat, long), "50")

  # Not
  expect_silent(aa <- arc_reverse_geo(lat, long, progressbar = FALSE))
})
