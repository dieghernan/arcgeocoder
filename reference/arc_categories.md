# Place categories supported by the ArcGIS REST API

A dataset of categories that can be used to filter results from
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)
and
[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md).

## Format

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with 383
rows and three variables:

- level_1:

  Top-level category.

- level_2:

  Second-level category.

- level_3:

  Child-level category.

## Source

[ArcGIS REST API category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm).

## Details

See [ArcGIS REST API category
filtering](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-category-filtering.htm)
for details and examples.

The ArcGIS geocoding service supports searches for many types of
addresses and places around the world. This simplifies application
development because developers do not need to know what types of places
their users are searching for. However, ambiguous searches can match
many different places and produce unexpected results. For example, a
search for a city may match a street name, or an airport code may match
a country abbreviation.

In these cases, the `category` argument can filter out unwanted results.
It limits the types of places that the service searches for, which can
eliminate false-positive matches and speed up the search.

The dataset lists categories at three hierarchy levels (`level_1`,
`level_2` and `level_3`). If a `level_1` category is requested (for
example, `POI`), its child categories may also be included in the
results.

## Note

Data extracted on **15 January 2026**.

## See also

[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md),
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)

Other datasets:
[`arc_spatial_references`](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)

## Examples

``` r
# \donttest{
# Get all possible values.
data("arc_categories")
arc_categories
#> # A tibble: 383 × 3
#>    level_1 level_2         level_3
#>    <chr>   <chr>           <chr>  
#>  1 Address Subaddress      NA     
#>  2 Address Point Address   NA     
#>  3 Address Street Address  NA     
#>  4 Address Distance Marker NA     
#>  5 Address Intersection    NA     
#>  6 Address Street Midblock NA     
#>  7 Address Street Between  NA     
#>  8 Address Street Name     NA     
#>  9 Postal  Primary Postal  NA     
#> 10 Postal  Postal Locality NA     
#> # ℹ 373 more rows

# Use categories.

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
#> $ LongLabel  <chr> "SEA, 17801 International Blvd, Seattle, WA, 98158, USA", "…
#> $ Type       <chr> "Airport", "Airport"
#> $ xmin       <dbl> -122.3189, -122.3393
#> $ ymin       <dbl> 47.42762, 47.41899
#> $ xmax       <dbl> -122.2869, -122.2793
#> $ ymax       <dbl> 47.45962, 47.47899
#> $ wkid       <int> 4326, 4326
#> $ latestWkid <int> 4326, 4326

# Categories can disambiguate the result.

sea_2 <- arc_geo("sea",
  custom_query = list(outFields = c("LongLabel", "Type")),
  limit = 2, category = "Food"
)

dplyr::glimpse(sea_2)
#> Rows: 2
#> Columns: 15
#> $ query      <chr> "sea", "sea"
#> $ lat        <dbl> 40.71816, 47.86564
#> $ lon        <dbl> -73.959946, -4.221409
#> $ address    <chr> "Sea", "Sea"
#> $ score      <int> 100, 100
#> $ x          <dbl> -73.959946, -4.221409
#> $ y          <dbl> 40.71816, 47.86564
#> $ LongLabel  <chr> "Sea, 114 N 6th St, Brooklyn, NY, 11249, USA", "Sea, 6 Rue …
#> $ Type       <chr> "Restaurant", "Restaurant"
#> $ xmin       <dbl> -73.960946, -4.226409
#> $ ymin       <dbl> 40.71716, 47.86064
#> $ xmax       <dbl> -73.958946, -4.216409
#> $ ymax       <dbl> 40.71916, 47.87064
#> $ wkid       <int> 4326, 4326
#> $ latestWkid <int> 4326, 4326

# Use a list of categories.
sea_3 <- arc_geo("sea",
  custom_query = list(outFields = c("LongLabel", "Type")),
  sourcecountry = "UK", limit = 5,
  category = c("Amusement Park", "Aquarium")
)

dplyr::glimpse(sea_3)
#> Rows: 5
#> Columns: 15
#> $ query      <chr> "sea", "sea", "sea", "sea", "sea"
#> $ lat        <dbl> 50.81961, 53.81288, 53.46756, 52.93494, 54.30120
#> $ lon        <dbl> -0.135754, -3.054875, -2.340909, 0.483427, -0.409800
#> $ address    <chr> "Sea Life Brighton", "Sea Life Blackpool", "Sea Life Manche…
#> $ score      <dbl> 82.00, 81.88, 81.76, 81.76, 81.76
#> $ x          <dbl> -0.135754, -3.054875, -2.340909, 0.483427, -0.409800
#> $ y          <dbl> 50.81961, 53.81288, 53.46756, 52.93494, 54.30120
#> $ LongLabel  <chr> "Sea Life Brighton, 1 Marine Parade, Queen's Park, Brighton…
#> $ Type       <chr> "Aquarium", "Aquarium", "Aquarium", "Aquarium", "Aquarium"
#> $ xmin       <dbl> -0.140754, -3.059875, -2.345909, 0.478427, -0.414800
#> $ ymin       <dbl> 50.81461, 53.80788, 53.46256, 52.92994, 54.29620
#> $ xmax       <dbl> -0.130754, -3.049875, -2.335909, 0.488427, -0.404800
#> $ ymax       <dbl> 50.82461, 53.81788, 53.47256, 52.93994, 54.30620
#> $ wkid       <int> 4326, 4326, 4326, 4326, 4326
#> $ latestWkid <int> 4326, 4326, 4326, 4326, 4326
# }
```
