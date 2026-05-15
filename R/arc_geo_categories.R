#' Geocode places in a given area by category
#'
#' @description
#' This function is useful for extracting places with a given category (or list
#' of categories) near or within a given location or area. This is a wrapper
#' of [arc_geo()], but it is vectorized over `category`.
#'
#' See [arc_categories] for a detailed explanation and available values.
#'
#' **Note:** to obtain results, provide one of the following:
#' - A pair of coordinates (`x` and `y` arguments) used as a reference for
#'   geocoding.
#' - A bounding box via the `bbox` argument defining a desired extent for
#'   results.
#'
#' It is possible to combine both approaches (i.e. providing `x`, `y` and
#' `bbox` values) to improve the geocoding process. See **Examples**.
#'
#' @param category A place or address type that can be used to filter results.
#'   Several values can also be supplied as a vector (i.e.
#'   `c("Cinema", "Museum")`), which performs one call for each value. See
#'   **Details**.
#' @param limit Maximum number of results per query. ArcGIS API limits a single
#'   request to 50 results.
#' @inheritParams arc_geo
#' @inheritParams arc_reverse_geo
#' @inheritDotParams arc_geo -address -return_addresses -progressbar
#' @param bbox A numeric vector of longitude and latitude
#'   `c(minX, minY, maxX, maxY)` that restricts the search area.
#'   See **Details**.
#' @param name Optionally, a string indicating the name or address of the
#'   desired results.
#' @param custom_query Additional API parameters as named list values.
#'
#' @details
#'
#' Bounding boxes can be located using online tools, such as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid categories see [arc_categories]. This function is
#' vectorized over `category`, which means it performs one independent call
#' to [arc_geo()] for each `category` value.
#'
#' `arc_geo_categories()` also understands a single string of categories
#' separated by commas (`"Cinema,Museum"`), which is treated internally as
#' `c("Cinema", "Museum")`.
#'
#' @inheritSection arc_reverse_geo `outsr`
#'
#' @seealso
#' [ArcGIS REST Category filtering](`r arcurl("filt")`).
#'
#' [arc_categories]
#'
#' @family geocoding
#'
#' @return
#'
#' ```{r child = "man/chunks/out1.Rmd"}
#' ```
#'
#' @export
#' @examplesIf arcgeocoder_check_access()
#' \donttest{
#' # Full workflow: gas stations near Carabanchel, Madrid.
#'
#' # Get Carabanchel.
#' carab <- arc_geo("Carabanchel, Madrid, Spain")
#'
#' # CRS.
#' carab_crs <- unique(carab$latestWkid)
#'
#' library(ggplot2)
#'
#' base_map <- ggplot(carab) +
#'   geom_point(aes(lon, lat), size = 5, color = "red") +
#'   geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
#'     fill = NA,
#'     color = "blue"
#'   ) +
#'   coord_sf(crs = carab_crs)
#'
#' # Example 1: Search near Carabanchel (not restricted).
#' ex1 <- arc_geo_categories("Gas Station",
#'   # Location.
#'   x = carab$lon, y = carab$lat,
#'   limit = 50, full_results = TRUE
#' )
#'
#' # Reduce labels to the most common ones.
#' library(dplyr)
#'
#' labs <- ex1 |>
#'   count(ShortLabel) |>
#'   slice_max(n = 7, order_by = n) |>
#'   pull(ShortLabel)
#'
#' base_map +
#'   geom_point(data = ex1, aes(lon, lat, color = ShortLabel)) +
#'   scale_color_discrete(breaks = labs) +
#'   labs(
#'     title = "Example 1",
#'     subtitle = "Search near (points may be far away)"
#'   )
#'
#' # Example 2: Include part of the name for different results.
#' ex2 <- arc_geo_categories("Gas Station",
#'   # Name.
#'   name = "Repsol",
#'   # Location.
#'   x = carab$lon, y = carab$lat,
#'   limit = 50, full_results = TRUE
#' )
#'
#' base_map +
#'   geom_point(data = ex2, aes(lon, lat, color = ShortLabel)) +
#'   labs(
#'     title = "Example 2",
#'     subtitle = "Search near with name"
#'   )
#'
#' # Example 3: Search within a bounding box.
#' ex3 <- arc_geo_categories("Gas Station",
#'   name = "Repsol",
#'   bbox = c(carab$xmin, carab$ymin, carab$xmax, carab$ymax),
#'   limit = 50, full_results = TRUE
#' )
#'
#' base_map +
#'   geom_point(data = ex3, aes(lon, lat, color = ShortLabel)) +
#'   labs(
#'     title = "Example 3",
#'     subtitle = "Search near with name and bounding box"
#'   )
#' }
arc_geo_categories <- function(
  category,
  x = NULL,
  y = NULL,
  bbox = NULL,
  name = NULL,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  verbose = FALSE,
  custom_query = list(),
  ...
) {
  # Prepare location.
  locs <- validate_location(x, y)

  # Prepare `bbox`.
  bbox <- validate_bbox(bbox)

  if (all(is.na(c(locs, bbox)))) {
    stop(
      paste0(
        "Provide either a valid combination of x and y arguments or ",
        "a valid `bbox`"
      )
    )
  }

  # Prepare query.
  # Vectorize categories.
  cats <- unlist(strsplit(paste0(category, collapse = ","), ","))

  base_tbl <- dplyr::tibble(
    q_category = cats,
    q_x = locs[1],
    q_y = locs[2],
    q_bbox_xmin = bbox[1],
    q_bbox_ymin = bbox[2],
    q_bbox_xmax = bbox[3],
    q_bbox_ymax = bbox[4]
  )

  if (!anyNA(locs)) {
    custom_query$location <- paste0(locs, collapse = ",")
  }

  if (!anyNA(bbox)) {
    custom_query$searchExtent <- paste0(bbox, collapse = ",")
  }

  if (is.null(name)) {
    name <- ""
  }

  # Vectorize call over categories.
  ncalls <- seq_len(nrow(base_tbl))
  api_res <- lapply(ncalls, function(x) {
    bs <- base_tbl[x, ]
    qry <- arc_geo(
      category = bs$q_category,
      address = name,
      lat = lat,
      long = long,
      limit = limit,
      full_results = full_results,
      return_addresses = TRUE,
      verbose = verbose,
      progressbar = FALSE,
      custom_query = custom_query,
      ...
    )
    if (all(is.na(qry[, c(2, 3)]))) {
      message("(category: ", bs$q_category, ")")
    }
    end <- dplyr::bind_cols(bs, qry)

    # Remove helper fields.
    end <- end[, setdiff(names(end), "query")]

    end
  })

  dplyr::bind_rows(api_res)
}

validate_location <- function(x = NULL, y = NULL) {
  if (is.null(x)) {
    x <- NA
  }
  if (is.null(y)) {
    y <- NA
  }
  # Return NAs if both coordinates are missing.
  if (all(is.na(x), is.na(y))) {
    return(c(NA, NA))
  }

  # Return NAs with a message if either coordinate is missing.
  if (anyNA(c(x, y))) {
    message(
      "Either x or y is missing. The `location` argument will not be used"
    )
    return(c(NA, NA))
  }

  # Check inputs.
  if (!is.numeric(x) || !is.numeric(y)) {
    stop("x and y must be numeric")
  }

  # Use only the first coordinate pair.
  x <- x[1]
  y <- y[1]

  # Lat
  y_cap <- pmax(pmin(y, 90), -90)

  if (!identical(y_cap, y)) {
    message("\nLatitudes have been restricted to [-90, 90]")
  }

  # Lon
  x_cap <- pmax(pmin(x, 180), -180)

  if (!all(x_cap == x)) {
    message("\nLongitudes have been restricted to [-180, 180]")
  }

  c(x_cap, y_cap)
}

validate_bbox <- function(bbox = NULL) {
  if (is.null(bbox)) {
    return(c(NA, NA, NA, NA))
  }

  # Return NAs with a message if any `bbox` value is missing.
  if (anyNA(bbox)) {
    message("`bbox` has NA values. The `bbox` argument will not be used")
    return(c(NA, NA, NA, NA))
  }

  if (length(bbox) < 4) {
    message(
      "`bbox` has fewer than 4 values. The `bbox` argument will not be used"
    )
    return(c(NA, NA, NA, NA))
  }

  if (!is.numeric(bbox)) {
    message("`bbox` is not numeric. The `bbox` argument will not be used")
    return(c(NA, NA, NA, NA))
  }

  # Use only the first four `bbox` values.
  bbox <- bbox[1:4]

  # Lon
  xs <- bbox[c(1, 3)]
  xs_cap <- pmax(pmin(xs, 180), -180)

  if (!all(xs_cap == xs)) {
    message("\n`bbox` xmin and xmax have been restricted to [-180, 180]")
  }

  # Lat
  ys <- bbox[c(2, 4)]
  ys_cap <- pmax(pmin(ys, 90), -90)

  if (!all(ys_cap == ys)) {
    message("\n`bbox` ymin and ymax have been restricted to [-90, 90]")
  }

  c(xs_cap[1], ys_cap[1], xs_cap[2], ys_cap[2])
}
