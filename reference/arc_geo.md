# Geocode addresses with the ArcGIS REST API

Converts single-line addresses into geographic coordinates and returns
one or more matches for each query.

This function uses the `SingleLine` approach detailed in the [ArcGIS
REST API
documentation](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm).
For structured queries that use specific address components, use
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md).

## Usage

``` r
arc_geo(
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
)
```

## Arguments

- address:

  Single-line address text (for example,
  `"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
  (for example, `c("Madrid", "Barcelona")`).

- lat:

  Name of the latitude or y-coordinate column in the output. The default
  is `"lat"`.

- long:

  Name of the longitude or x-coordinate column in the output. The
  default is `"lon"`.

- limit:

  Maximum number of results to return per input address. Each query has
  a hard API limit of 50 results.

- full_results:

  A logical value. If `TRUE`, returns all available API fields via
  `outFields = "*"`. The default is `FALSE`.

- return_addresses:

  A logical value. If `TRUE`, includes the input query in the output.

- verbose:

  A logical value. If `TRUE`, displays API request details.

- progressbar:

  A logical value. If `TRUE`, displays a progress bar for multiple
  queries.

- outsr:

  Spatial reference of the output coordinates. The default is `NULL`,
  which uses the service default. See **Details** and
  [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

- langcode:

  Language of the returned addresses.

- sourcecountry:

  Country filter using ISO codes (for example, `"USA"`). Multiple values
  can be supplied as a comma-separated string.

- category:

  Place or address type used to filter results. Multiple values are
  accepted (for example, `c("Cinema", "Museum")`). See
  [arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md).

- custom_query:

  A named list with additional API parameters.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with one
or more matches for each query. For details about the available fields,
see [ArcGIS REST API service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

See the [ArcGIS REST API
documentation](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm)
for more information and valid values.

## `outsr`

The spatial reference can be specified as a well-known ID (WKID). If not
specified, the spatial reference of the output locations is the same as
that of the service (WGS 84, that is, WKID 4326).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## References

[ArcGIS REST API
`findAddressCandidates`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm).

## See also

Geocoding and reverse geocoding functions:
[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md),
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md)

## Examples

``` r
# \donttest{
arc_geo("Madrid, Spain")
#> # A tibble: 1 × 13
#>   query        lat   lon address score     x     y  xmin  ymin  xmax  ymax  wkid
#>   <chr>      <dbl> <dbl> <chr>   <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <int>
#> 1 Madrid, S…  40.4 -3.70 Madrid…   100 -3.70  40.4 -3.88  40.2 -3.52  40.6  4326
#> # ℹ 1 more variable: latestWkid <int>

library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

# Several addresses with additional output fields.
with_params <- arc_geo(c("Madrid", "Barcelona"),
  custom_query = list(outFields = c("LongLabel", "CntryName"))
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%

with_params |>
  select(lat, lon, CntryName, LongLabel)
#> # A tibble: 2 × 4
#>     lat   lon CntryName LongLabel                       
#>   <dbl> <dbl> <chr>     <chr>                           
#> 1  40.4 -3.70 España    Madrid, Comunidad de Madrid, ESP
#> 2  41.4  2.17 España    Barcelona, Cataluña, ESP        

# Restrict the search to the USA.
with_params_usa <- arc_geo(c("Madrid", "Barcelona"),
  sourcecountry = "USA",
  custom_query = list(outFields = c("LongLabel", "CntryName"))
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%

with_params_usa |>
  select(lat, lon, CntryName, LongLabel)
#> # A tibble: 2 × 4
#>     lat   lon CntryName     LongLabel         
#>   <dbl> <dbl> <chr>         <chr>             
#> 1  41.9 -93.8 United States Madrid, IA, USA   
#> 2  35.6 -94.5 United States Barcelona, AR, USA
# }
```
