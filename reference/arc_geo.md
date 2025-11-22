# Geocoding using the ArcGIS REST API

Geocodes addresses given as character values. This function returns the
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) object
associated with the query.

This function uses the `SingleLine` approach detailed in the [ArcGIS
REST
docs](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm).
For multi-field queries (i.e. using specific address parameters) use
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)
function.

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

  character with single line address
  (`"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
  (`c("Madrid", "Barcelona")`).

- lat:

  latitude column name in the output data (default `"lat"`).

- long:

  longitude column name in the output data (default `"lon"`).

- limit:

  maximum number of results to return per input address. Note that each
  query returns a maximum of 50 results.

- full_results:

  returns all available data from the API service. This is a shorthand
  of `outFields=*`. See **References**. If `FALSE` (default) only the
  default values of the API would be returned. See also
  `return_addresses` argument.

- return_addresses:

  return input addresses with results if `TRUE`.

- verbose:

  if `TRUE` then detailed logs are output to the console.

- progressbar:

  Logical. If `TRUE` displays a progress bar to indicate the progress of
  the function.

- outsr:

  The spatial reference of the `x,y` coordinates returned by a geocode
  request. By default is `NULL` (i.e. the parameter won't be used in the
  query). See **Details** and
  [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

- langcode:

  Sets the language in which reverse-geocoded addresses are returned.

- sourcecountry:

  Limits the candidates returned to the specified country or countries.
  Acceptable values include the three-character country code. You can
  specify multiple country codes to limit results to more than one
  country.

- category:

  A place or address type that can be used to filter results. Several
  values can be used as well as a vector (i.e. `c("Cinema", "Museum")`).
  See
  [arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)
  for details.

- custom_query:

  API-specific parameters to be used, passed as a named list.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) object
with the results. See the details of the output in [ArcGIS REST API
Service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

More info and valid values in the [ArcGIS REST
docs](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm).

## `outsr`

The spatial reference can be specified as either a well-known ID (WKID).
If not specified, the spatial reference of the output locations is the
same as that of the service ( WGS84, i.e. WKID = 4326)).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## References

[ArcGIS REST
`findAddressCandidates`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm).

## See also

[`tidygeocoder::geo()`](https://jessecambon.github.io/tidygeocoder/reference/geo.html)

Other functions for geocoding:
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
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# Several addresses with additional output fields
with_params <- arc_geo(c("Madrid", "Barcelona"),
  custom_query = list(outFields = c("LongLabel", "CntryName"))
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%

with_params %>%
  select(lat, lon, CntryName, LongLabel)
#> # A tibble: 2 × 4
#>     lat   lon CntryName LongLabel                       
#>   <dbl> <dbl> <chr>     <chr>                           
#> 1  40.4 -3.70 España    Madrid, Comunidad de Madrid, ESP
#> 2  41.4  2.17 España    Barcelona, Cataluña, ESP        

# With options: restrict search to USA
with_params_usa <- arc_geo(c("Madrid", "Barcelona"),
  sourcecountry = "USA",
  custom_query = list(outFields = c("LongLabel", "CntryName"))
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%

with_params_usa %>%
  select(lat, lon, CntryName, LongLabel)
#> # A tibble: 2 × 4
#>     lat   lon CntryName     LongLabel         
#>   <dbl> <dbl> <chr>         <chr>             
#> 1  41.9 -93.8 United States Madrid, IA, USA   
#> 2  35.6 -94.5 United States Barcelona, AR, USA
# }
```
