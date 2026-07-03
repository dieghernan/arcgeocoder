#' Reverse geocode coordinates with the ArcGIS REST API
#'
#' @description
#' Converts longitude and latitude values into addresses. Latitudes must be in
#' the range \eqn{\left[-90, 90 \right]} and longitudes in the range
#' \eqn{\left[-180, 180 \right]}. Returns one match for each coordinate pair.
#'
#' @param x A numeric vector of longitude values in the range
#'   \eqn{\left[-180, 180 \right]}.
#' @param y A numeric vector of latitude values in the range
#'   \eqn{\left[-90, 90 \right]}.
#' @param address Name of the address column in the output. The default is
#'   `"address"`.
#' @param full_results A logical value indicating whether to return all
#'   available API fields. The default, `FALSE`, returns only latitude,
#'   longitude and address.
#' @param return_coords A logical value indicating whether to return the input
#'   coordinates with the results.
#' @param verbose A logical value indicating whether to display API request
#'   details.
#' @param progressbar A logical value indicating whether to display a progress
#'   bar for multiple queries.
#' @param outsr Spatial reference of the output coordinates. The default is
#'   `NULL`, which uses the service default. See **Details** and
#'   [arc_spatial_references].
#' @param langcode Language of the returned addresses.
#' @param featuretypes A character vector that limits the possible match types.
#'   The default is `NULL`, which does not filter by feature type. See
#'   **Details**.
#' @param locationtype Location represented by the output geometry when
#'   `featuretypes` is `"PointAddress"` or `"Subaddress"`. Valid values are
#'   `"rooftop"` and `"street"`. The default is `NULL`.
#' @param custom_query A named list with additional API parameters.
#'
#' @details
#' See the [ArcGIS REST API documentation](`r arcurl("rev")`) for more
#' information and valid values.
#'
#' # `outsr`
#'
#' The spatial reference can be specified as a well-known ID (WKID). If not
#' specified, the spatial reference of the output locations is the same as that
#' of the service (WGS 84, that is, WKID 4326).
#'
#' See [arc_spatial_references] for values and examples.
#'
#' # `featuretypes`
#'
#' See `vignette("feature-types", package = "arcgeocoder")` for a detailed
#' explanation of this argument.
#'
#' This argument restricts the feature types returned by a reverse geocoding
#' request. Possible values are `"StreetInt"`, `"DistanceMarker"`,
#' `"StreetAddress"`, `"StreetName"`, `"POI"`, `"Subaddress"`,
#' `"PointAddress"`, `"Postal"` and `"Locality"`.
#'
#' Supply multiple values as a character vector, for example,
#' `c("PointAddress", "StreetAddress")`.
#'
#' @returns
#' A [tibble][dplyr::tibble] with one match for each coordinate pair. The API
#' output fields `x` and `y` are named `lon` and `lat`. These coordinates
#' correspond to the matched feature and may differ from the input `x` and `y`
#' values.
#'
#' See [ArcGIS REST API output](`r arcurl("out")`) for field details.
#'
#' @references
#' [ArcGIS REST API `reverseGeocode`](`r arcurl("rev")`).
#'
#' @family geocoders
#'
#' @export
#' @encoding UTF-8
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' arc_reverse_geo(x = -73.98586, y = 40.75728)
#'
#' # Several coordinate pairs.
#' arc_reverse_geo(x = c(-73.98586, -3.188375), y = c(40.75728, 55.95335))
#'
#' # Use additional API options.
#' sev <- arc_reverse_geo(
#'   x = c(-73.98586, -3.188375),
#'   y = c(40.75728, 55.95335),
#'   # Restrict results to specific feature types.
#'   featuretypes = "POI,StreetInt",
#'   # Return results in this WKID.
#'   outsr = 102100,
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
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
    stop("`x` and `y` must be numeric.")
  }

  if (length(x) != length(y)) {
    stop("`x` and `y` must have the same number of elements.")
  }

  y_cap <- restrict_lat(y)
  x_cap <- restrict_lon(x)

  # Deduplicate coordinates before querying.
  init_key <- dplyr::tibble(
    x_key_int = x,
    y_key_int = y,
    y_cap_int = y_cap,
    x_cap_int = x_cap
  )

  key <- dplyr::distinct(init_key)

  # Add API arguments to the custom query.
  custom_query <- add_reverse_params(
    custom_query,
    outsr = outsr,
    langcode = langcode,
    featuretypes = featuretypes,
    locationtype = locationtype
  )

  all_res <- map_with_progress(seq_len(nrow(key)), progressbar, function(x, i) {
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

  empty_strings_to_na(all_res)
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
  api <- arc_endpoint_url("reverseGeocode")

  # Compose URL.
  url <- paste0(api, "location=", long_cap, ",", lat_cap, "&f=json")

  # Add options.
  url <- add_custom_query(custom_query, url)

  # Download to a temporary file.
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)

  if (isFALSE(res)) {
    message("\nUnable to reach URL: ", url)
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Handle empty queries.
  if ("error" %in% names(result_init)) {
    message(
      "\n",
      "No results found for location: ",
      long_cap,
      ", ",
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
