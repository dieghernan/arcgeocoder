#' ArcGIS REST API category database
#'
#' @description
#'
#' Database of available categories that can be used to filter results
#' provided by [arc_geo()], [arc_geo_multi()] and [arc_geo_categories()] in
#' [tibble][tibble::tbl_df] format.
#'
#' @note Data extracted on **15 January 2026**.
#'
#' @source
#' [ArcGIS REST Category filtering](`r arcurl("filt")`).
#'
#' @encoding UTF-8
#'
#' @name arc_categories
#'
#' @docType data
#'
#' @format
#' A [tibble][tibble::tbl_df] with
#' `r prettyNum(nrow(arcgeocoder::arc_categories), big.mark=",")` rows and
#' fields:
#' \describe{
#'   \item{level_1}{Top-level category.}
#'   \item{level_2}{Second-level category.}
#'   \item{level_3}{Child-level category.}
#' }
#' @details
#'
#' See [ArcGIS REST Category filtering](`r arcurl("filt")`) for details and
#' examples.
#'
#' The geocoding service allows users to search for and geocode many types of
#' addresses and places around the world. This simplifies application
#' development because developers do not need to know what types of places
#' their users are searching for; the service can decipher that.
#' However, due to this flexibility, it is possible for ambiguous searches to
#' match to many different places, and users may sometimes receive unexpected
#' results. For example, a search for a city may match to a street name, or a
#' search for an airport code may match to a country abbreviation.
#'
#' For such cases, the service provides the ability to filter out unwanted
#' geocode results with the `category` argument. The `category` argument
#' limits the types of places for which the service searches, thus eliminating
#' false positive matches and potentially speeding up the search process.
#'
#' The results show a list of categories with three different hierarchy levels
#' (`level_1`, `level_2`, `level_3`). If a `level_1` category is requested
#' (i.e. `POI`), the child categories may also be included in the results.
#'
#' @family datasets
#'
#' @seealso [arc_geo_categories()], [arc_geo()], [arc_geo_multi()]
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Get all possible values.
#' data("arc_categories")
#' arc_categories
#'
#' # Use categories.
#'
#' sea_1 <- arc_geo("sea",
#'   custom_query = list(outFields = c("LongLabel", "Type")),
#'   limit = 2
#' )
#'
#' dplyr::glimpse(sea_1)
#'
#' # An airport, but if we use categories...
#'
#' sea_2 <- arc_geo("sea",
#'   custom_query = list(outFields = c("LongLabel", "Type")),
#'   limit = 2, category = "Food"
#' )
#'
#' dplyr::glimpse(sea_2)
#'
#' # Use a list of categories.
#' sea_3 <- arc_geo("sea",
#'   custom_query = list(outFields = c("LongLabel", "Type")),
#'   sourcecountry = "UK", limit = 5,
#'   category = c("Amusement Park", "Aquarium")
#' )
#'
#' dplyr::glimpse(sea_3)
#' }
NULL

#' Esri (ArcGIS) spatial reference database
#'
#' @description
#'
#' Database of available spatial references (CRS) in [tibble][tibble::tbl_df]
#' format.
#'
#' @note Data extracted on **15 January 2026**.
#'
#' @source
#' [Esri Projection Engine
#' factory](https://github.com/Esri/projection-engine-db-doc)
#'
#' @encoding UTF-8
#'
#' @name arc_spatial_references
#'
#' @docType data
#'
#' @format A [tibble][tibble::tbl_df] with
#' `r prettyNum(nrow(arcgeocoder::arc_spatial_references), big.mark=",")` rows
#' and fields:
#' \describe{
#'   \item{projtype}{Projection type (`"ProjectedCoordinateSystems"`,
#'   `"GeographicCoordinateSystems"` or `"VerticalCoordinateSystems"`).}
#'   \item{wkid}{Well-Known ID.}
#'   \item{latestWkid}{Most recent `wkid`, if `wkid` is deprecated.}
#'   \item{authority}{`wkid` authority (Esri or EPSG).}
#'   \item{deprecated}{Logical indicating whether `wkid` is deprecated.}
#'   \item{description}{Human-readable description of the `wkid`.}
#'   \item{areaname}{Use area of the `wkid`.}
#'   \item{wkt}{Representation of `wkid` in Well-Known Text (WKT). Useful when
#'   working with \CRANpkg{sf} or \CRANpkg{terra}.}
#' }
#' @details
#'
#' This database is useful when using the `outsr` argument.
#'
#' Some projection IDs have changed over time. For example, Web Mercator
#' `wkid = 102100` is deprecated and is currently `wkid = 3857`. However, both
#' values work and return similar results.
#'
#' @family datasets
#'
#' @seealso
#' [sf::st_crs()]
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Get all possible values.
#' data("arc_spatial_references")
#' arc_spatial_references
#'
#' # Request with deprecated Web Mercator.
#' library(dplyr)
#' wkid <- arc_spatial_references |>
#'   filter(latestWkid == 3857 & deprecated) |>
#'   slice(1)
#'
#' glimpse(wkid)
#'
#' add <- arc_geo("London, United Kingdom", outsr = wkid$wkid)
#'
#' # Note values for `lat`, `lon` and `wkid`. `latestWkid` gives the current
#' # valid `wkid`.
#' add |>
#'   select(lat, lon, wkid, latestWkid) |>
#'   glimpse()
#'
#' # Try with `sf`.
#'
#' try(sf::st_crs(wkid$wkid))
#'
#' # Try the latest WKID.
#' try(sf::st_crs(wkid$latestWkid))
#'
#' # Or use WKT.
#' try(sf::st_crs(wkid$wkt))
#' }
NULL
