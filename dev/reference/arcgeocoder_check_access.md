# Check access to the ArcGIS REST API

Checks whether the current R session can access the ArcGIS REST API at
<https://developers.arcgis.com/rest/geocode/api-reference/overview-world-geocoding-service.htm>.

## Usage

``` r
arcgeocoder_check_access()
```

## Value

A [logical](https://rdrr.io/r/base/logical.html) value, `TRUE` if the
service is accessible, otherwise `FALSE`.

## Examples

``` r
# \donttest{
arcgeocoder_check_access()
#> [1] TRUE
# }
```
