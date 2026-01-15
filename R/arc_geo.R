#' Geocoding using the ArcGIS REST API
#'
#' @description
#' Geocodes addresses given as character values. This function returns the
#' [tibble][tibble::tbl_df] object associated with the query.
#'
#' This function uses the `SingleLine` approach detailed in the
#' [ArcGIS REST docs](`r arcurl("cand")`). For multi-field queries (i.e.
#' using specific address arguments) use [arc_geo_multi()] function.
#'
#' @param address character with single line address
#'   (`"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
#'   (`c("Madrid", "Barcelona")`).
#' @param lat	latitude column name in the output data (default  `"lat"`).
#' @param long	longitude column name in the output data (default  `"lon"`).
#' @param limit	maximum number of results to return per input address. Note
#'   that each query returns a maximum of 50 results.
#' @param full_results returns all available data from the API service. This
#'   is a shorthand of `outFields=*`. See **References**. If `FALSE` (default)
#'   only the default values of the API are returned. See also
#'   `return_addresses` argument.
#' @param return_addresses return input addresses with results if `TRUE`.
#' @param sourcecountry limits the candidates returned to the specified country
#'   or countries. Acceptable values include the three-character country code.
#'   You can specify multiple country codes to limit results to more than one
#'   country.
#' @param category A place or address type that can be used to filter results.
#'   Several values can be used as well as a vector (i.e.
#'   `c("Cinema", "Museum")`). See [arc_categories] for details.
#'
#' @inheritParams arc_reverse_geo
#'
#'
#' @references
#' [ArcGIS REST `findAddressCandidates`](`r arcurl("cand")`).
#'
#' @return
#'
#' ```{r child = "man/chunks/out1.Rmd"}
#' ```
#'
#' @details
#' More info and valid values in the [ArcGIS REST docs](`r arcurl("cand")`).
#'
#' @inheritSection arc_reverse_geo `outsr`
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' arc_geo("Madrid, Spain")
#'
#' library(dplyr)
#'
#' # Several addresses with additional output fields
#' with_params <- arc_geo(c("Madrid", "Barcelona"),
#'   custom_query = list(outFields = c("LongLabel", "CntryName"))
#' )
#'
#' with_params |>
#'   select(lat, lon, CntryName, LongLabel)
#'
#' # With options: restrict search to USA
#' with_params_usa <- arc_geo(c("Madrid", "Barcelona"),
#'   sourcecountry = "USA",
#'   custom_query = list(outFields = c("LongLabel", "CntryName"))
#' )
#'
#' with_params_usa |>
#'   select(lat, lon, CntryName, LongLabel)
#' }
#' @export
#'
#' @seealso [tidygeocoder::geo()]
#' @family geocoding
#'
arc_geo <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  progressbar = TRUE,
  outsr = NULL,
  langcode = NULL,
  sourcecountry = NULL,
  category = NULL,
  custom_query = list()
) {
  if (limit > 50) {
    message(paste(
      "\nArcGIS REST API provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }

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

  # Add additional arguments to the custom query
  if (isTRUE(full_results)) {
    # This will override the outFields param provided in the custom_query
    custom_query$outFields <- "*"
  }

  custom_query$sourceCountry <- sourcecountry
  custom_query$outSR <- outsr
  custom_query$langCode <- langcode
  custom_query$category <- category

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
      custom_query,
      singleline = TRUE
    )
  })
  if (progressbar) {
    close(pb)
  }

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  all_res[all_res == ""] <- NA
  all_res
}


arc_geo_single <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = TRUE,
  return_addresses = TRUE,
  verbose = TRUE,
  custom_query = list(),
  singleline = TRUE
) {
  # Step 1: Download ----
  api <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer/findAddressCandidates?"
  )

  # Compose url
  if (singleline) {
    ad_q <- paste0("SingleLine=", address)
  } else {
    ad_q <- address
  }

  url <- paste0(api, ad_q, "&f=json&maxLocations=", limit)

  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(query = address)

  # nocov start
  if (isFALSE(res)) {
    message("\n", url, " not reachable.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = FALSE)

  # Empty query
  if (length(result_init$candidates) == 0) {
    message("\nNo results for query ", address)
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
    result_end,
    lat,
    long,
    full_results,
    return_addresses
  )

  result_out
}
