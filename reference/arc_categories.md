# ArcGIS REST API category data base

Database of available categories that can be used for filtering results
provided by
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)
and
[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md)
in [`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
format.

## Format

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
376 rows and fields:

- level_1:

  Top-level category

- level_2:

  Second-level category

- level_3:

  Child-level category

## Source

[ArcGIS REST Category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm).

## Details

See [ArcGIS REST Category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
for details and examples.

The geocoding service allows users to search for and geocode many types
of addresses and places around the world. This simplifies the
application building process, as developers don't need to know what
types of places their users are searching for, because the service can
decipher that. However, due to this flexibility, it is possible for
ambiguous searches to match to many different places, and users may
sometimes receive unexpected results. For example, a search for a city
may match to a street name, or a search for an airport code may match to
a country abbreviation.

For such cases, the service provides the ability to filter out unwanted
geocode results with the `category` parameter. The `category` parameter
limits the types of places for which the service searches, thus
eliminating false positive matches and potentially speeding up the
search process.

The results shows a list of categories with three different hierarchy
levels (`level_1`, `level_2`, `level_3`). If a `level_1` category is
requested (i.e. `POI`) the child categories may be included also in the
results.

## Note

Data extracted on **10 January 2023**.

## See also

[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md),
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)

Other datasets:
[`arc_spatial_references`](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)

## Examples

``` r
# \donttest{
# Get all possible values
data("arc_categories")
arc_categories
#> # A tibble: 376 × 3
#>    level_1 level_2          level_3
#>    <chr>   <chr>            <chr>  
#>  1 Address Subaddress       NA     
#>  2 Address Point Address    NA     
#>  3 Address Street Address   NA     
#>  4 Address Distance Marker  NA     
#>  5 Address Intersection     NA     
#>  6 Address Street Midblock  NA     
#>  7 Address Street Name      NA     
#>  8 Postal  Primary Postal   NA     
#>  9 Postal  Postal Locality  NA     
#> 10 Postal  Postal Extension NA     
#> # ℹ 366 more rows

# Using categories

sea_1 <- arc_geo("sea",
  custom_query = list(outFields = c("LongLabel", "Type")),
  limit = 2
)


dplyr::glimpse(sea_1)
#> Rows: 2
#> Columns: 15
#> $ query      <chr> "sea", "sea"
#> $ lat        <dbl> 47.44362, 47.44899
#> $ lon        <dbl> -122.3029, -122.3093
#> $ address    <chr> "SEA", "SEA"
#> $ score      <int> 100, 100
#> $ x          <dbl> -122.3029, -122.3093
#> $ y          <dbl> 47.44362, 47.44899
#> $ LongLabel  <chr> "SEA, 17801 International Blvd, Seatac, WA, 98158, USA", "S…
#> $ Type       <chr> "Airport", "Airport"
#> $ xmin       <dbl> -122.3189, -122.3393
#> $ ymin       <dbl> 47.42762, 47.41899
#> $ xmax       <dbl> -122.2869, -122.2793
#> $ ymax       <dbl> 47.45962, 47.47899
#> $ wkid       <int> 4326, 4326
#> $ latestWkid <int> 4326, 4326

# An airport, but if we use categories...

sea_2 <- arc_geo("sea",
  custom_query = list(outFields = c("LongLabel", "Type")),
  limit = 2, category = "Food"
)

dplyr::glimpse(sea_2)
#> Rows: 2
#> Columns: 15
#> $ query      <chr> "sea", "sea"
#> $ lat        <dbl> 40.71816, 48.84329
#> $ lon        <dbl> -73.959946, -3.001996
#> $ address    <chr> "Sea", "Sea"
#> $ score      <int> 100, 100
#> $ x          <dbl> -73.959946, -3.001996
#> $ y          <dbl> 40.71816, 48.84329
#> $ LongLabel  <chr> "Sea, 114 N 6th St, Brooklyn, NY, 11249, USA", "Sea, Parc a…
#> $ Type       <chr> "Restaurant", "Restaurant"
#> $ xmin       <dbl> -73.960946, -3.006996
#> $ ymin       <dbl> 40.71716, 48.83829
#> $ xmax       <dbl> -73.958946, -2.996996
#> $ ymax       <dbl> 40.71916, 48.84829
#> $ wkid       <int> 4326, 4326
#> $ latestWkid <int> 4326, 4326

# We can use a list of categories
sea_3 <- arc_geo("sea",
  custom_query = list(outFields = c("LongLabel", "Type")),
  sourcecountry = "UK", limit = 5,
  category = c("Amusement Park", "Aquarium")
)

dplyr::glimpse(sea_3)
#> Rows: 1
#> Columns: 15
#> $ query      <chr> "sea"
#> $ lat        <dbl> 54.30124
#> $ lon        <dbl> -0.409833
#> $ address    <chr> "Sea Life Scarborough"
#> $ score      <dbl> 81.67
#> $ x          <dbl> -0.409833
#> $ y          <dbl> 54.30124
#> $ LongLabel  <chr> "Sea Life Scarborough, North Bay Promenade, Scarborough, No…
#> $ Type       <chr> "Aquarium"
#> $ xmin       <dbl> -0.414833
#> $ ymin       <dbl> 54.29624
#> $ xmax       <dbl> -0.404833
#> $ ymax       <dbl> 54.30624
#> $ wkid       <int> 4326
#> $ latestWkid <int> 4326
# }
```
