#' Geocode addresses with the ArcGIS REST API
#'
#' @description
#' Converts single-line addresses into geographic coordinates and returns one
#' or more matches for each query.
#'
#' This function uses the `SingleLine` approach detailed in the
#' [ArcGIS REST API documentation](`r arcurl("cand")`). For structured queries
#' that use specific address components, use [arc_geo_multi()].
#'
#' @param address Single-line address text (for example,
#'   `"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
#'   (for example, `c("Madrid", "Barcelona")`).
#' @param lat Name of the latitude or y-coordinate column in the output. The
#'   default is `"lat"`.
#' @param long Name of the longitude or x-coordinate column in the output. The
#'   default is `"lon"`.
#' @param limit Maximum number of results to return per input address. Each
#'   query has a hard API limit of 50 results.
#' @param full_results A logical value. If `TRUE`, returns all available API
#'   fields via `outFields = "*"`. The default is `FALSE`.
#' @param return_addresses A logical value. If `TRUE`, includes the input query
#'   in the output.
#' @param sourcecountry Country filter using ISO codes (for example, `"USA"`).
#'   Multiple values can be supplied as a comma-separated string.
#' @param category Place or address type used to filter results. Multiple values
#'   are accepted (for example, `c("Cinema", "Museum")`). See [arc_categories].
#' @param custom_query A named list with additional API parameters.
#'
#' @inheritParams arc_reverse_geo
#'
#' @details
#' See the [ArcGIS REST API documentation](`r arcurl("cand")`) for more
#' information and valid values.
#'
#' @inheritSection arc_reverse_geo `outsr`
#'
#' @returns
#' ```{r child = "man/chunks/out1.Rmd"}
#' ```
#'
#' @references
#' [ArcGIS REST API `findAddressCandidates`](`r arcurl("cand")`).
#'
#' @family geocoders
#'
#' @export
#' @encoding UTF-8
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' arc_geo("Madrid, Spain")
#'
#' library(dplyr)
#'
#' # Several addresses with additional output fields.
#' with_params <- arc_geo(c("Madrid", "Barcelona"),
#'   custom_query = list(outFields = c("LongLabel", "CntryName"))
#' )
#'
#' with_params |>
#'   select(lat, lon, CntryName, LongLabel)
#'
#' # Restrict the search to the USA.
#' with_params_usa <- arc_geo(c("Madrid", "Barcelona"),
#'   sourcecountry = "USA",
#'   custom_query = list(outFields = c("LongLabel", "CntryName"))
#' )
#'
#' with_params_usa |>
#'   select(lat, lon, CntryName, LongLabel)
#' }
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
  limit <- restrict_arc_limit(limit)

  # Deduplicate addresses before querying.
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  # Add API arguments to the custom query.
  custom_query <- add_find_address_params(
    custom_query,
    full_results = full_results,
    sourcecountry = sourcecountry,
    outsr = outsr,
    langcode = langcode,
    category = category
  )

  arc_geo_bulk(
    key = key,
    init_key = init_key,
    lat = lat,
    long = long,
    limit = limit,
    full_results = full_results,
    return_addresses = return_addresses,
    verbose = verbose,
    custom_query = custom_query,
    singleline = TRUE,
    progressbar = progressbar
  )
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
  api <- arc_endpoint_url("findAddressCandidates")

  # Compose URL.
  if (singleline) {
    ad_q <- paste0("SingleLine=", address)
  } else {
    ad_q <- address
  }

  url <- paste0(api, ad_q, "&f=json&maxLocations=", limit)

  url <- add_custom_query(custom_query, url)

  # Download to a temporary file.
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(query = address)

  if (isFALSE(res)) {
    message("\nURL is unreachable: ", url)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result_init <- jsonlite::fromJSON(json, flatten = FALSE)

  # Handle empty queries.
  if (length(result_init$candidates) == 0) {
    message("\nNo results found for query: ", address)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Unnest fields.
  tbl_query$lat <- NA
  tbl_query$lon <- NA
  result_unn <- unnest_geo(result_init)
  result_end <- dplyr::bind_cols(tbl_query, result_unn)
  result_end$lat <- as.double(result_unn$y)
  result_end$lon <- as.double(result_unn$x)

  # Keep names in the requested order.
  result_out <- keep_names(
    result_end,
    lat,
    long,
    full_results,
    return_addresses
  )

  result_out
}
