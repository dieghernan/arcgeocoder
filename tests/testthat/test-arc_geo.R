test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- arc_geo("alsksjdhfg 561bata lorem ipsum"),
    "No results for"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "alsksjdhfg 561bata lorem ipsum")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "lat", "lon"))
  expect_true(all(
    vapply(obj, class, FUN.VALUE = character(1)) ==
      c("character", rep("numeric", 2))
  ))
  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))

  expect_message(
    obj_renamed <- arc_geo(
      "alsksjdhfg 561bata lorem ipsum",
      lat = "lata",
      long = "longa"
    ),
    "No results for"
  )

  expect_identical(names(obj_renamed), c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_snapshot(
    out <- arc_geo("Madrid", limit = 200)
  )

  expect_snapshot(out <- arc_geo("Madrid", verbose = TRUE))
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- arc_geo("Madrid")
  expect_s3_class(obj, "tbl")
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(names(obj), c("query", "at", "ong"))

  obj1 <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )
  nobj1 <- ncol(obj1)
  obj2 <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = TRUE
  )
  nobj2 <- ncol(obj2)
  expect_gt(nobj2, nobj1)

  # Try with outfields
  obj3 <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE,
    custom_query = list(outFields = "PlaceName")
  )

  expect_equal(ncol(obj3) - nobj1, 1)
  expect_equal(setdiff(names(obj3), names(obj1)), "PlaceName")

  obj <- arc_geo(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)

  # Boosting with parameters

  query <- arc_geo(
    "Burger King",
    limit = 10,
    full_results = TRUE,
    sourcecountry = "ES"
  )
  expect_gt(nrow(query), 4)

  # Should be in Spain
  expect_true(any(query$Country == "ESP"))

  # And different than
  query2 <- arc_geo("Burger King", limit = 10, full_results = TRUE)

  expect_false(any(query$lon == query2$lon))

  # Select with other outsr
  query3 <- arc_geo(
    "Burger King",
    limit = 10,
    full_results = TRUE,
    outsr = 102100
  )

  expect_false(any(query3$lon == query2$lon))
  expect_true(all(query2$LongLabel == query3$LongLabel))
})


test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes
  expect_silent(
    dup <- arc_geo(
      rep(c("Pentagon", "Barcelona"), 50),
      limit = 1,
      progressbar = FALSE,
      verbose = FALSE
    )
  )

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("Pentagon", "Barcelona"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("Pentagon", "Barcelona"), 1))
})


test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()
  # No pbar
  expect_silent(arc_geo("Madrid"))
  expect_silent(arc_geo("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- arc_geo(c("Madrid", "Barcelona")))

  # Not
  expect_silent(aa <- arc_geo(c("Madrid", "Barcelona"), progressbar = FALSE))
})

test_that("Use categories single", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

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

  expect_equal(out$Type, "Gas Station")

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

  expect_equal(out2$Type, "Restaurant")
})
