# Geocode places by category in an area

Finds places that match one or more categories near a location or within
a bounding box.

See
[arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)
for a detailed explanation and available values.

To obtain results, provide either a pair of coordinates, `x` and `y`, as
a search origin or a bounding box in `bbox` to define the search extent.

You can combine both approaches by providing `x`, `y` and `bbox`. See
**Examples**.

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

  A place or address type used to filter results. Multiple values can be
  supplied as a vector (for example, `c("Cinema", "Museum")`), which
  performs one call for each value. See **Details**.

- x:

  A numeric vector of longitude values in the range \\\left\[-180, 180
  \right\]\\.

- y:

  A numeric vector of latitude values in the range \\\left\[-90, 90
  \right\]\\.

- bbox:

  A numeric vector of longitude and latitude values
  `c(xmin, ymin, xmax, ymax)` that restricts the search area. See
  **Details**.

- name:

  An optional string containing the name or address to match.

- lat:

  Name of the latitude or y-coordinate column in the output. The default
  is `"lat"`.

- long:

  Name of the longitude or x-coordinate column in the output. The
  default is `"lon"`.

- limit:

  Maximum number of results per query. The ArcGIS REST API limits a
  single request to 50 results.

- full_results:

  A logical value. If `TRUE`, returns all available API fields via
  `outFields = "*"`. The default is `FALSE`.

- verbose:

  A logical value. If `TRUE`, displays API request details.

- custom_query:

  A named list with additional API parameters.

- ...:

  Arguments passed on to
  [`arc_geo`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md)

  `sourcecountry`

  :   Country filter using ISO codes (for example, `"USA"`). Multiple
      values can be supplied as a comma-separated string.

  `outsr`

  :   Spatial reference of the output coordinates. The default is
      `NULL`, which uses the service default. See **Details** and
      [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

  `langcode`

  :   Language of the returned addresses.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with one
or more matches for each query. For details about the available fields,
see [ArcGIS REST API service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

Bounding boxes can be located using online tools, such as [Bounding Box
Tool](https://boundingbox.klokantech.com/).

For a full list of valid categories, see
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
that of the service (WGS 84, that is, WKID 4326).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## See also

[arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)
for supported values and [ArcGIS REST API category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
for API details.

Geocoding and reverse geocoding functions:
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md),
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md)

## Examples

``` r
# \donttest{
# Full workflow: gas stations near Carabanchel, Madrid.

# Geocode Carabanchel.
carab <- arc_geo("Carabanchel, Madrid, Spain")

# Extract the CRS.
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
  # Use Carabanchel as the search origin.
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
  # Match this name.
  name = "Repsol",
  # Use Carabanchel as the search origin.
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
