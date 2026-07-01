# Reverse geocode coordinates with the ArcGIS REST API

Converts longitude and latitude values into addresses. Latitudes must be
in the range \\\left\[-90, 90 \right\]\\ and longitudes in the range
\\\left\[-180, 180 \right\]\\. Returns one match for each coordinate
pair.

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

  A numeric vector of longitude values in the range \\\left\[-180, 180
  \right\]\\.

- y:

  A numeric vector of latitude values in the range \\\left\[-90, 90
  \right\]\\.

- address:

  Name of the address column in the output. The default is `"address"`.

- full_results:

  A logical value. If `TRUE`, returns all available API fields. The
  default, `FALSE`, returns latitude, longitude and address only.

- return_coords:

  A logical value. If `TRUE`, returns input coordinates with the
  results.

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

- featuretypes:

  A character vector that limits the possible match types. The default
  is `NULL`, which does not filter by feature type. See **Details**.

- locationtype:

  Specifies whether the output geometry of
  `featuretypes = "PointAddress"` or `featuretypes = "Subaddress"`
  matches should be the rooftop point or street entrance location. The
  default is `NULL`. Other valid values are `"rooftop"` and `"street"`.

- custom_query:

  A named list with additional API parameters.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with one
match for each coordinate pair. The API output fields `x` and `y` are
named `lon` and `lat`. These coordinates correspond to the matched
feature and may differ from the input `x` and `y` values.

See the details of the output in [ArcGIS REST API
output](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-service-output.htm).

## Details

See the [ArcGIS REST API
documentation](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm)
for more information and valid values.

## `outsr`

The spatial reference can be specified as a well-known ID (WKID). If not
specified, the spatial reference of the output locations is the same as
that of the service (WGS 84, that is, WKID 4326).

See
[arc_spatial_references](https://dieghernan.github.io/arcgeocoder/reference/arc_spatial_references.md)
for values and examples.

## `featuretypes`

See `vignette("featuretypes", package = "arcgeocoder")` for a detailed
explanation of this argument.

This argument restricts the feature types returned by a reverse
geocoding request. Possible values are `"StreetInt"`,
`"DistanceMarker"`, `"StreetAddress"`, `"StreetName"`, `"POI"`,
`"Subaddress"`, `"PointAddress"`, `"Postal"` and `"Locality"`.

Supply multiple values as a character vector, for example,
`c("PointAddress", "StreetAddress")`.

## References

[ArcGIS REST API
`reverseGeocode`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm).

## See also

Geocoding and reverse geocoding functions:
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

# Several coordinate pairs.
arc_reverse_geo(x = c(-73.98586, -3.188375), y = c(40.75728, 55.95335))
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 3
#>        x     y address                                                          
#>    <dbl> <dbl> <chr>                                                            
#> 1 -74.0   40.8 178-198 W 44th St, New York, NY, 10036, USA                      
#> 2  -3.19  56.0 Thistle & Churn Ice Cream, 1 Waterloo Place, Canongate, Edinburg…

# Use additional API options.
sev <- arc_reverse_geo(
  x = c(-73.98586, -3.188375),
  y = c(40.75728, 55.95335),
  # Restrict to these features.
  featuretypes = "POI,StreetInt",
  # Return results in this WKID.
  outsr = 102100,
  verbose = TRUE, full_results = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%
#> 
#> Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
#> Parameters:
#>    - location=-73.98586,40.75728
#>    - f=json
#>    - outSR=102100
#>    - featureTypes=POI,StreetInt
#> URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-73.98586,40.75728&f=json&outSR=102100&featureTypes=POI,StreetInt
#>   |                                                          |==================================================| 100%
#> 
#> Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
#> Parameters:
#>    - location=-3.188375,55.95335
#>    - f=json
#>    - outSR=102100
#>    - featureTypes=POI,StreetInt
#> URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-3.188375,55.95335&f=json&outSR=102100&featureTypes=POI,StreetInt
#> 

dplyr::glimpse(sev)
#> Rows: 2
#> Columns: 39
#> $ x            <dbl> -73.985860, -3.188375
#> $ y            <dbl> 40.75728, 55.95335
#> $ address      <chr> "W 44th St & Broadway, New York, NY, 10036, USA", "Thistl…
#> $ lat          <dbl> 4976603, 7549116
#> $ lon          <dbl> -8236060.8, -354916.9
#> $ Match_addr   <chr> "W 44th St & Broadway, New York, New York, 10036", "Thist…
#> $ LongLabel    <chr> "W 44th St & Broadway, New York, NY, 10036, USA", "Thistl…
#> $ ShortLabel   <chr> "W 44th St & Broadway", "Thistle & Churn Ice Cream"
#> $ Addr_type    <chr> "StreetInt", "POI"
#> $ Type         <chr> "", "Restaurant"
#> $ PlaceName    <chr> "", "Thistle & Churn Ice Cream"
#> $ AddNum       <chr> "", "1"
#> $ Address      <chr> "W 44th St & Broadway", "1 Waterloo Place"
#> $ Block        <chr> "", ""
#> $ Sector       <chr> "", ""
#> $ Neighborhood <chr> "Midtown", "Canongate"
#> $ District     <chr> "Manhattan", ""
#> $ City         <chr> "New York", "Edinburgh"
#> $ MetroArea    <chr> "", "Edinburgh"
#> $ Subregion    <chr> "New York County", "Midlothian"
#> $ Region       <chr> "New York", "Scotland"
#> $ RegionAbbr   <chr> "NY", "SCT"
#> $ Territory    <chr> "", ""
#> $ Postal       <chr> "10036", "EH1 3EG"
#> $ PostalExt    <chr> "4011", ""
#> $ CntryName    <chr> "United States", "United Kingdom"
#> $ CountryCode  <chr> "USA", "GBR"
#> $ X            <dbl> -73.985793, -3.188273
#> $ Y            <dbl> 40.75726, 55.95325
#> $ InputX       <dbl> -73.985860, -3.188375
#> $ InputY       <dbl> 40.75728, 55.95335
#> $ StrucType    <chr> "", ""
#> $ StrucDet     <chr> "", ""
#> $ StrucType1   <chr> "", NA
#> $ StrucType2   <chr> "", NA
#> $ StrucDet1    <chr> "", NA
#> $ StrucDet2    <chr> "", NA
#> $ wkid         <int> 102100, 102100
#> $ latestWkid   <int> 3857, 3857
# }
```
