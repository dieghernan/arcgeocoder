arc_geo <- function(address, lat = "lat", long = "lon", limit = 1,
                    full_results = FALSE, return_addresses = TRUE,
                    verbose = FALSE, progressbar = TRUE,
                    custom_query = list()) {
  # Dedupe for query
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  # Set progress bar
  ntot <- length(key)
  # Set progress bar if n > 1
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }
  seql <- seq(1, ntot, 1)

  all_res <- lapply(seql, function(x) {
    ad <- key[x]
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }
    arc_geo_single(
      address = ad,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query
    )
  })
  if (progressbar) close(pb)

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  all_res[all_res == ""] <- NA
  return(all_res)
}



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

  # Keep names in the right order

  result_out <- keep_names(
    result_end, lat, long, return_addresses,
    full_results
  )

  return(result_out)
}
