# General ----
add_custom_query <- function(custom_query = list(), url) {
  if (any(length(custom_query) == 0, isFALSE(is_named(custom_query)))) {
    return(url)
  }

  opts <- paste0(names(custom_query), "=", custom_query, collapse = "&")

  end_url <- paste0(url, "&", opts)

  end_url
}

is_named <- function(x) {
  nm <- names(x)

  if (is.null(nm)) {
    return(FALSE)
  }
  if (any(is.na(nm))) {
    return(FALSE)
  }
  if (any(nm == "")) {
    return(FALSE)
  }

  return(TRUE)
}

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
  return(endobj_loc)
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


  return(endobj)
}

keep_names_rev <- function(x, address = "address", return_coords = FALSE,
                           full_results = FALSE,
                           colstokeep = address) {
  names(x) <- gsub("address", address, names(x))

  out_cols <- colstokeep
  if (return_coords) out_cols <- c(out_cols, "lat", "lon")
  if (full_results) out_cols <- c(out_cols, "lat", "lon", names(x))

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  return(out)
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
