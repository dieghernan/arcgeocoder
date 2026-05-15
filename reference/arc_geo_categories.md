# Geocode places in a given area by category

This function is useful for extracting places with a given category (or
list of categories) near or within a given location or area. This is a
wrapper of
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
but it is vectorized over `category`.

See
[arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)
for a detailed explanation and available values.

**Note:** to obtain results, provide one of the following:

- A pair of coordinates (`x` and `y` arguments) used as a reference for
  geocoding.

- A bounding box via the `bbox` argument defining a desired extent for
  results.

It is possible to combine both approaches (i.e. providing `x`, `y` and
`bbox` values) to improve the geocoding process. See **Examples**.

## Usage

``` r
arc_geo_categories(
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
)
```

## Arguments

- category:

  A place or address type that can be used to filter results. Several
  values can also be supplied as a vector (i.e.
  `c("Cinema", "Museum")`), which performs one call for each value. See
  **Details**.

- x:

  Longitude values in numeric format. Must be in the range
  \\\left\[-180, 180 \right\]\\.

- y:

  Latitude values in numeric format. Must be in the range \\\left\[-90,
  90 \right\]\\.

- bbox:

  A numeric vector of longitude and latitude `c(minX, minY, maxX, maxY)`
  that restricts the search area. See **Details**.

- name:

  Optionally, a string indicating the name or address of the desired
  results.

- lat:

  Latitude column name in the output data (default `"lat"`).

- long:

  Longitude column name in the output data (default `"lon"`).

- limit:

  Maximum number of results per query. ArcGIS API limits a single
  request to 50 results.

- full_results:

  Logical. If `TRUE`, return all available API fields via `outFields=*`.
  Default is `FALSE`.

- verbose:

  Logical. If `TRUE`, output process messages to the console.

- custom_query:

  Additional API parameters as named list values.

- ...:

  Arguments passed on to
  [`arc_geo`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md)

  `sourcecountry`

  :   Country filter using ISO codes (e.g. `"USA"`). Multiple values can
      be specified (comma-separated).

  `outsr`

  :   The spatial reference of the `x` and `y` coordinates returned by a
      geocode request. By default, it is `NULL` (i.e. the argument will
      not be used in the query). See **Details** and
      [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

  `langcode`

  :   Sets the language in which reverse-geocoded addresses are
      returned.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
object with the results. See output details in [ArcGIS REST API service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

Bounding boxes can be located using online tools, such as [Bounding Box
Tool](https://boundingbox.klokantech.com/).

For a full list of valid categories see
[arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md).
This function is vectorized over `category`, which means it performs one
independent call to
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md)
for each `category` value.

`arc_geo_categories()` also understands a single string of categories
separated by commas (`"Cinema,Museum"`), which is treated internally as
`c("Cinema", "Museum")`.

## `outsr`

The spatial reference can be specified as a well-known ID (WKID). If not
specified, the spatial reference of the output locations is the same as
that of the service (WGS84, i.e. WKID = 4326).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## See also

[ArcGIS REST Category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm).

[arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)

Other functions for geocoding:
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md),
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md)

## Examples

``` r
# \donttest{
# Full workflow: gas stations near Carabanchel, Madrid.

# Get Carabanchel.
carab <- arc_geo("Carabanchel, Madrid, Spain")

# CRS.
carab_crs <- unique(carab$latestWkid)

library(ggplot2)

base_map <- ggplot(carab) +
  geom_point(aes(lon, lat), size = 5, color = "red") +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = NA,
    color = "blue"
  ) +
  coord_sf(crs = carab_crs)

# Example 1: Search near Carabanchel (not restricted).
ex1 <- arc_geo_categories("Gas Station",
  # Location.
  x = carab$lon, y = carab$lat,
  limit = 50, full_results = TRUE
)

# Reduce labels to the most common ones.
library(dplyr)

labs <- ex1 |>
  count(ShortLabel) |>
  slice_max(n = 7, order_by = n) |>
  pull(ShortLabel)

base_map +
  geom_point(data = ex1, aes(lon, lat, color = ShortLabel)) +
  scale_color_discrete(breaks = labs) +
  labs(
    title = "Example 1",
    subtitle = "Search near (points may be far away)"
  )


# Example 2: Include part of the name for different results.
ex2 <- arc_geo_categories("Gas Station",
  # Name.
  name = "Repsol",
  # Location.
  x = carab$lon, y = carab$lat,
  limit = 50, full_results = TRUE
)

base_map +
  geom_point(data = ex2, aes(lon, lat, color = ShortLabel)) +
  labs(
    title = "Example 2",
    subtitle = "Search near with name"
  )


# Example 3: Search within a bounding box.
ex3 <- arc_geo_categories("Gas Station",
  name = "Repsol",
  bbox = c(carab$xmin, carab$ymin, carab$xmax, carab$ymax),
  limit = 50, full_results = TRUE
)

base_map +
  geom_point(data = ex3, aes(lon, lat, color = ShortLabel)) +
  labs(
    title = "Example 3",
    subtitle = "Search near with name and bounding box"
  )

# }
```
