# General ----
add_custom_query <- function(custom_query = list(), url) {
  if (any(length(custom_query) == 0, isFALSE(is_named(custom_query)))) {
    return(url)
  }

  # Collapse vector values into query strings.
  custom_query <- lapply(custom_query, paste0, collapse = ",")

  opts <- paste0(names(custom_query), "=", custom_query, collapse = "&")

  end_url <- paste0(url, "&", opts)

  end_url
}

is_named <- function(x) {
  nm <- names(x)

  test_names <- c(is.null(nm), is.na(nm), !nzchar(nm))

  if (any(test_names)) {
    return(FALSE)
  }

  TRUE
}

restrict_arc_limit <- function(limit) {
  if (limit > 50) {
    message(paste0(
      "\nThe ArcGIS REST API returns at most 50 results per request.",
      " Only the first 50 results will be requested."
    ))
    limit <- min(50, limit)
  }

  limit
}

progress_control <- function(progressbar, total) {
  show_progress <- all(progressbar, total > 1)

  pb <- NULL
  if (show_progress) {
    pb <- txtProgressBar(min = 0, max = total, width = 50, style = 3)
  }

  list(show = show_progress, bar = pb, seq = seq_len(total))
}

tick_progress <- function(progress, value) {
  if (progress$show) {
    setTxtProgressBar(progress$bar, value)
  }
}

close_progress <- function(progress) {
  if (progress$show) {
    close(progress$bar)
  }
}

map_with_progress <- function(x, progressbar, fun) {
  progress <- progress_control(progressbar, length(x))
  on.exit(close_progress(progress), add = TRUE)

  lapply(progress$seq, function(i) {
    tick_progress(progress, i)
    fun(x[[i]], i)
  })
}

add_find_address_params <- function(
  custom_query,
  full_results = FALSE,
  sourcecountry = NULL,
  outsr = NULL,
  langcode = NULL,
  category = NULL,
  include_sourcecountry = TRUE
) {
  if (isTRUE(full_results)) {
    # Override any `outFields` parameter provided in `custom_query`.
    custom_query$outFields <- "*"
  }

  if (include_sourcecountry) {
    custom_query$sourceCountry <- sourcecountry
  }
  custom_query$outSR <- outsr
  custom_query$langCode <- langcode
  custom_query$category <- category

  custom_query
}

add_reverse_params <- function(
  custom_query,
  outsr = NULL,
  langcode = NULL,
  featuretypes = NULL,
  locationtype = NULL
) {
  custom_query$outSR <- outsr
  custom_query$langCode <- langcode
  custom_query$featureTypes <- featuretypes
  custom_query$locationType <- locationtype

  custom_query
}

restrict_range <- function(
  x,
  min_value,
  max_value,
  message_text,
  use_identical = FALSE
) {
  capped <- pmax(pmin(x, max_value), min_value)

  has_changed <- !all(capped == x)
  if (use_identical) {
    has_changed <- !identical(capped, x)
  }

  if (has_changed) {
    message(message_text)
  }

  capped
}

restrict_lat <- function(x) {
  restrict_range(
    x,
    min_value = -90,
    max_value = 90,
    message_text = "\nLatitudes were restricted to [-90, 90].",
    use_identical = TRUE
  )
}

restrict_lon <- function(x) {
  restrict_range(
    x,
    min_value = -180,
    max_value = 180,
    message_text = "\nLongitudes were restricted to [-180, 180]."
  )
}

restrict_bbox_lat <- function(x) {
  restrict_range(
    x,
    min_value = -90,
    max_value = 90,
    message_text = "\n`bbox` ymin and ymax were restricted to [-90, 90]."
  )
}

restrict_bbox_lon <- function(x) {
  restrict_range(
    x,
    min_value = -180,
    max_value = 180,
    message_text = "\n`bbox` xmin and xmax were restricted to [-180, 180]."
  )
}

missing_location <- function(message_text = NULL) {
  if (!is.null(message_text)) {
    message(message_text)
  }

  c(NA, NA)
}

missing_bbox <- function(message_text = NULL) {
  if (!is.null(message_text)) {
    message(message_text)
  }

  c(NA, NA, NA, NA)
}

arc_endpoint_url <- function(endpoint) {
  paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer/",
    endpoint,
    "?"
  )
}

arc_download_file <- function(url, destfile) {
  tryCatch(
    download.file(url, destfile = destfile, quiet = TRUE, mode = "wb"),
    warning = function(e) {
      FALSE
    },
    error = function(e) {
      FALSE
    }
  )
}

message_api_call <- function(url) {
  decomp <- unlist(strsplit(url, "?", fixed = TRUE))
  params <- unlist(strsplit(decomp[2], "&"))
  encoded_url <- URLencode(url)

  message(
    "\nEndpoint: ",
    decomp[1],
    "?\nParameters:\n",
    paste0("   - ", params, collapse = "\n"),
    "\nURL: ",
    encoded_url
  )
}

select_unique_cols <- function(x, cols) {
  x[, unique(cols), drop = FALSE]
}

empty_strings_to_na <- function(x) {
  replace_empty <- function(value) {
    if (is.character(value)) {
      value[!is.na(value) & !nzchar(value)] <- NA_character_
    }
    value
  }

  if (is.data.frame(x)) {
    x[] <- lapply(x, replace_empty)
    return(x)
  }

  x <- replace_empty(x)
  x
}

arc_geo_bulk <- function(
  key,
  init_key,
  lat,
  long,
  limit,
  full_results,
  return_addresses,
  verbose,
  custom_query,
  singleline,
  progressbar
) {
  all_res <- map_with_progress(key, progressbar, function(ad, i) {
    arc_geo_single(
      address = ad,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query,
      singleline = singleline
    )
  })

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  empty_strings_to_na(all_res)
}

category_values <- function(category) {
  unlist(strsplit(paste0(category, collapse = ","), ","))
}

category_query_tbl <- function(categories, locs, bbox) {
  dplyr::tibble(
    q_category = categories,
    q_x = locs[1],
    q_y = locs[2],
    q_bbox_xmin = bbox[1],
    q_bbox_ymin = bbox[2],
    q_bbox_xmax = bbox[3],
    q_bbox_ymax = bbox[4]
  )
}

add_category_query_params <- function(custom_query, locs, bbox) {
  if (!anyNA(locs)) {
    custom_query$location <- paste0(locs, collapse = ",")
  }

  if (!anyNA(bbox)) {
    custom_query$searchExtent <- paste0(bbox, collapse = ",")
  }

  custom_query
}

remove_query_col <- function(x) {
  x[, setdiff(names(x), "query")]
}

rename_exact <- function(x, old, new) {
  names(x) <- gsub(paste0("^", old, "$"), new, names(x))
  x
}

geo_output_cols <- function(
  x,
  colstokeep,
  full_results = TRUE,
  return_addresses = TRUE
) {
  out_cols <- colstokeep

  if (return_addresses || full_results) {
    out_cols <- c(out_cols, names(x))
  }

  out_cols
}

reverse_output_cols <- function(x, colstokeep, full_results = FALSE) {
  out_cols <- colstokeep

  if (full_results) {
    out_cols <- c(out_cols, "lat", "lon", names(x))
  }

  out_cols
}

multi_row_query <- function(row) {
  row <- row[, as.logical(!is.na(row)), drop = FALSE]

  if (ncol(row) == 0) {
    return(NA_character_)
  }

  row <- as.list(row)
  paste0(names(row), "=", row, collapse = "&")
}

# Specific ----
unnest_reverse <- function(x) {
  x_add <- x$address
  lngths <- lengths(x_add)
  endobj <- dplyr::as_tibble(x_add[lngths == 1])

  x_loc <- x$location
  lngths_loc <- lengths(x_loc)
  endobj_loc <- dplyr::as_tibble(x_loc[lngths_loc == 1])
  names(endobj_loc) <- c("lon", "lat")

  # Use ArcGIS address label when available.
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
  # Extract candidates.
  x_cand <- x$candidates

  maybe_df <- vapply(x_cand, is.data.frame, FUN.VALUE = logical(1))
  # Extract scalar candidate fields first.
  endobj <- dplyr::as_tibble(x_cand[!maybe_df])

  unnes <- maybe_df[maybe_df]

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

keep_names_rev <- function(
  x,
  address = "address",
  full_results = FALSE,
  colstokeep = address
) {
  names(x) <- gsub("address", address, names(x), fixed = TRUE)

  out_cols <- reverse_output_cols(x, colstokeep, full_results)
  out <- select_unique_cols(x, out_cols)

  out
}

keep_names <- function(
  x,
  lat = "lat",
  lon = "lon",
  full_results = TRUE,
  return_addresses = TRUE,
  colstokeep = c("query", lat, lon)
) {
  x <- rename_exact(x, "lon", lon)
  x <- rename_exact(x, "lat", lat)

  out_cols <- geo_output_cols(x, colstokeep, full_results, return_addresses)
  out <- select_unique_cols(x, out_cols)

  out
}

empty_tbl_rev <- function(x, address) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$n <- as.character(NA)

  names(x) <- c(init_nm, address)

  # Keep only the address column.
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

# Generate URLs for documentation.
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
