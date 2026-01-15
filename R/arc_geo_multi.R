#' Geocoding using the ArcGIS REST API with multi-field query
#'
#' @description
#' Geocodes addresses given specific address components. This function returns
#' the [tibble][tibble::tbl_df] associated with the query.
#'
#' For geocoding using a single text string use [arc_geo()] function.
#'
#'
#' @param address,address2,address3,neighborhood,city,subregion Address
#'   components  (See **Details**).
#' @param region,postal,postalext,countrycode More address components, see
#'    (See **Details**).
#' @inheritParams arc_geo
#'
#' @references
#' [ArcGIS REST `findAddressCandidates`](`r arcurl("cand")`)
#'
#' @return
#' ```{r child = "man/chunks/out1.Rmd"}
#' ```
#'
#' The resulting output will include also the input arguments (columns with
#' prefix `q_`) for better tracking the results.
#'
#' @details
#' More info and valid values in the [ArcGIS REST docs](`r arcurl("cand")`).
#'
#'
#' # Address components
#'
#' This function allows performing structured queries by different components of
#' an address. At least one field should be different than `NA` or `NULL`.
#'
#' A vector of values can be provided for each argument for multiple geocoding.
#' When using vectors on different arguments, their lengths should be the
#' same.
#'
#' The following list provides a brief description of each argument:
#'
#' - `address`: A string that represents the first line of a street address. In
#'    most cases it will be the **street name and house number** input, but it
#'    can also be used to input building name or place-name.
#' - `address2`: A string that represents the second line of a street address.
#'   This can include **street name/house number, building name, place-name, or
#'   sub unit**.
#' - `address3`: A string that represents the third line of a street address.
#'   This can include **street name/house number, building name, place-name, or
#'   sub unit**.
#' - `neighborhood`: The smallest administrative division associated with an
#'   address, typically, a **neighborhood** or a section of a larger populated
#'   place.
#' - `city`: The next largest administrative division associated with an
#'   address, typically, a **city or municipality**.
#'  - `subregion`: The next largest administrative division associated with an
#'   address. Depending on the country, a sub region can represent a
#'  **county, state, or province**.
#'  - `region`: The largest administrative division associated with an address,
#'    typically, a **state or province**.
#' - `postal`: The **standard postal code** for an address, typically, a
#'    three– to six-digit alphanumeric code.
#' - `postalext`: A **postal code extension**, such as the United States Postal
#'    Service ZIP+4 code.
#'  - `countrycode`: A value representing the **country**. Providing this value
#'    **increases geocoding speed**. Acceptable values include the full country
#'    name in English or the official language of the country, the two-character
#'    country code, or the three-character country code.
#'
#' @inheritSection arc_reverse_geo `outsr`
#'
#' @export
#'
#' @seealso [tidygeocoder::geo()]
#' @family geocoding
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
#' # Restrict search to Spain
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
#' # Restrict to a region
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
  # Treat input multi
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

  if (limit > 50) {
    message(paste(
      "\nArcGIS REST API provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }

  # Dedupe for query
  init_key <- init_df
  key <- unique(init_df$query)
  key <- key[!is.na(key)]

  if (length(key) == 0) {
    stop("No address component provided. Must provide at least one value")
  }

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
      singleline = FALSE
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

# Helpef fun
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
    stop("No address component provided. Must provide at least one value")
  }
  if (length(unique(nolens)) != 1) {
    stop("When providing several components their lenghts should be the same")
  }

  the_df <- dplyr::bind_rows(multi_list[names(nolens)])

  # Build query for each row
  nr <- seq_len(nrow(the_df))

  query <- lapply(nr, function(x) {
    id_row <- the_df[x, ]
    id_row <- id_row[, as.logical(!is.na(id_row))]
    if (ncol(id_row) == 0) {
      qq <- NA
    } else {
      ll <- as.list(id_row)
      qq <- paste0(names(ll), "=", ll, collapse = "&")
    }

    qq
  })

  names(the_df) <- paste0("q_", tolower(names(the_df)))

  the_df$query <- unlist(query)

  the_df
}
