#' Categories supported by the ArcGIS REST API
#'
#' @description
#'
#' List of available categories that can be used for filtering
#' results provided by [arc_geo()] and [arc_geo_multi()].
#'
#' @inheritParams arc_geo
#'
#' @references
#' [ArcGIS REST Category
#' filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
#'
#' @return A \CRANpkg{tibble} with the results.
#'
#' @details
#'
#' The geocoding service allows users to search for and geocode many types of
#' addresses and places around the world. This simplifies the application
#' building process, as developers don't need to know what types of places
#' their users are searching for, because the service can decipher that.
#' However, due to this flexibility, it is possible for ambiguous searches to
#' match to many different places, and users may sometimes receive unexpected
#' results. For example, a search for a city may match to a street name, or a
#' search for an airport code may match to a country abbreviation.
#'
#' For such cases, the service provides the ability to filter out unwanted
#' geocode results with the `category` parameter. The `category` parameter
#' limits the types of places for which the service searches, thus eliminating
#' false positive matches and potentially speeding up the search process.
#'
#' The results shows a list of categories with three different hierarchy levels
#' (`level_1`, `level_2`, `level_3`). If a `level_1` category is requested
#' (i.e. `POI`) the child categories may be included also in the results.
#'
#' @export
#'
#' @family helpers
#'
#' @seealso [arc_geo()], [arc_geo_multi()]
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Get all possible values
#'
#' all_cats <- arc_categories()
#'
#' all_cats
#'
#' # Using categories
#'
#' sea_1 <- arc_geo("sea",
#'   custom_query = list(outFields = "LongLabel,Type"),
#'   limit = 2
#' )
#'
#' # An airport, but if we use categories...
#'
#' dplyr::glimpse(sea_1)
#'
#'
#' sea_2 <- arc_geo("sea",
#'   custom_query = list(outFields = "LongLabel,Type"),
#'   limit = 2, category = "Restaurant"
#' )
#'
#' dplyr::glimpse(sea_2)
#'
#' # We can use a list of categories separated by comma
#' sea_3 <- arc_geo("sea",
#'   custom_query = list(outFields = "LongLabel,Type"),
#'   sourcecountry = "UK", limit = 5,
#'   category = "Amusement Park,Aquarium"
#' )
#'
#' dplyr::glimpse(sea_3)
#' }
arc_categories <- function(verbose = FALSE) {
  # Step 1: Download ----
  url <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/",
    "services/World/GeocodeServer?f=pjson"
  )

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- arc_api_call(url, json, isFALSE(verbose))


  # Step 2: Read and parse results ----
  result_init <- jsonlite::fromJSON(json, flatten = FALSE)

  # Get categories
  cats <- as.list(result_init$categories)

  # top names
  topnames <- cats$name

  # Second level cats, no localized
  second_lev <- lapply(cats$categories, function(x) {
    x[!grepl("local", names(x))]
  })

  # There are special cases here...
  lng_list <- lengths(second_lev)

  # When lenght 1 is trivial
  seq_tot <- seq_len(length(second_lev))
  easy <- lapply(seq_tot[lng_list == 1], function(x) {
    end <- as.data.frame(second_lev[x])
    names(end) <- "level_2"
    end$level_1 <- topnames[x]
    end
  })

  easy_end <- dplyr::bind_rows(easy)
  # For others (POI) not so easy...

  n_hard <- seq_tot[lng_list > 1]

  pois <- second_lev[[n_hard]]$categories
  pois_sub <- second_lev[[n_hard]]$name
  pois_end <- lapply(pois, function(x) {
    x$name
  })

  # Compose sub data frames
  n_pois <- seq_len(length(pois_sub))

  pois_2nd_lev <- lapply(n_pois, function(x) {
    end <- data.frame(level_3 = unlist(pois_end[x]))
    end$level_2 <- pois_sub[x]
    end
  })

  pois_tbl <- dplyr::bind_rows(pois_2nd_lev)

  pois_tbl$level_1 <- topnames[n_hard]

  # End, rename and reorder cols

  all_end <- dplyr::bind_rows(easy_end, pois_tbl)

  all_end <- all_end[, c(2, 1, 3)]

  all_end <- dplyr::as_tibble(all_end)


  all_end
}
