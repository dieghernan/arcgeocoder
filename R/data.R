#' ArcGIS REST API category data base
#'
#' @description
#'
#' Database of available categories that can be used for filtering
#' results provided by [arc_geo()] and [arc_geo_multi()] in \CRANpkg{tibble}
#' format.
#'
#' @note Data extracted on **10 January 2023**.
#'
#'
#' @source
#' [ArcGIS REST Category
#' filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
#'
#' @encoding UTF-8
#'
#' @name arc_categories
#'
#' @docType data
#'
#' @format A \CRANpkg{tibble} with
#' `r prettyNum(nrow(arcgeocoder::arc_categories), big.mark=",")` rows and
#' fields:
#' \describe{
#'   \item{level_1}{Top-level category}
#'   \item{level_2}{Second-level category}
#'   \item{level_3}{Child-level category}
#' }
#' @details
#'
#' See [ArcGIS REST Category
#' filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
#' for details and examples.
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
#'
#' @family datasets
#'
#' @seealso [arc_geo()], [arc_geo_multi()]
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Get all possible values
#' data("arc_categories")
#' arc_categories
#'
#' # Using categories
#'
#' sea_1 <- arc_geo("sea",
#'   custom_query = list(outFields = "LongLabel,Type"),
#'   limit = 2
#' )
#'
#'
#' dplyr::glimpse(sea_1)
#'
#' # An airport, but if we use categories...
#'
#' sea_2 <- arc_geo("sea",
#'   custom_query = list(outFields = "LongLabel,Type"),
#'   limit = 2, category = "Food"
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
NULL
