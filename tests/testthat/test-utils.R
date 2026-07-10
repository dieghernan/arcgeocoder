test_that("add_custom_query builds and validates custom queries", {
  expect_identical(add_custom_query(list(a = 1, b = 2), "url"), "url&a=1&b=2")
  expect_identical(
    add_custom_query(list(a = c(1, 2), b = 3), "url"),
    "url&a=1,2&b=3"
  )
  expect_identical(add_custom_query(list(), "url"), "url")
  expect_identical(add_custom_query(list(1), "url"), "url")
})

test_that("is_named requires every element to have a valid name", {
  expect_true(is_named(list(a = "f", b = "a")))
  expect_false(is_named(list(a = "f", NULL)))
  expect_false(is_named(list(a = "f", NA)))
  expect_false(is_named(list(a = "f", "b")))
  expect_false(is_named(list("b")))
  expect_false(is_named(list(NULL)))
  expect_false(is_named(list(NA)))
})

test_that("restrict_arc_limit caps values above the API limit", {
  expect_no_message(expect_identical(restrict_arc_limit(50), 50))
  expect_message(
    expect_identical(restrict_arc_limit(51), 50),
    "at most 50 results"
  )
})

test_that("progress helpers handle disabled progress bars", {
  progress <- progress_control(FALSE, 3)

  expect_false(progress$show)
  expect_null(progress$bar)
  expect_identical(progress$seq, 1:3)
  expect_invisible(tick_progress(progress, 1))
  expect_invisible(close_progress(progress))
})

test_that("progress helpers update enabled progress bars", {
  invisible(capture.output({
    progress <- progress_control(TRUE, 2)
    tick_progress(progress, 1)
    close_progress(progress)
  }))

  expect_true(progress$show)
  expect_s3_class(progress$bar, "txtProgressBar")
})

test_that("map_with_progress maps values and indices", {
  result <- map_with_progress(
    c("a", "b"),
    progressbar = FALSE,
    fun = function(value, index) paste0(value, index)
  )

  expect_identical(result, list("a1", "b2"))
  expect_identical(
    map_with_progress(character(), FALSE, function(...) stop("not called")),
    list()
  )
})

test_that("find-address parameters are added consistently", {
  query <- add_find_address_params(
    list(outFields = "Match_addr", untouched = "yes"),
    full_results = TRUE,
    sourcecountry = "ESP",
    outsr = 4326,
    langcode = "es",
    category = "Address"
  )

  expect_identical(
    query,
    list(
      outFields = "*",
      untouched = "yes",
      sourceCountry = "ESP",
      outSR = 4326,
      langCode = "es",
      category = "Address"
    )
  )

  expect_identical(
    add_find_address_params(
      list(outFields = "Match_addr"),
      include_sourcecountry = FALSE
    ),
    list(outFields = "Match_addr")
  )
})

test_that("reverse-geocoding parameters are added consistently", {
  expect_identical(
    add_reverse_params(
      list(untouched = "yes"),
      outsr = 4326,
      langcode = "es",
      featuretypes = "StreetAddress",
      locationtype = "rooftop"
    ),
    list(
      untouched = "yes",
      outSR = 4326,
      langCode = "es",
      featureTypes = "StreetAddress",
      locationType = "rooftop"
    )
  )
})

test_that("coordinate restrictors cap values and report changes", {
  expect_no_message(expect_identical(
    restrict_range(c(1, 2, 3), 0, 3, "changed"),
    c(1, 2, 3)
  ))
  expect_message(
    expect_identical(restrict_range(c(-1, 4), 0, 3, "changed"), c(0, 3)),
    "changed"
  )

  expect_message(
    expect_identical(restrict_lat(c(-91, 91)), c(-90, 90)),
    "Latitudes"
  )
  expect_no_message(expect_identical(restrict_lat(c(-90, 90)), c(-90, 90)))
  expect_message(
    expect_identical(restrict_lon(c(-181, 181)), c(-180, 180)),
    "Longitudes"
  )
  expect_message(
    expect_identical(restrict_bbox_lat(c(-91, 91)), c(-90, 90)),
    "ymin and ymax"
  )
  expect_message(
    expect_identical(restrict_bbox_lon(c(-181, 181)), c(-180, 180)),
    "xmin and xmax"
  )
})

test_that("missing coordinate helpers return typed missing values", {
  expect_no_message(expect_identical(missing_location(), c(NA, NA)))
  expect_message(
    expect_identical(missing_location("No location"), c(NA, NA)),
    "No location"
  )
  expect_no_message(expect_identical(missing_bbox(), rep(NA, 4)))
  expect_message(
    expect_identical(missing_bbox("No bounding box"), rep(NA, 4)),
    "No bounding box"
  )
})

test_that("arc_endpoint_url builds endpoint URLs", {
  expect_identical(
    arc_endpoint_url("findAddressCandidates"),
    paste0(
      "https://geocode.arcgis.com/arcgis/rest/services/",
      "World/GeocodeServer/findAddressCandidates?"
    )
  )
})

test_that("arc_download_file delegates downloads and handles failures", {
  calls <- new.env(parent = emptyenv())
  local_mocked_bindings(download.file = function(url, destfile, quiet, mode) {
    calls$args <- list(url, destfile, quiet, mode)
    0L
  })

  expect_identical(
    arc_download_file("https://example.com/file", "destination"),
    0L
  )
  expect_identical(
    calls$args,
    list("https://example.com/file", "destination", TRUE, "wb")
  )

  local_mocked_bindings(download.file = function(...) {
    warning("Download failed")
  })
  expect_no_warning(expect_false(arc_download_file(
    "https://example.com/file",
    "destination"
  )))

  local_mocked_bindings(download.file = function(...) stop("Download failed"))
  expect_no_error(expect_false(arc_download_file(
    "https://example.com/file",
    "destination"
  )))
})

test_that("message_api_call formats endpoint, parameters and encoded URL", {
  url <- "https://example.com/search?text=Main Street&limit=1"

  expect_snapshot(message_api_call(url))
})

test_that("column helpers select, remove and rename exact names", {
  x <- data.frame(query = 1, lat = 2, latitude = 3, lon = 4)

  expect_named(select_unique_cols(x, c("lat", "lat", "lon")), c("lat", "lon"))
  expect_named(remove_query_col(x), c("lat", "latitude", "lon"))
  expect_named(rename_exact(x, "lat", "y"), c("query", "y", "latitude", "lon"))
})

test_that("empty_strings_to_na handles vectors and tables", {
  expect_identical(
    empty_strings_to_na(c("", "x", NA_character_)),
    c(NA_character_, "x", NA_character_)
  )

  x <- dplyr::tibble(
    character = c("", "x"),
    missing = c(NA_character_, ""),
    numeric = c(1, 2)
  )
  result <- empty_strings_to_na(x)

  expect_s3_class(result, "tbl_df")
  expect_identical(result$character, c(NA_character_, "x"))
  expect_identical(result$missing, c(NA_character_, NA_character_))
  expect_identical(result$numeric, c(1, 2))
})

test_that("arc_geo_bulk combines and joins individual results", {
  local_mocked_bindings(arc_geo_single = function(address, ...) {
    dplyr::tibble(
      query = address,
      lat = 1,
      lon = 2,
      address = if (address == "empty") "" else address
    )
  })

  result <- arc_geo_bulk(
    key = c("first", "empty"),
    init_key = dplyr::tibble(query = c("first", "empty"), id = 1:2),
    lat = "lat",
    long = "lon",
    limit = 1,
    full_results = FALSE,
    return_addresses = TRUE,
    verbose = FALSE,
    custom_query = list(),
    singleline = "address",
    progressbar = FALSE
  )

  expect_identical(result$query, c("first", "empty"))
  expect_identical(result$id, 1:2)
  expect_identical(result$address, c("first", NA_character_))
})

test_that("category helpers normalise values and query metadata", {
  expect_identical(
    category_values(c("Address,Postal", "POI")),
    c("Address", "Postal", "POI")
  )

  result <- category_query_tbl(
    categories = c("Address", "POI"),
    locs = c(1, 2),
    bbox = c(3, 4, 5, 6)
  )
  expect_s3_class(result, "tbl_df")
  expect_identical(result$q_category, c("Address", "POI"))
  expect_named(
    result,
    c(
      "q_category",
      "q_x",
      "q_y",
      "q_bbox_xmin",
      "q_bbox_ymin",
      "q_bbox_xmax",
      "q_bbox_ymax"
    )
  )
})

test_that("category location and bounding-box parameters omit missing values", {
  expect_identical(
    add_category_query_params(list(a = 1), c(2, 3), c(4, 5, 6, 7)),
    list(a = 1, location = "2,3", searchExtent = "4,5,6,7")
  )
  expect_identical(
    add_category_query_params(list(a = 1), c(NA, NA), rep(NA, 4)),
    list(a = 1)
  )
})

test_that("output-column helpers include requested result fields", {
  x <- data.frame(query = 1, lat = 2, lon = 3, address = "a")

  expect_identical(
    geo_output_cols(x, c("query", "lat", "lon"), FALSE, FALSE),
    c("query", "lat", "lon")
  )
  expect_identical(
    geo_output_cols(x, "query", FALSE, TRUE),
    c("query", names(x))
  )
  expect_identical(reverse_output_cols(x, "address", FALSE), "address")
  expect_identical(
    reverse_output_cols(x, "address", TRUE),
    c("address", "lat", "lon", names(x))
  )
})

test_that("multi_row_query omits missing fields", {
  row <- dplyr::tibble(
    address = "Calle Mayor",
    city = NA_character_,
    countryCode = "ESP"
  )
  expect_identical(multi_row_query(row), "address=Calle Mayor&countryCode=ESP")

  empty_row <- dplyr::tibble(address = NA_character_, city = NA_character_)
  expect_identical(multi_row_query(empty_row), NA_character_)
})

test_that("input_multi validates structured address input", {
  expect_snapshot(error = TRUE, input_multi())
  expect_snapshot(error = TRUE, input_multi("a", c("a", "b")))

  result <- input_multi(
    address = c("Calle Mayor", NA),
    city = c("Madrid", "Guanajuato"),
    countrycode = c("ESP", NA)
  )

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("q_address", "q_city", "q_countrycode", "query"))
  expect_identical(result$q_address, c("Calle Mayor", NA_character_))
  expect_identical(result$q_city, c("Madrid", "Guanajuato"))
  expect_identical(result$q_countrycode, c("ESP", NA_character_))
  expect_identical(
    result$query,
    c(
      "address=Calle Mayor&city=Madrid&countryCode=ESP",
      "city=Guanajuato"
    )
  )
})

test_that("unnest_reverse extracts address and location fields", {
  x <- list(
    address = list(LongLabel = "Main Street", City = "Madrid"),
    location = list(
      x = -3.7,
      y = 40.4,
      spatialReference = list(wkid = 4326, latestWkid = 4326)
    )
  )

  result <- unnest_reverse(x)

  expect_s3_class(result, "tbl_df")
  expect_identical(result$lon, -3.7)
  expect_identical(result$lat, 40.4)
  expect_identical(result$address, "Main Street")
  expect_identical(result$City, "Madrid")
  expect_identical(result$wkid, 4326)
  expect_identical(result$latestWkid, 4326)
})

test_that("unnest_geo extracts scalar, nested and spatial-reference fields", {
  x <- jsonlite::fromJSON(
    paste0(
      '{"candidates":[{"address":"Main Street","score":100,',
      '"location":{"x":-3.7,"y":40.4}}],',
      '"spatialReference":{"wkid":4326}}'
    ),
    flatten = FALSE
  )

  result <- unnest_geo(x)

  expect_s3_class(result, "tbl_df")
  expect_identical(result$address, "Main Street")
  expect_identical(result$score, 100L)
  expect_identical(result$x, -3.7)
  expect_identical(result$y, 40.4)
  expect_identical(result$wkid, 4326L)
})

test_that("keep_names selects and renames geocoding output", {
  x <- data.frame(
    query = "Main Street",
    lat = 40.4,
    lon = -3.7,
    address = "Main Street"
  )

  basic <- keep_names(
    x,
    lat = "y",
    lon = "x",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_named(basic, c("query", "y", "x"))

  full <- keep_names(x, full_results = TRUE)
  expect_identical(names(full), names(x))
})

test_that("keep_names_rev selects and renames reverse-geocoding output", {
  x <- data.frame(address = "Main Street", lat = 40.4, lon = -3.7)

  basic <- keep_names_rev(x, address = "result", full_results = FALSE)
  expect_s3_class(basic, "data.frame")
  expect_named(basic, "result")
  expect_identical(basic$result, "Main Street")

  full <- keep_names_rev(x, address = "result", full_results = TRUE)
  expect_named(full, c("result", "lat", "lon"))
})

test_that("empty table helpers create correctly named missing columns", {
  geo <- empty_tbl(data.frame(query = "unknown"), "y", "x")
  expect_named(geo, c("query", "y", "x"))
  expect_type(geo$y, "double")
  expect_identical(
    unname(vapply(geo[c("y", "x")], is.na, FUN.VALUE = logical(1))),
    c(TRUE, TRUE)
  )

  reverse <- empty_tbl_rev(data.frame(query = 1), "result")
  expect_named(reverse, "result")
  expect_true(is.na(reverse$result))
})

test_that("arcurl returns known documentation URLs", {
  expect_identical(
    arcurl("cand"),
    paste0(
      "https://developers.arcgis.com/rest/geocode/api-reference/",
      "geocoding-find-address-candidates.htm"
    )
  )
  expect_identical(
    unname(vapply(c("filt", "out", "rev", "over"), arcurl, character(1))),
    paste0(
      "https://developers.arcgis.com/rest/geocode/api-reference/",
      c(
        "geocoding-category-filtering.htm",
        "geocoding-service-output.htm",
        "geocoding-reverse-geocode.htm",
        "overview-world-geocoding-service.htm"
      )
    )
  )
  expect_identical(
    arcurl("unknown"),
    "https://developers.arcgis.com/rest/geocode/api-reference"
  )
})
