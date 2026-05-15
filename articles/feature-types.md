# Reverse geocoding and feature types

*Adapted from the
<https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm>*

## Reverse geocoding details

The purpose of reverse geocoding is to answer the question: What is near
this location? To answer this question, the `reverseGeocode` operation
provided by the **ArcGIS REST API** returns the most relevant feature
near an input location based on a prioritized hierarchy of feature
types.

The hierarchy is summarized in the table below, ordered by descending
priority. Unless otherwise noted, each feature type is returned only
when the distance between the input location and the feature is within
the tolerance specified in the *Search Tolerance* column.

| Feature type | Search tolerance | Comments |
|----|----|----|
| `StreetInt` | 10 meters | Intersections are only returned when `featuretypes = "StreetInt"` is included in the request. |
| `StreetAddress` (near), `DistanceMarker`, or `StreetName` | 3 meters | Candidates of type `StreetName` are only returned if `featureTypes = "streetName"` is included in the request. |
| `POI` centroid | 25 meters | A business or landmark that can be represented by a point. |
| `Subaddress` | 10 meters | `Subaddress` candidates, which can be features such as apartments or floors in a building, may not be returned under certain conditions. |
| `PointAddress` | 50 meters | A `PointAddress` match is not returned if it is on the opposite side of the street as the input location, even if it is within 50 meters of the location. |
| `StreetAddress` (distant), `DistanceMarker`, or `StreetName` | 100 meters | Candidates of type `StreetName` are only returned if `featuretypes = "StreetName"` is included in the request. |
| `POI` area | within boundary | A business or landmark that can be represented by an area, such as a large park or university. Not available in all countries. |
| `Postal` or `Locality` area | within boundary | If the input location intersects multiple boundaries, the feature with the smallest area is returned. |

Table 1: Adapted from ArcGIS REST API `reverseGeocode`

In **arcgeocoder**, this hierarchy is implemented in
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md),
specifically through the `featuretypes` argument. The default value
(`featuretypes = NULL`) does not include the argument in the API call.
In this case, the hierarchy presented in the previous table would apply.

It is possible to narrow down the output of the query to a specific
feature type or a list of feature types. The possible values supported
for this argument are:

- `"StreetInt"`
- `"DistanceMarker"`
- `"StreetAddress"`
- `"StreetName"`
- `"POI"`
- `"Subaddress"`
- `"PointAddress"`
- `"Postal"`
- `"Locality"`

As mentioned, it is possible to include several feature types. If more
than one value is specified for the argument, the values must be
separated by a comma, with no spaces after the comma.

### Single `featuretypes` value

``` r

arc_reverse_geo(..., featuretypes = "PointAddress")
```

### Multiple `featuretypes` values

``` r

arc_reverse_geo(..., featuretypes = c("PointAddress", "StreetAddress"))
```

## Examples

The following examples show different scenarios.

``` r

library(arcgeocoder)
library(dplyr)
```

### Example 1: Match to `POI` centroid returned

In this example, we do not provide any value to the `featuretypes`
argument. This input location is within the search tolerance of both
`POI` and `PointAddress` features, but a match to the `POI` centroid is
returned because it has a higher priority (see [Table 1](#tbl-hier)).
Note that the output field `Addr_type` indicates the type of feature.

``` r

example_x <- -117.196324
example_y <- 34.059217

api_poi <- arc_reverse_geo(
  x = example_x,
  y = example_y,
  langcode = "EN",
  full_results = TRUE,
  verbose = TRUE
)

api_poi |>
  select(x, y, address, lon, lat, Addr_type) |>
  knitr::kable()
```

| x | y | address | lon | lat | Addr_type |
|---:|---:|:---|---:|---:|:---|
| -117.1963 | 34.05922 | 1025-1141 W Park Ave, Redlands, CA, 92373, USA | -117.1963 | 34.05917 | StreetAddress |

### Example 2: `StreetAddress` match returned

Here, we specify the type of feature to return using
`featuretypes = "StreetAddress"`.

``` r

api_address <- arc_reverse_geo(
  x = example_x,
  y = example_y,
  featuretypes = "StreetAddress",
  langcode = "EN",
  full_results = TRUE,
  verbose = TRUE
)

api_address |>
  select(x, y, address, lon, lat, Addr_type) |>
  knitr::kable()
```

| x | y | address | lon | lat | Addr_type |
|---:|---:|:---|---:|---:|:---|
| -117.1963 | 34.05922 | 1025-1141 W Park Ave, Redlands, CA, 92373, USA | -117.1963 | 34.05917 | StreetAddress |

### Example 3: `Locality` match returned

``` r

api_local <- arc_reverse_geo(
  x = example_x,
  y = example_y,
  featuretypes = "Locality",
  langcode = "EN",
  full_results = TRUE,
  verbose = TRUE
)

api_local |>
  select(x, y, address, lon, lat, Addr_type) |>
  knitr::kable()
```

|         x |        y | address           |       lon |      lat | Addr_type |
|----------:|---------:|:------------------|----------:|---------:|:----------|
| -117.1963 | 34.05922 | Redlands, CA, USA | -117.1963 | 34.05922 | Locality  |

### Example 4: Multiple values

When multiple values are included in the API call, the hierarchy
explained in [Table 1](#tbl-hier) is still applied to the requested
`featuretypes`.

``` r

api_multiple <- arc_reverse_geo(
  x = example_x,
  y = example_y,
  featuretypes = c("Locality", "StreetInt", "StreetAddress"),
  langcode = "EN",
  full_results = TRUE,
  verbose = TRUE
)

api_multiple |>
  select(x, y, address, lon, lat, Addr_type) |>
  knitr::kable()
```

| x | y | address | lon | lat | Addr_type |
|---:|---:|:---|---:|---:|:---|
| -117.1963 | 34.05922 | 1025-1141 W Park Ave, Redlands, CA, 92373, USA | -117.1963 | 34.05917 | StreetAddress |

### Example 5: No results for specific `featuretypes`

The following example presents a case where only certain `featuretypes`
are near the requested location. In this case, when reverse geocoding
the North Pole, the API would return a `Locality`, but no
`StreetAddress` is found.

When it is not possible to return results,
[`arc_reverse_geo()`](https://dieghernan.github.io/arcgeocoder/reference/arc_reverse_geo.md)
returns an empty **tibble**.

``` r

# North Pole

npole <- arc_reverse_geo(x = 0, y = 90, langcode = "EN", full_results = TRUE)

npole |>
  select(x, y, address, lon, lat, Addr_type) |>
  knitr::kable()
```

|   x |   y | address        | lon | lat | Addr_type |
|----:|----:|:---------------|----:|----:|:----------|
|   0 |  90 | Ozero Shybyndy |   0 |  90 | POI       |

``` r

# But no `StreetAddress`.
npole2 <- arc_reverse_geo(
  x = 0,
  y = 90,
  langcode = "EN",
  full_results = TRUE,
  featuretypes = "StreetAddress"
)

npole2 |>
  knitr::kable()
```

|   x |   y | address |
|----:|----:|:--------|
|   0 |  90 | NA      |

## Conclusion

The API can return different results for the same `x` and `y` values
depending on the value of `featuretypes`. When `featuretypes = NULL`,
the feature type returned depends on the hierarchy shown in
[Table 1](#tbl-hier).

Depending on the location, the `featuretypes` filter may not return
results, so using `featuretypes = NULL` is safer for general purposes.
