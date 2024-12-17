# General ----
add_custom_query <- function(custom_query = list(), url) {
  if (any(length(custom_query) == 0, isFALSE(is_named(custom_query)))) {
    return(url)
  }

  # Collapse
  custom_query <- lapply(custom_query, paste0, collapse = ",")


  opts <- paste0(names(custom_query), "=", custom_query, collapse = "&")

  end_url <- paste0(url, "&", opts)

  end_url
}

is_named <- function(x) {
  nm <- names(x)

  test_names <- c(is.null(nm), is.na(nm), nm == "")

  if (any(test_names)) {
    return(FALSE)
  }

  TRUE
}

# Specific ----
unnest_reverse <- function(x) {
  x_add <- x$address
  lngths <- vapply(x_add, length, FUN.VALUE = numeric(1))
  endobj <- dplyr::as_tibble(x_add[lngths == 1])

  x_loc <- x$location
  lngths_loc <- vapply(x_loc, length, FUN.VALUE = numeric(1))
  endobj_loc <- dplyr::as_tibble(x_loc[lngths_loc == 1])
  names(endobj_loc) <- c("lon", "lat")

  # ArcGIS address
  if ("LongLabel" %in% names(lngths)) {
    ad <- dplyr::as_tibble(x_add$LongLabel)[1, ]
    names(ad) <- "address"
    endobj_loc <- dplyr::bind_cols(endobj_loc, ad)
  }

  endobj_loc <- dplyr::bind_cols(endobj_loc, endobj)

  if ("spatialReference" %in% names(lngths_loc)) {
    bb <- dplyr::as_tibble(x_loc$spatialReference)
    endobj_loc <- dplyr::bind_cols(endobj_loc, bb)
  }

  endobj_loc
}


unnest_geo <- function(x) {
  # Candidates
  x_cand <- x$candidates

  maybe_df <- vapply(x_cand, is.data.frame, FUN.VALUE = logical(1))
  # Extract first those that are not
  endobj <- dplyr::as_tibble(x_cand[maybe_df == FALSE])

  unnes <- maybe_df[maybe_df == TRUE]

  df_list <- lapply(names(unnes), function(y) {
    x_cand[, y]
  })

  unnested <- dplyr::bind_cols(df_list)
  endobj <- dplyr::bind_cols(endobj, unnested)


  if ("spatialReference" %in% names(x)) {
    bb <- dplyr::as_tibble(x$spatialReference)
    endobj <- dplyr::bind_cols(endobj, bb)
  }


  endobj
}

keep_names_rev <- function(x, address = "address",
                           full_results = FALSE,
                           colstokeep = address) {
  names(x) <- gsub("address", address, names(x))

  out_cols <- colstokeep
  if (full_results) out_cols <- c(out_cols, "lat", "lon", names(x))

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  out
}

keep_names <- function(x, lat = "lat", lon = "lon",
                       full_results = TRUE,
                       return_addresses = TRUE,
                       colstokeep = c("query", lat, lon)) {
  names(x) <- gsub("^lon$", lon, names(x))
  names(x) <- gsub("^lat$", lat, names(x))

  out_cols <- colstokeep
  out_cols <- c(out_cols, names(x))

  if (!return_addresses) out_cols <- colstokeep
  if (full_results) out_cols <- c(out_cols, names(x))

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  out
}

empty_tbl_rev <- function(x, address) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$n <- as.character(NA)

  names(x) <- c(init_nm, address)

  # Reorder and get only address
  x <- x[, address]

  x
}

empty_tbl <- function(x, lat, lon) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$lat <- as.double(NA)
  x$lon <- x$lat

  names(x) <- c(init_nm, lat, lon)

  x
}

# Helper for url in docs
arcurl <- function(x) {
  base <- "https://developers.arcgis.com/rest/geocode/api-reference"

  entry <- switch(x,
    "filt" = "geocoding-category-filtering.htm",
    "out" = "geocoding-service-output.htm",
    "cand" = "geocoding-find-address-candidates.htm",
    "rev" = "geocoding-reverse-geocode.htm",
    "over" = "overview-world-geocoding-service.htm",
    NULL
  )

  paste0(c(base, entry), collapse = "/")
}
