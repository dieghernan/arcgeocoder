arc_geo_single <- function(address,
                           lat = "lat",
                           long = "lon",
                           limit = 1,
                           full_results = TRUE,
                           return_addresses = TRUE,
                           verbose = TRUE,
                           custom_query = list()) {
  # Step 1: Download ----
  api <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer/findAddressCandidates?"
  )

  # Compose url
  url <- paste0(api, "SingleLine=", address, "&f=json&maxLocations=", limit)


  # Add options

  if (isTRUE(full_results)) {
    custom_query$outFields <- "*"
  }

  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))


  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(query = address)


  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = FALSE)

  # Empty query
  if (length(result_init$candidates) == 0) {
    message("No results for query ", address)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Unnest fields
  tbl_query$lat <- NA
  tbl_query$lon <- NA
  result_unn <- unnest_geo(result_init)
  result_end <- dplyr::bind_cols(tbl_query, result_unn)
  result_end$lat <- as.double(result_unn$y)
  result_end$lon <- as.double(result_unn$x)
  return(result_end)

  # Keep names
  result_out <- keep_names_rev(result,
    address = address,
    # Return coords here always FALSE, check that in the top-level query
    return_coords = FALSE,
    full_results = full_results
  )

  return(result_out)
}
