#' Place categories supported by the ArcGIS REST API
#'
#' @description
#' A dataset of categories that can be used to filter results from [arc_geo()],
#' [arc_geo_multi()] and [arc_geo_categories()].
#'
#' @name arc_categories
#' @docType data
#' @format
#' A [tibble][dplyr::tibble] with
#' `r prettyNum(nrow(arcgeocoder::arc_categories), big.mark=",")` rows and
#' three variables:
#' \describe{
#'   \item{level_1}{Top-level category.}
#'   \item{level_2}{Second-level category.}
#'   \item{level_3}{Child-level category.}
#' }
#' @details
#' See [ArcGIS REST API category filtering](`r arcurl("filt")`) for details and
#' examples.
#'
#' The ArcGIS geocoding service supports searches for many types of addresses
#' and places around the world, so applications do not need to anticipate the
#' types of places that users may search for. However, ambiguous searches can
#' match many different places and produce unexpected results. For example, a
#' search for a city may match a street name, or an airport code may match a
#' country abbreviation.
#'
#' In these cases, the `category` argument can filter out unwanted results. It
#' limits the types of places that the service searches for, which can eliminate
#' false-positive matches and speed up the search.
#'
#' The dataset lists categories at three hierarchy levels (`level_1`, `level_2`
#' and `level_3`). If a `level_1` category is requested (for example, `POI`),
#' its child categories may also be included in the results.
#'
#' @source
#' [ArcGIS REST API category filtering](`r arcurl("filt")`).
#'
#' @note Data extracted on **15 January 2026**.
#'
#' @seealso [arc_geo()], [arc_geo_multi()] and [arc_geo_categories()].
#'
#' @keywords datasets
#'
#' @encoding UTF-8
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
#' # Categories can disambiguate the result.
#'
#' sea_2 <- arc_geo("sea",
#'   custom_query = list(outFields = c("LongLabel", "Type")),
#'   limit = 2, category = "Food"
#' )
#'
#' dplyr::glimpse(sea_2)
#'
#' # Use multiple categories.
#' sea_3 <- arc_geo("sea",
#'   custom_query = list(outFields = c("LongLabel", "Type")),
#'   sourcecountry = "UK", limit = 5,
#'   category = c("Amusement Park", "Aquarium")
#' )
#'
#' dplyr::glimpse(sea_3)
#' }
NULL

#' Spatial references supported by the ArcGIS REST API
#'
#' @description
#' A dataset of coordinate reference systems (CRSs) supported by the ArcGIS
#' REST API.
#'
#' @name arc_spatial_references
#' @docType data
#' @format
#' A [tibble][dplyr::tibble] with
#' `r prettyNum(nrow(arcgeocoder::arc_spatial_references), big.mark=",")` rows
#' and eight variables:
#' \describe{
#'   \item{projtype}{Projection type (`"ProjectedCoordinateSystems"`,
#'     `"GeographicCoordinateSystems"` or `"VerticalCoordinateSystems"`).}
#'   \item{wkid}{Well-known ID (WKID).}
#'   \item{latestWkid}{Current WKID if `wkid` is deprecated.}
#'   \item{authority}{WKID authority (Esri or EPSG).}
#'   \item{deprecated}{Whether `wkid` is deprecated.}
#'   \item{description}{Human-readable description of the spatial reference.}
#'   \item{areaname}{Area of use of the spatial reference.}
#'   \item{wkt}{Well-known text (WKT) representation of the spatial reference.
#'     Useful when working with \CRANpkg{sf} or \CRANpkg{terra}.}
#' }
#' @details
#' This dataset is useful when using the `outsr` argument.
#'
#' Some projection IDs have changed over time. For example, Web Mercator
#' `wkid = 102100` is deprecated and its current equivalent is `wkid = 3857`.
#' Both values work and return equivalent results.
#'
#' @source
#' [Esri Projection Engine
#' factory](https://github.com/Esri/projection-engine-db-doc).
#'
#' @note Data extracted on **15 January 2026**.
#'
#' @seealso
#' - [sf::st_crs()] inspects coordinate reference systems.
#' - [arc_geo()], [arc_geo_multi()], [arc_geo_categories()] and
#'   [arc_reverse_geo()] accept spatial references.
#'
#' @keywords datasets
#'
#' @encoding UTF-8
#'
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Get all possible values.
#' data("arc_spatial_references")
#' arc_spatial_references
#'
#' # Find the deprecated Web Mercator WKID.
#' library(dplyr)
#' wkid <- arc_spatial_references |>
#'   filter(latestWkid == 3857 & deprecated) |>
#'   slice(1)
#'
#' glimpse(wkid)
#'
#' add <- arc_geo("London, United Kingdom", outsr = wkid$wkid)
#'
#' # Compare `lat`, `lon`, `wkid` and the current ID in `latestWkid`.
#' add |>
#'   select(lat, lon, wkid, latestWkid) |>
#'   glimpse()
#'
#' # Look up the deprecated WKID.
#'
#' try(sf::st_crs(wkid$wkid))
#'
#' # Look up the current WKID.
#' try(sf::st_crs(wkid$latestWkid))
#'
#' # Look up the WKT definition.
#' try(sf::st_crs(wkid$wkt))
#' }
NULL
