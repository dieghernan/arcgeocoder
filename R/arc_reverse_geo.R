#' Reverse geocoding using the ArcGIS REST API
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be in the
#' range \eqn{\left[-90, 90 \right]} and longitudes in the range
#' \eqn{\left[-180, 180 \right]}. This function returns the
#' [tibble][tibble::tbl_df] associated with the query.
#'
#' @param x Longitude values in numeric format. Must be in the range
#'   \eqn{\left[-180, 180 \right]}.
#' @param y Latitude values in numeric format. Must be in the range
#'   \eqn{\left[-90, 90 \right]}.
#' @param address Output address column name (default `"address"`).
#' @param full_results Logical. If `TRUE`, return all available API fields.
#'   `FALSE` (default) returns latitude, longitude and address only.
#' @param return_coords Logical. If `TRUE`, return input coordinates with
#'   results.
#' @param verbose Logical. If `TRUE`, output process messages to the console.
#' @param progressbar Logical. If `TRUE`, show a progress bar for multiple
#'   points.
#' @param outsr The spatial reference of the `x` and `y` coordinates returned
#'   by a geocode request. By default, it is `NULL` (i.e. the argument will not
#'   be used in the query). See **Details** and [arc_spatial_references].
#' @param langcode Sets the language in which reverse-geocoded addresses are
#'   returned.
#' @param featuretypes This argument limits the possible match types returned.
#'   By default, it is `NULL` (i.e. the argument will not be used in the query).
#'   See **Details**.
#' @param locationtype Specifies whether the output geometry of
#'   `featuretypes = "PointAddress"` or `featuretypes = "Subaddress"` matches
#'   should be the rooftop point or street entrance location. Valid values are
#'   `NULL` (i.e. not using the argument in the query), `rooftop` and `street`.
#' @param custom_query API-specific arguments to be used, passed as a named
#'   list.
#'
#' @references
#' [ArcGIS REST `reverseGeocode`](`r arcurl("rev")`).
#'
#' @details
#'
#' See the [ArcGIS REST docs](`r arcurl("rev")`) for more information and
#' valid values.
#'
#' # `outsr`
#'
#' The spatial reference can be specified as a well-known ID (WKID). If not
#' specified, the spatial reference of the output locations is the same as that
#' of the service (WGS84, i.e. WKID = 4326).
#'
#' See [arc_spatial_references] for values and examples.
#'
#' # `featuretypes`
#'
#' See `vignette("featuretypes", package = "arcgeocoder")` for a detailed
#' explanation of this argument.
#'
#' This argument may be used to filter the type of feature returned when
#' geocoding. Possible values are:
#'
#' - `"StreetInt"`
#' - `"DistanceMarker"`
#' - `"StreetAddress"`
#' - `"StreetName"`
#' - `"POI"`
#' - `"Subaddress"`
#' - `"PointAddress"`
#' - `"Postal"`
#' - `"Locality"`
#'
#' It is also possible to use several values as a vector
#' (`featuretypes = c("PointAddress", "StreetAddress")`).
#'
#' @return
#' A [tibble][tibble::tbl_df] with the corresponding results. The `x` and `y`
#' values returned by the API are named `lon` and `lat`. Note that these
#' coordinates correspond to the geocoded feature and may differ from the `x`
#' and `y` values provided as inputs.
#'
#' See the details of the output in
#' [ArcGIS REST API service output](`r arcurl("out")`).
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#'
#' arc_reverse_geo(x = -73.98586, y = 40.75728)
#'
#' # Several coordinates.
#' arc_reverse_geo(x = c(-73.98586, -3.188375), y = c(40.75728, 55.95335))
#'
#' # With options: use additional arguments.
#' sev <- arc_reverse_geo(
#'   x = c(-73.98586, -3.188375),
#'   y = c(40.75728, 55.95335),
#'   # Restrict to these features.
#'   featuretypes = "POI,StreetInt",
#'   # Return results in this WKID.
#'   outsr = 102100,
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
#'
#' @export
#' @encoding UTF-8
#'
#' @family geocoding
#' @seealso [tidygeocoder::reverse_geo()]
#'
arc_reverse_geo <- function(
  x,
  y,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  progressbar = TRUE,
  outsr = NULL,
  langcode = NULL,
  featuretypes = NULL,
  locationtype = NULL,
  custom_query = list()
) {
  # Check inputs.
  if (!is.numeric(x) || !is.numeric(y)) {
    stop("x and y must be numeric")
  }

  if (length(x) != length(y)) {
    stop("x and y must have the same number of elements")
  }

  # Lat
  y_cap <- pmax(pmin(y, 90), -90)

  if (!identical(y_cap, y)) {
    message("\nLatitudes have been restricted to [-90, 90]")
  }

  # Lon
  x_cap <- pmax(pmin(x, 180), -180)

  if (!all(x_cap == x)) {
    message("\nLongitudes have been restricted to [-180, 180]")
  }

  # Deduplicate coordinates before querying.
  init_key <- dplyr::tibble(
    x_key_int = x,
    y_key_int = y,
    y_cap_int = y_cap,
    x_cap_int = x_cap
  )

  key <- dplyr::distinct(init_key)

  # Set progress bar.
  ntot <- nrow(key)
  # Show progress bar only for multiple coordinates.
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }

  seql <- seq(1, ntot, 1)

  # Add API arguments to the custom query.

  custom_query$outSR <- outsr
  custom_query$langCode <- langcode
  custom_query$featureTypes <- featuretypes
  custom_query$locationType <- locationtype

  all_res <- lapply(seql, function(x) {
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }
    rw <- key[x, ]
    res_single <- arc_reverse_geo_single(
      as.double(rw$y_cap_int),
      as.double(rw$x_cap_int),
      address,
      full_results,
      verbose,
      custom_query
    )

    res_single <- dplyr::bind_cols(res_single, rw[, c(1, 2)])

    res_single
  })
  if (progressbar) {
    close(pb)
  }

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(
    init_key[, c(1, 2)],
    all_res,
    by = c("x_key_int", "y_key_int")
  )

  # Clean final names.
  nm <- names(all_res)
  nm <- gsub("x_key_int", "x", nm, fixed = TRUE)
  nm <- gsub("y_key_int", "y", nm, fixed = TRUE)
  names(all_res) <- nm

  if (isFALSE(return_coords)) {
    all_res <- all_res[, !nm %in% c("x", "y")]
  }

  all_res[all_res == ""] <- NA
  all_res
}

arc_reverse_geo_single <- function(
  lat_cap,
  long_cap,
  address = "address",
  full_results = FALSE,
  verbose = TRUE,
  custom_query = list()
) {
  # Step 1: Download ----
  api <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer/reverseGeocode?"
  )

  # Compose URL.
  url <- paste0(api, "location=", long_cap, ",", lat_cap, "&f=json")

  # Add options.
  url <- add_custom_query(custom_query, url)

  # Download to a temporary file.
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)

  # nocov start
  if (isFALSE(res)) {
    message("\n", url, " is not reachable.")
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Handle empty queries.
  if ("error" %in% names(result_init)) {
    message(
      "\n",
      "No results for location=",
      long_cap,
      ",",
      lat_cap,
      "\n",
      result_init$error$message,
      "\nDetails: ",
      result_init$error$details
    )
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }

  # Unnest fields.
  result <- unnest_reverse(result_init)

  result$lat <- as.double(result$lat)
  result$lon <- as.double(result$lon)

  # Keep requested names.
  result_out <- keep_names_rev(
    result,
    address = address,
    full_results = full_results
  )

  result_out
}
