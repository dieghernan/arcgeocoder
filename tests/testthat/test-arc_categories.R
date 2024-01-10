test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_snapshot(
    out <- arc_categories(verbose = TRUE)
  )
})

test_that("Use test single", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_snapshot(
    out <- arc_geo("",
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
    out2 <- arc_geo("",
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


test_that("Use test multi", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_snapshot(
    out <- arc_geo_multi(
      address = "Atocha", city = "Madrid", countrycode = "ESP",
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
      address = "Atocha", city = "Madrid", countrycode = "ESP",
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
