#' Reverse Geocoding using the ArcGIS REST API
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be
#' between `[-90, 90]` and longitudes between `[-180, 180]`. This
#' function returns the \CRANpkg{tibble} associated with the query.
#'
#' @param lat  latitude values in numeric format. Must be in the range
#'   `[-90, 90]`.
#' @param long  longitude values in numeric format. Must be in the range
#'   `[-180, 180]`.
#' @param address address column name in the output data (default  `"address"`).
#' @param full_results returns all available data from the API service. If
#'   `FALSE` (default) only latitude, longitude and address columns are
#'   returned.
#' @param return_coords	return input coordinates with results if `TRUE`.
#' @param verbose if `TRUE` then detailed logs are output to the console.
#' @param progressbar Logical. If `TRUE` displays a progress bar to indicate
#'  the progress of the function.
#' @param custom_query API-specific parameters to be used, passed as a named
#'   list (i.e. `list(featureTypes = "POI")`). See **Details**.
#'
#'
#' @details
#' See <https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm>
#' for additional parameters to be passed to `custom_query`.
#'
#' @return A \CRANpkg{tibble} with the results.
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#'
#' arc_reverse_geo(lat = 40.75728, long = -73.98586)
#'
#' # Several coordinates
#' arc_reverse_geo(lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375))
#'
#' # With options: zoom to country level
#' sev <- arc_reverse_geo(
#'   lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375),
#'   custom_query = list(featureTypes = "StreetInt,POI", langCode = "FR"),
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
#'
#' @export
#'
#' @seealso [tidygeocoder::reverse_geo()]
#'
arc_reverse_geo <- function(lat,
                            long,
                            address = "address",
                            full_results = FALSE,
                            return_coords = TRUE,
                            verbose = FALSE,
                            progressbar = TRUE,
                            custom_query = list()) {
  # Check inputs
  if (!is.numeric(lat) || !is.numeric(long)) {
    stop("lat and long must be numeric")
  }

  if (length(lat) != length(long)) {
    stop("lat and long should have the same number of elements")
  }

  # Lat
  lat_cap <- pmax(pmin(lat, 90), -90)

  if (!identical(lat_cap, lat)) {
    message("latitudes have been restricted to [-90, 90]")
  }

  # Lon
  long_cap <- pmax(pmin(long, 180), -180)

  if (!all(long_cap == long)) {
    message("longitudes have been restricted to [-180, 180]")
  }


  # Dedupe for query using data frame

  init_key <- dplyr::tibble(
    lat_key_int = lat, long_key_int = long,
    lat_cap_int = lat_cap, long_cap_int = long_cap
  )
  key <- dplyr::distinct(init_key)

  # Set progress bar
  ntot <- nrow(key)
  # Set progress bar if n > 1
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }

  seql <- seq(1, ntot, 1)


  all_res <- lapply(seql, function(x) {
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }
    rw <- key[x, ]
    res_single <- arc_reverse_geo_single(
      as.double(rw$lat_cap_int),
      as.double(rw$long_cap_int),
      address,
      full_results,
      return_coords,
      verbose,
      custom_query
    )

    res_single <- dplyr::bind_cols(res_single, rw[, c(1, 2)])

    res_single
  })
  if (progressbar) close(pb)

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key[, c(1, 2)], all_res,
    by = c("lat_key_int", "long_key_int")
  )

  # Final clean
  all_res <- all_res[, -c(1, 2)]
  return(all_res)
}

arc_reverse_geo_single <- function(lat_cap,
                                   long_cap,
                                   address = "address",
                                   full_results = FALSE,
                                   return_coords = TRUE,
                                   verbose = TRUE,
                                   custom_query = list()) {
  # Step 1: Download ----
  api <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer/reverseGeocode?"
  )

  # Compose url
  url <- paste0(api, "location=", long_cap, ",", lat_cap, "&f=json")


  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))



  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)


  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Empty query
  if ("error" %in% names(result_init)) {
    message(
      "No results for query lon=",
      long_cap, ", lat=", lat_cap,
      "\n", result_init$error$message, "\nDetails: ", result_init$error$details
    )
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }



  # Unnest fields
  result <- unnest_reverse(result_init)

  result$lat <- as.double(result$lat)
  result$lon <- as.double(result$lon)

  # Keep names
  result_out <- keep_names_rev(result,
    address = address,
    return_coords = return_coords,
    full_results = full_results
  )

  return(result_out)
}
