test_that("Errors", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_error(
    arc_geo_multi(),
    "No address component provided"
  )

  expect_error(
    arc_geo_multi("a", c("a", "b")),
    "their lenghts should be the same"
  )

  expect_error(
    arc_geo_multi(NA),
    "No address component provided"
  )

  expect_s3_class(
    out <- arc_geo_multi(
      c(NA, "Plaza Mayor"),
      address2 = c("Guanajuato", NA),
      progressbar = FALSE
    ),
    "tbl"
  )
})


test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_snapshot(
    out <- arc_geo_multi("Madrid", limit = 200)
  )

  expect_snapshot(
    out <- arc_geo_multi(
      address = "Calle Mayor",
      city = "Madrid",
      countrycode = "ESP",
      verbose = TRUE
    )
  )
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- arc_geo_multi("Madrid")
  expect_s3_class(obj, "tbl")
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- arc_geo_multi(
    address = "Calle Mayor",
    city = "Madrid",
    countrycode = "ESP",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(
    names(obj),
    c(
      "q_address",
      "q_city",
      "q_countrycode",
      "query",
      "at",
      "ong"
    )
  )

  obj1 <- arc_geo_multi(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )
  nobj1 <- ncol(obj1)
  obj2 <- arc_geo_multi(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = TRUE
  )
  nobj2 <- ncol(obj2)
  expect_gt(nobj2, nobj1)

  # Try with outfields
  obj3 <- arc_geo_multi(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE,
    custom_query = list(outFields = "PlaceName")
  )

  expect_equal(ncol(obj3) - nobj1, 1)
  expect_equal(setdiff(names(obj3), names(obj1)), "PlaceName")

  obj <- arc_geo_multi(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(
    names(obj)[1:5],
    c(
      "q_address",
      "query",
      "at",
      "ong",
      "address"
    )
  )
  expect_gt(ncol(obj), 4)

  # Boosting with arguments

  query <- arc_geo_multi(
    "Burger King",
    limit = 10,
    full_results = TRUE,
    countrycode = "ES"
  )
  expect_gt(nrow(query), 4)

  # Should be in Spain
  expect_true(any(query$Country == "ESP"))

  # And different than
  query2 <- arc_geo_multi("Burger King", limit = 10, full_results = TRUE)

  expect_false(any(query$lon == query2$lon))

  # Select with other outsr
  query3 <- arc_geo_multi(
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
    dup <- arc_geo_multi(
      rep(c("Pentagon", "Barcelona"), 50),
      limit = 1,
      progressbar = FALSE,
      verbose = FALSE
    )
  )

  expect_equal(nrow(dup), 100)
  expect_equal(
    as.character(dup$query),
    rep(
      c(
        "address=Pentagon",
        "address=Barcelona"
      ),
      50
    )
  )

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(
    as.character(dedup$query),
    rep(
      c(
        "address=Pentagon",
        "address=Barcelona"
      ),
      1
    )
  )
})


test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()
  # No pbar
  expect_silent(arc_geo_multi("Madrid"))
  expect_silent(arc_geo_multi("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- arc_geo_multi(c("Madrid", "Barcelona")))

  # Not
  expect_silent(aa <- arc_geo(c("Madrid", "Barcelona"), progressbar = FALSE))
})

test_that("Use categories multi", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

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

  expect_false(identical(out$Type, out2$Type))
})
