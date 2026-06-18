#' Geocode addresses with a structured ArcGIS REST API query
#'
#' @description
#' Converts structured address components into geographic coordinates and
#' returns one or more matches for each query.
#'
#' For a single-line address, use [arc_geo()].
#'
#' @param address,address2,address3,neighborhood,city,subregion Address
#'   components. See **Details**.
#' @param region,postal,postalext,countrycode Additional address components.
#'   See **Details**.
#' @inheritParams arc_geo
#'
#' @details
#' See the [ArcGIS REST API documentation](`r arcurl("cand")`) for more
#' information and valid values.
#'
#' # Address components
#'
#' This function performs structured queries using separate address components.
#' At least one component must not be `NA` or `NULL`.
#'
#' Each argument can be a vector to geocode multiple addresses. Vectors supplied
#' to different arguments must have the same length.
#'
#' The following list provides a brief description of each argument:
#'
#' - `address`: A string representing the first line of a street address. It
#'   usually contains the street name and house number, but can also contain a
#'   building or place name.
#' - `address2`: A string that represents the second line of a street address.
#'   It can include a street name and house number, building name, place name or
#'   subunit.
#' - `address3`: A string that represents the third line of a street address.
#'   It can include a street name and house number, building name, place name or
#'   subunit.
#' - `neighborhood`: The smallest administrative division associated with an
#'   address, typically a neighborhood or a section of a larger populated
#'   place.
#' - `city`: The next largest administrative division associated with an
#'   address, typically a city or municipality.
#' - `subregion`: The next largest administrative division associated with an
#'   address. Depending on the country, a subregion can represent a
#'   county, state or province.
#' - `region`: The largest administrative division associated with an address,
#'   typically a state or province.
#' - `postal`: The standard postal code for an address, typically a
#'   three– to six-digit alphanumeric code.
#' - `postalext`: A postal code extension, such as the United States Postal
#'   Service ZIP+4 code.
#' - `countrycode`: A value representing the country. Providing this value can
#'   increase search speed. Acceptable values include the full country
#'   name in English or the official language of the country, the two-character
#'   country code or the three-character country code.
#'
#' @inheritSection arc_reverse_geo `outsr`
#'
#' @returns
#' ```{r child = "man/chunks/out1.Rmd"}
#' ```
#'
#' The output also includes the input arguments as columns prefixed with `q_`
#' to help track the results.
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
#' simple <- arc_geo_multi(
#'   address = "Plaza Mayor", limit = 10,
#'   custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
#' )
#'
#' library(dplyr)
#'
#' simple |>
#'   select(lat, lon, CntryName, Region, LongLabel) |>
#'   slice_head(n = 10)
#'
#' # Restrict search to Spain.
#' simple2 <- arc_geo_multi(
#'   address = "Plaza Mayor", countrycode = "ESP",
#'   limit = 10,
#'   custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
#' )
#'
#' simple2 |>
#'   select(lat, lon, CntryName, Region, LongLabel) |>
#'   slice_head(n = 10)
#'
#' # Restrict to a region.
#' simple3 <- arc_geo_multi(
#'   address = "Plaza Mayor", region = "Segovia",
#'   countrycode = "ESP",
#'   limit = 10,
#'   custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
#' )
#'
#' simple3 |>
#'   select(lat, lon, CntryName, Region, LongLabel) |>
#'   slice_head(n = 10)
#' }
arc_geo_multi <- function(
  address = NULL,
  address2 = NULL,
  address3 = NULL,
  neighborhood = NULL,
  city = NULL,
  subregion = NULL,
  region = NULL,
  postal = NULL,
  postalext = NULL,
  countrycode = NULL,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  progressbar = TRUE,
  outsr = NULL,
  langcode = NULL,
  category = NULL,
  custom_query = list()
) {
  # Prepare multi-field input.
  init_df <- input_multi(
    address,
    address2,
    address3,
    neighborhood,
    city,
    subregion,
    region,
    postal,
    postalext,
    countrycode
  )

  limit <- restrict_arc_limit(limit)

  # Deduplicate queries.
  init_key <- init_df
  key <- unique(init_df$query)
  key <- key[!is.na(key)]

  if (length(key) == 0) {
    stop("Provide at least one address component that is not `NA`.")
  }

  # Add API arguments to the custom query.
  custom_query <- add_find_address_params(
    custom_query,
    full_results = full_results,
    outsr = outsr,
    langcode = langcode,
    category = category,
    include_sourcecountry = FALSE
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
    singleline = FALSE,
    progressbar = progressbar
  )
}

# Prepare multi-field input.
input_multi <- function(
  address = NULL,
  address2 = NULL,
  address3 = NULL,
  neighborhood = NULL,
  city = NULL,
  subregion = NULL,
  region = NULL,
  postal = NULL,
  postalext = NULL,
  countrycode = NULL
) {
  multi_list <- list(
    address = address,
    address2 = address2,
    address3 = address3,
    neighborhood = neighborhood,
    city = city,
    subregion = subregion,
    region = region,
    postal = postal,
    postalExt = postalext,
    countryCode = countrycode
  )

  getlen <- lengths(multi_list)
  nolens <- getlen[getlen != 0]
  if (length(nolens) == 0) {
    stop("Provide at least one address component that is not `NA`.")
  }
  if (length(unique(nolens)) != 1) {
    stop(paste0(
      "When providing multiple address components, ",
      "their lengths must be the same."
    ))
  }

  the_df <- dplyr::bind_rows(multi_list[names(nolens)])

  # Build a query for each row.
  query <- vapply(
    seq_len(nrow(the_df)),
    function(x) {
      multi_row_query(the_df[x, ])
    },
    FUN.VALUE = character(1)
  )

  names(the_df) <- paste0("q_", tolower(names(the_df)))

  the_df$query <- query

  the_df
}
