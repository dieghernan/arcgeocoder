# Reverse Geocoding using the ArcGIS REST API

Generates an address from a latitude and longitude. Latitudes must be in
the range \\\left\[-90, 90 \right\]\\ and longitudes in the range
\\\left\[-180, 180 \right\]\\. This function returns the
[tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
associated with the query.

## Usage

``` r
arc_reverse_geo(
  x,
  y,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  progressbar = TRUE,
  outsr = NULL,
  langcode = NULL,
  featuretypes = NULL,
  locationtype = NULL,
  custom_query = list()
)
```

## Arguments

- x:

  longitude values in numeric format. Must be in the range
  \\\left\[-180, 180 \right\]\\.

- y:

  latitude values in numeric format. Must be in the range \\\left\[-90,
  90 \right\]\\.

- address:

  address column name in the output data (default `"address"`).

- full_results:

  returns all available data from the API service. If `FALSE` (default)
  only latitude, longitude and address columns are returned.

- return_coords:

  return input coordinates with results if `TRUE`.

- verbose:

  if `TRUE` then detailed logs are output to the console.

- progressbar:

  Logical. If `TRUE` displays a progress bar to indicate the progress of
  the function.

- outsr:

  The spatial reference of the `x,y` coordinates returned by a geocode
  request. By default is `NULL` (i.e. the argument won't be used in the
  query). See **Details** and
  [arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md).

- langcode:

  Sets the language in which reverse-geocoded addresses are returned.

- featuretypes:

  This argument limits the possible match types returned. By default is
  `NULL` (i.e. the argument won't be used in the query). See
  **Details**.

- locationtype:

  Specifies whether the output geometry of
  `featuretypes = "PointAddress"` or `featuretypes = "Subaddress"`
  matches should be the rooftop point or street entrance location. Valid
  values are `NULL` (i.e. not using the argument in the query),
  `rooftop` and `street`.

- custom_query:

  API-specific arguments to be used, passed as a named list.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
with the corresponding results. The `x,y` values returned by the API are
named `lon,lat`. Note that these coordinates correspond to the geocoded
feature, and may be different from the `x,y` values provided as inputs.

See the details of the output in [ArcGIS REST API Service
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

More info and valid values in the [ArcGIS REST
docs](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm).

## `outsr`

The spatial reference can be specified as either a well-known ID (WKID).
If not specified, the spatial reference of the output locations is the
same as that of the service (WGS84, i.e. WKID = 4326)).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## `featuretypes`

See `vignette("featuretypes", package = "arcgeocoder")` for a detailed
explanation of this argument.

This argument may be used for filtering the type of feature to be
returned when geocoding. Possible values are:

- `"StreetInt"`

- `"DistanceMarker"`

- `"StreetAddress"`

- `"StreetName"`

- `"POI"`

- `"Subaddress"`

- `"PointAddress"`

- `"Postal"`

- `"Locality"`

It is also possible to use several values as a vector
(`featuretypes = c("PointAddress", "StreetAddress")`).

## References

[ArcGIS REST
`reverseGeocode`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm).

## See also

[`tidygeocoder::reverse_geo()`](https://jessecambon.github.io/tidygeocoder/reference/reverse_geo.html)

Other functions for geocoding:
[`arc_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo.md),
[`arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.md),
[`arc_geo_multi()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_multi.md)

## Examples

``` r
# \donttest{

arc_reverse_geo(x = -73.98586, y = 40.75728)
#> # A tibble: 1 × 3
#>       x     y address                                    
#>   <dbl> <dbl> <chr>                                      
#> 1 -74.0  40.8 178-198 W 44th St, New York, NY, 10036, USA

# Several coordinates
arc_reverse_geo(x = c(-73.98586, -3.188375), y = c(40.75728, 55.95335))
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 3
#>        x     y address                                                          
#>    <dbl> <dbl> <chr>                                                            
#> 1 -74.0   40.8 178-198 W 44th St, New York, NY, 10036, USA                      
#> 2  -3.19  56.0 Microsoft, 3 Waterloo Place, Canongate, Edinburgh, Midlothian, S…

# With options: using some additional arguments
sev <- arc_reverse_geo(
  x = c(-73.98586, -3.188375),
  y = c(40.75728, 55.95335),
  # Restrict to these features
  featuretypes = "POI,StreetInt",
  # Result on this WKID
  outsr = 102100,
  verbose = TRUE, full_results = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%
#> 
#> Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
#> Parameters:
#>    - location=-73.98586,40.75728
#>    - f=json
#>    - outSR=102100
#>    - featureTypes=POI,StreetInt
#> url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-73.98586,40.75728&f=json&outSR=102100&featureTypes=POI,StreetInt
#>   |                                                          |==================================================| 100%
#> 
#> Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
#> Parameters:
#>    - location=-3.188375,55.95335
#>    - f=json
#>    - outSR=102100
#>    - featureTypes=POI,StreetInt
#> url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-3.188375,55.95335&f=json&outSR=102100&featureTypes=POI,StreetInt
#> 

dplyr::glimpse(sev)
#> Rows: 2
#> Columns: 39
#> $ x            <dbl> -73.985860, -3.188375
#> $ y            <dbl> 40.75728, 55.95335
#> $ address      <chr> "W 44th St & Broadway, New York, NY, 10036, USA", "Micros…
#> $ lat          <dbl> 4976603, 7549135
#> $ lon          <dbl> -8236060.8, -354915.4
#> $ Match_addr   <chr> "W 44th St & Broadway, New York, New York, 10036", "Micro…
#> $ LongLabel    <chr> "W 44th St & Broadway, New York, NY, 10036, USA", "Micros…
#> $ ShortLabel   <chr> "W 44th St & Broadway", "Microsoft"
#> $ Addr_type    <chr> "StreetInt", "POI"
#> $ Type         <chr> NA, "Consumer Electronics Store"
#> $ PlaceName    <chr> NA, "Microsoft"
#> $ AddNum       <chr> NA, "3"
#> $ Address      <chr> "W 44th St & Broadway", "3 Waterloo Place"
#> $ Block        <chr> NA, NA
#> $ Sector       <chr> NA, NA
#> $ Neighborhood <chr> "Midtown", "Canongate"
#> $ District     <chr> "Manhattan", NA
#> $ City         <chr> "New York", "Edinburgh"
#> $ MetroArea    <chr> NA, "Edinburgh"
#> $ Subregion    <chr> "New York County", "Midlothian"
#> $ Region       <chr> "New York", "Scotland"
#> $ RegionAbbr   <chr> "NY", "SCT"
#> $ Territory    <chr> NA, NA
#> $ Postal       <chr> "10036", "EH1 3EG"
#> $ PostalExt    <chr> "4011", NA
#> $ CntryName    <chr> "United States", "United Kingdom"
#> $ CountryCode  <chr> "USA", "GBR"
#> $ X            <dbl> -73.985793, -3.188259
#> $ Y            <dbl> 40.75726, 55.95335
#> $ InputX       <dbl> -73.985860, -3.188375
#> $ InputY       <dbl> 40.75728, 55.95335
#> $ StrucType    <chr> NA, NA
#> $ StrucDet     <chr> NA, NA
#> $ StrucType1   <chr> NA, NA
#> $ StrucType2   <chr> NA, NA
#> $ StrucDet1    <chr> NA, NA
#> $ StrucDet2    <chr> NA, NA
#> $ wkid         <int> 102100, 102100
#> $ latestWkid   <int> 3857, 3857
# }
```
