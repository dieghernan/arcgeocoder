# Geocoding using the ArcGIS REST API with multi-field query

Geocodes addresses given specific address components. This function
returns the
[tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
associated with the query.

For geocoding using a single text string use
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md)
function.

## Usage

``` r
arc_geo_multi(
  address = NULL,
  address2 = NULL,
  address3 = NULL,
  neighborhood = NULL,
  city = NULL,
  subregion = NULL,
  region = NULL,
  postal = NULL,
  postalext = NULL,
  countrycode = NULL,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  progressbar = TRUE,
  outsr = NULL,
  langcode = NULL,
  category = NULL,
  custom_query = list()
)
```

## Arguments

- address, address2, address3, neighborhood, city, subregion:

  Address components. See **Details**.

- region, postal, postalext, countrycode:

  Additional address components. See **Details**.

- lat:

  Latitude column name in the output data (default `"lat"`).

- long:

  Longitude column name in the output data (default `"lon"`).

- limit:

  Maximum number of results to return per input address. Each query has
  a hard API limit of 50 results.

- full_results:

  Logical; if `TRUE` return all available API fields via `outFields=*`.
  Default is `FALSE`.

- return_addresses:

  Logical; if `TRUE` keep input query in output.

- verbose:

  Logical; if `TRUE` output process messages to console.

- progressbar:

  Logical; if `TRUE` shows a progress bar for multiple points.

- outsr:

  The spatial reference of the `x,y` coordinates returned by a geocode
  request. By default is `NULL` (i.e. the argument won't be used in the
  query). See **Details** and
  [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

- langcode:

  Sets the language in which reverse-geocoded addresses are returned.

- category:

  Place or address type used as a filter. Multiple values are accepted
  (e.g. `c("Cinema", "Museum")`). See
  [arc_categories](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md).

- custom_query:

  Additional API parameters as named list values.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
object with the results. See the details of the output in [ArcGIS REST
API Service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

The resulting output will include also the input arguments (columns with
prefix `q_`) for better tracking the results.

## Details

See the [ArcGIS REST
docs](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm)
for more info and valid values.

## Address components

This function allows performing structured queries by different
components of an address. At least one field should be different than
`NA` or `NULL`.

A vector of values can be provided for each argument for multiple
geocoding. When using vectors on different arguments, their lengths
should be the same.

The following list provides a brief description of each argument:

- `address`: A string that represents the first line of a street
  address. In most cases it will be the **street name and house number**
  input, but it can also be used to input building name or place-name.

- `address2`: A string that represents the second line of a street
  address. This can include **street name/house number, building name,
  place-name, or sub unit**.

- `address3`: A string that represents the third line of a street
  address. This can include **street name/house number, building name,
  place-name, or sub unit**.

- `neighborhood`: The smallest administrative division associated with
  an address, typically, a **neighborhood** or a section of a larger
  populated place.

- `city`: The next largest administrative division associated with an
  address, typically, a **city or municipality**.

- `subregion`: The next largest administrative division associated with
  an address. Depending on the country, a sub region can represent a
  **county, state, or province**.

- `region`: The largest administrative division associated with an
  address, typically, a **state or province**.

- `postal`: The **standard postal code** for an address, typically, a
  three– to six-digit alphanumeric code.

- `postalext`: A **postal code extension**, such as the United States
  Postal Service ZIP+4 code.

- `countrycode`: A value representing the **country**. Providing this
  value **increases geocoding speed**. Acceptable values include the
  full country name in English or the official language of the country,
  the two-character country code, or the three-character country code.

## `outsr`

The spatial reference can be specified as either a well-known ID (WKID).
If not specified, the spatial reference of the output locations is the
same as that of the service (WGS84, i.e. WKID = 4326)).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## References

[ArcGIS REST
`findAddressCandidates`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm)

## See also

[`tidygeocoder::geo()`](https://jessecambon.github.io/tidygeocoder/reference/geo.html)

Other functions for geocoding:
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md),
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md)

## Examples

``` r
# \donttest{
simple <- arc_geo_multi(
  address = "Plaza Mayor", limit = 10,
  custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
)

library(dplyr)

simple |>
  select(lat, lon, CntryName, Region, LongLabel) |>
  slice_head(n = 10)
#> # A tibble: 10 × 5
#>      lat    lon CntryName Region          LongLabel                             
#>    <dbl>  <dbl> <chr>     <chr>           <chr>                                 
#>  1 41.7   -4.73 España    Castilla y León Plaza Mayor, Valladolid, Castilla y L…
#>  2 39.5   -6.37 España    Extremadura     Plaza Mayor, Cáceres, Extremadura, ESP
#>  3 36.7   -4.48 España    Andalucía       Plaza Mayor, Calle Alfonso Ponce de L…
#>  4  6.24 -75.6  Colombia  Antioquia       Plaza Mayor, Calle Nueva, Medellín, A…
#>  5  5.63 -73.5  Colombia  Boyacá          Plaza Mayor, Villa de Leyva, Boyacá, …
#>  6 21.8  -80.0  Cuba      Sancti Spíritus Plaza Mayor, Trinidad, Sancti Spíritu…
#>  7 37.1   -2.78 España    Andalucía       Plaza Mayor, Plaza Mayor 3, 04510, Ab…
#>  8 37.0   -2.95 España    Andalucía       Plaza Mayor, Plaza Mayor 9, 04479, Pa…
#>  9 37.2   -1.87 España    Andalucía       Plaza Mayor, Calle de Juan Anglada 5,…
#> 10 38.2   -3.77 España    Andalucía       Plaza Mayor, Calle de la Conquista 3,…

# Restrict search to Spain
simple2 <- arc_geo_multi(
  address = "Plaza Mayor", countrycode = "ESP",
  limit = 10,
  custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
)

simple2 |>
  select(lat, lon, CntryName, Region, LongLabel) |>
  slice_head(n = 10)
#> # A tibble: 10 × 5
#>      lat    lon CntryName Region          LongLabel                             
#>    <dbl>  <dbl> <chr>     <chr>           <chr>                                 
#>  1  41.7 -4.73  España    Castilla y León Plaza Mayor, Valladolid, Castilla y L…
#>  2  39.5 -6.37  España    Extremadura     Plaza Mayor, Cáceres, Extremadura, ESP
#>  3  36.7 -4.48  España    Andalucía       Plaza Mayor, Calle Alfonso Ponce de L…
#>  4  37.1 -2.78  España    Andalucía       Plaza Mayor, Plaza Mayor 3, 04510, Ab…
#>  5  37.0 -2.95  España    Andalucía       Plaza Mayor, Plaza Mayor 9, 04479, Pa…
#>  6  37.2 -1.87  España    Andalucía       Plaza Mayor, Calle de Juan Anglada 5,…
#>  7  38.2 -3.77  España    Andalucía       Plaza Mayor, Calle de la Conquista 3,…
#>  8  42.4  0.139 España    Aragón          Plaza Mayor, Plaza Mayor 6, 22330, Aí…
#>  9  42.0  0.258 España    Aragón          Plaza Mayor, 22422, Fonz, Huesca, Ara…
#> 10  42.5  0.135 España    Aragón          Plaza Mayor, 22360, Labuerda, Huesca,…

# Restrict to a region
simple3 <- arc_geo_multi(
  address = "Plaza Mayor", region = "Segovia",
  countrycode = "ESP",
  limit = 10,
  custom_query = list(outFields = c("LongLabel", "CntryName", "Region"))
)

simple3 |>
  select(lat, lon, CntryName, Region, LongLabel) |>
  slice_head(n = 10)
#> # A tibble: 10 × 5
#>      lat   lon CntryName Region          LongLabel                              
#>    <dbl> <dbl> <chr>     <chr>           <chr>                                  
#>  1  41.2 -4.52 España    Castilla y León Plaza Mayor, Plaza Mayor 5, 40480, Coc…
#>  2  41.2 -4.56 España    Castilla y León Plaza Mayor, Carretera de Estación de …
#>  3  41.4 -4.31 España    Castilla y León Plaza Mayor, Calle del Colegio 4, 4020…
#>  4  41.1 -4.38 España    Castilla y León Plaza Mayor, Calle Migueláñez 1, 40495…
#>  5  40.9 -4.35 España    Castilla y León Plaza Mayor, Camino de Marugán, 40142,…
#>  6  41.0 -4.60 España    Castilla y León Plaza Mayor, Plaza Mayor 20, 40446, Ma…
#>  7  41.1 -3.81 España    Castilla y León Plaza Mayor, Plaza Mayor 6, 40173, Ped…
#>  8  41.3 -3.34 España    Castilla y León Plaza Mayor, Travesía Mayor 1, 40510, …
#>  9  41.0 -4.12 España    Castilla y León Plaza Mayor, Plaza Mayor 1, 40001, Seg…
#> 10  41.1 -4.00 España    Castilla y León Plaza Mayor, Camino de Turégano, 40181…
# }
```
