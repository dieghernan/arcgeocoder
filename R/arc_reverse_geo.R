#' Reverse Geocoding using the ArcGIS REST API
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be
#' between `[-90, 90]` and longitudes between `[-180, 180]`. This
#' function returns the \CRANpkg{tibble} associated with the query.
#'
#' @param x longitude values in numeric format. Must be in the range
#'   `[-180, 180]`.
#' @param y  latitude values in numeric format. Must be in the range
#'   `[-90, 90]`.
#' @param address address column name in the output data (default  `"address"`).
#' @param full_results returns all available data from the API service. If
#'   `FALSE` (default) only latitude, longitude and address columns are
#'   returned.
#' @param return_coords	return input coordinates with results if `TRUE`.
#' @param verbose if `TRUE` then detailed logs are output to the console.
#' @param progressbar Logical. If `TRUE` displays a progress bar to indicate
#'  the progress of the function.
#' @param outsr The spatial reference of the `x,y` coordinates returned by a
#'   geocode request. By default is `NULL` (i.e. the parameter won't be used in
#'   the query). See **Details** and [arc_spatial_references].
#' @param langcode Sets the language in which reverse-geocoded addresses are
#'   returned.
#' @param featuretypes This parameter limits the possible match types returned.
#'   By default is `NULL` (i.e. the parameter won't be used in the query).
#'   See **Details**.
#' @param locationtype Specifies whether the output geometry of
#' `featuretypes = "PointAddress"` or `featuretypes = "Subaddress"` matches
#'   should be the rooftop point or street entrance location. Valid values are
#'   `NULL` (i.e. not using the parameter in the query), `rooftop` and `street`.
#' @param custom_query API-specific parameters to be used, passed as a named
#'   list.
#'
#'
#'
#' @references
#' [ArcGIS REST
#' `reverseGeocode`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm)
#'
#' @details
#'
#' More info and valid values in the [ArcGIS REST
#' docs](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm)
#'
#' # `outsr`
#'
#' The spatial reference can be specified as either a well-known ID (WKID). If
#' not specified, the spatial reference of the output locations is the same as
#' that of the service ( WGS84, i.e. WKID = 4326)).
#'
#' See [arc_spatial_references] for values and examples.
#'
#' # `featuretypes`
#'
#' See `vignette("featuretypes", package = "arcgeocoder")` for a detailed
#' explanation of this parameter.
#'
#' This parameter may be used for filtering the type of feature to be returned
#' when geocoding. Possible values are:
#'
#' -   `"StreetInt"`
#' -   `"DistanceMarker"`
#' -   `"StreetAddress"`
#' -   `"StreetName"`
#' -   `"POI"`
#' -   `"Subaddress"`
#' -   `"PointAddress"`
#' -   `"Postal"`
#' -   `"Locality"`
#'
#' It is also possible to use several values separated by comma
#' (`featuretypes="PointAddress,StreetAddress"`).
#'
#' @return A \CRANpkg{tibble} with the corresponding results. The `x,y` values
#' returned by the API would be named `lon,lat`. Note that these coordinates
#' correspond to the geocoded feature, and may be different of the `x,y` values
#' provided as inputs.
#'
#' See the details of the output in [ArcGIS REST API Service
#' output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm)
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#'
#' arc_reverse_geo(x = -73.98586, y = 40.75728)
#'
#' # Several coordinates
#' arc_reverse_geo(x = c(-73.98586, -3.188375), y = c(40.75728, 55.95335))
#'
#' # With options: using some additional parameters
#' sev <- arc_reverse_geo(
#'   x = c(-73.98586, -3.188375),
#'   y = c(40.75728, 55.95335),
#'   # Restrict to these feautures
#'   featuretypes = "POI,StreetInt",
#'   # Result on this WKID
#'   outsr = 102100,
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
#'
#' @export
#'
#' @family geocoding
#' @seealso [tidygeocoder::reverse_geo()]
#'
arc_reverse_geo <- function(x, y, address = "address", full_results = FALSE,
                            return_coords = TRUE, verbose = FALSE,
                            progressbar = TRUE, outsr = NULL, langcode = NULL,
                            featuretypes = NULL, locationtype = NULL,
                            custom_query = list()) {
  # Check inputs
  if (!is.numeric(x) || !is.numeric(y)) {
    stop("x and y must be numeric")
  }

  if (length(x) != length(y)) {
    stop("x and y should have the same number of elements")
  }


  # Lat
  y_cap <- pmax(pmin(y, 90), -90)

  if (!identical(y_cap, y)) {
    message("\nlatitudes have been restricted to [-90, 90]")
  }

  # Lon
  x_cap <- pmax(pmin(x, 180), -180)

  if (!all(x_cap == x)) {
    message("\nlongitudes have been restricted to [-180, 180]")
  }

  # Dedupe for query using data frame
  init_key <- dplyr::tibble(
    x_key_int = x, y_key_int = y,
    y_cap_int = y_cap, x_cap_int = x_cap
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


  # Add additional parameters to the custom query

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
  if (progressbar) close(pb)

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key[, c(1, 2)], all_res,
    by = c("x_key_int", "y_key_int")
  )

  # # Final clean
  nm <- names(all_res)
  nm <- gsub("x_key_int", "x", nm)
  nm <- gsub("y_key_int", "y", nm)
  names(all_res) <- nm

  if (isFALSE(return_coords)) {
    all_res <- all_res[, !nm %in% c("x", "y")]
  }

  all_res[all_res == ""] <- NA
  return(all_res)
}

arc_reverse_geo_single <- function(lat_cap,
                                   long_cap,
                                   address = "address",
                                   full_results = FALSE,
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
    message("\n", url, " not reachable.")
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Empty query
  if ("error" %in% names(result_init)) {
    message(
      "\n",
      "No results for location=", long_cap, ",", lat_cap, "\n",
      result_init$error$message, "\nDetails: ", result_init$error$details
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
    full_results = full_results
  )

  return(result_out)
}
