# ESRI (ArcGIS) Spatial Reference data base

Database of available spatial references (CRS) in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

## Format

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
9,364 rows and fields:

- projtype:

  Projection type
  (`"ProjectedCoordinateSystems", "GeographicCoordinateSystems","VerticalCoordinateSystems"`)

- wkid:

  Well-Known ID

- latestWkid:

  Most recent `wkid`, in case that `wkid` is deprecated

- authority:

  `wkid` authority (Esri or EPSG)

- deprecated:

  Logical indicating if `wkid` is deprecated

- description:

  Human-readable description of the `wkid`

- areaname:

  Use area of the `wkid`

- wkt:

  Representation of `wkid` in Well-Known Text (WKT). Useful when working
  with [sf](https://CRAN.R-project.org/package=sf) or
  [terra](https://CRAN.R-project.org/package=terra)

## Source

[ESRI Projection Engine
factory](https://github.com/Esri/projection-engine-db-doc)

## Details

This data base is useful when using the `outsr` parameter of the
functions.

Some projections ids have changed over time, for example Web Mercator is
`wkid = 102100` is deprecated and currently is `wkid = 3857`. However,
both values would work, and they would return similar results.

## Note

Data extracted on **14 January 2023**.

## See also

[`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)

Other datasets:
[`arc_categories`](https://dieghernan.github.io/arcgeocoder/reference/arc_categories.md)

## Examples

``` r
# \donttest{
# Get all possible valuesdata("arc_spatial_references")
arc_spatial_references
#> # A tibble: 9,364 × 8
#>    projtype      wkid latestWkid authority deprecated description areaname wkt  
#>    <chr>        <int>      <int> <chr>     <lgl>      <chr>       <chr>    <chr>
#>  1 ProjectedCo…  2000       2000 EPSG      FALSE      Anguilla 1… Anguill… "PRO…
#>  2 ProjectedCo…  2001       2001 EPSG      FALSE      Antigua 19… Antigua… "PRO…
#>  3 ProjectedCo…  2002       2002 EPSG      FALSE      Dominica 1… Dominic… "PRO…
#>  4 ProjectedCo…  2003       2003 EPSG      FALSE      Grenada 19… Grenada… "PRO…
#>  5 ProjectedCo…  2004       2004 EPSG      FALSE      Montserrat… Montser… "PRO…
#>  6 ProjectedCo…  2005       2005 EPSG      FALSE      St Kitts 1… St Kitt… "PRO…
#>  7 ProjectedCo…  2006       2006 EPSG      FALSE      St Lucia 1… St Luci… "PRO…
#>  8 ProjectedCo…  2007       2007 EPSG      FALSE      St Vincent… St Vinc… "PRO…
#>  9 ProjectedCo…  2008       2008 EPSG      TRUE       NAD 1927 S… Canada … "PRO…
#> 10 ProjectedCo…  2009       2009 EPSG      FALSE      NAD 1927 S… Canada … "PRO…
#> # ℹ 9,354 more rows

# Request with deprecated Web Mercator
library(dplyr)
wkid <- arc_spatial_references |>
  filter(latestWkid == 3857 & deprecated == TRUE) |>
  slice(1)

glimpse(wkid)
#> Rows: 1
#> Columns: 8
#> $ projtype    <chr> "ProjectedCoordinateSystems"
#> $ wkid        <int> 102100
#> $ latestWkid  <int> 3857
#> $ authority   <chr> "Esri"
#> $ deprecated  <lgl> TRUE
#> $ description <chr> "WGS 1984 Web Mercator Major Auxiliary Sphere"
#> $ areaname    <chr> "World - 85~S to 85~N"
#> $ wkt         <chr> "PROJCS[\"WGS_1984_Web_Mercator_Auxiliary_Sphere\",GEOGCS[…

add <- arc_geo("London, United Kingdom", outsr = wkid$wkid)

# Note values lat, lon and wkid. latestwkid give the current valid wkid
add |>
  select(lat, lon, wkid, latestWkid) |>
  glimpse()
#> Rows: 1
#> Columns: 4
#> $ lat        <dbl> 6711544
#> $ lon        <dbl> -14215.35
#> $ wkid       <int> 102100
#> $ latestWkid <int> 3857

# See with sf

try(sf::st_crs(wkid$wkid))
#> Warning: GDAL Message 1: EPSG:102100 is not a valid CRS code, but ESRI:102100 is. Assuming ESRI:102100 was meant
#> Warning: GDAL Message 1: CRS EPSG:102100 is deprecated. Its non-deprecated replacement EPSG:3857 will be used instead. To use the original CRS, set the OSR_USE_NON_DEPRECATED configuration option to NO.
#> Coordinate Reference System:
#>   User input: EPSG:102100 
#>   wkt:
#> PROJCRS["WGS 84 / Pseudo-Mercator",
#>     BASEGEOGCRS["WGS 84",
#>         ENSEMBLE["World Geodetic System 1984 ensemble",
#>             MEMBER["World Geodetic System 1984 (Transit)"],
#>             MEMBER["World Geodetic System 1984 (G730)"],
#>             MEMBER["World Geodetic System 1984 (G873)"],
#>             MEMBER["World Geodetic System 1984 (G1150)"],
#>             MEMBER["World Geodetic System 1984 (G1674)"],
#>             MEMBER["World Geodetic System 1984 (G1762)"],
#>             MEMBER["World Geodetic System 1984 (G2139)"],
#>             MEMBER["World Geodetic System 1984 (G2296)"],
#>             ELLIPSOID["WGS 84",6378137,298.257223563,
#>                 LENGTHUNIT["metre",1]],
#>             ENSEMBLEACCURACY[2.0]],
#>         PRIMEM["Greenwich",0,
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>         ID["EPSG",4326]],
#>     CONVERSION["Popular Visualisation Pseudo-Mercator",
#>         METHOD["Popular Visualisation Pseudo Mercator",
#>             ID["EPSG",1024]],
#>         PARAMETER["Latitude of natural origin",0,
#>             ANGLEUNIT["degree",0.0174532925199433],
#>             ID["EPSG",8801]],
#>         PARAMETER["Longitude of natural origin",0,
#>             ANGLEUNIT["degree",0.0174532925199433],
#>             ID["EPSG",8802]],
#>         PARAMETER["False easting",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8806]],
#>         PARAMETER["False northing",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8807]]],
#>     CS[Cartesian,2],
#>         AXIS["easting (X)",east,
#>             ORDER[1],
#>             LENGTHUNIT["metre",1]],
#>         AXIS["northing (Y)",north,
#>             ORDER[2],
#>             LENGTHUNIT["metre",1]],
#>     USAGE[
#>         SCOPE["Web mapping and visualisation."],
#>         AREA["World between 85.06°S and 85.06°N."],
#>         BBOX[-85.06,-180,85.06,180]],
#>     ID["EPSG",3857]]

# But
try(sf::st_crs(wkid$latestWkid))
#> Coordinate Reference System:
#>   User input: EPSG:3857 
#>   wkt:
#> PROJCRS["WGS 84 / Pseudo-Mercator",
#>     BASEGEOGCRS["WGS 84",
#>         ENSEMBLE["World Geodetic System 1984 ensemble",
#>             MEMBER["World Geodetic System 1984 (Transit)"],
#>             MEMBER["World Geodetic System 1984 (G730)"],
#>             MEMBER["World Geodetic System 1984 (G873)"],
#>             MEMBER["World Geodetic System 1984 (G1150)"],
#>             MEMBER["World Geodetic System 1984 (G1674)"],
#>             MEMBER["World Geodetic System 1984 (G1762)"],
#>             MEMBER["World Geodetic System 1984 (G2139)"],
#>             MEMBER["World Geodetic System 1984 (G2296)"],
#>             ELLIPSOID["WGS 84",6378137,298.257223563,
#>                 LENGTHUNIT["metre",1]],
#>             ENSEMBLEACCURACY[2.0]],
#>         PRIMEM["Greenwich",0,
#>             ANGLEUNIT["degree",0.0174532925199433]],
#>         ID["EPSG",4326]],
#>     CONVERSION["Popular Visualisation Pseudo-Mercator",
#>         METHOD["Popular Visualisation Pseudo Mercator",
#>             ID["EPSG",1024]],
#>         PARAMETER["Latitude of natural origin",0,
#>             ANGLEUNIT["degree",0.0174532925199433],
#>             ID["EPSG",8801]],
#>         PARAMETER["Longitude of natural origin",0,
#>             ANGLEUNIT["degree",0.0174532925199433],
#>             ID["EPSG",8802]],
#>         PARAMETER["False easting",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8806]],
#>         PARAMETER["False northing",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8807]]],
#>     CS[Cartesian,2],
#>         AXIS["easting (X)",east,
#>             ORDER[1],
#>             LENGTHUNIT["metre",1]],
#>         AXIS["northing (Y)",north,
#>             ORDER[2],
#>             LENGTHUNIT["metre",1]],
#>     USAGE[
#>         SCOPE["Web mapping and visualisation."],
#>         AREA["World between 85.06°S and 85.06°N."],
#>         BBOX[-85.06,-180,85.06,180]],
#>     ID["EPSG",3857]]

# or
try(sf::st_crs(wkid$wkt))
#> Coordinate Reference System:
#>   User input: PROJCS["WGS_1984_Web_Mercator_Auxiliary_Sphere",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Mercator_Auxiliary_Sphere"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",0.0],PARAMETER["Standard_Parallel_1",0.0],PARAMETER["Auxiliary_Sphere_Type",0.0],UNIT["Meter",1.0]] 
#>   wkt:
#> PROJCRS["WGS 84 / Pseudo-Mercator",
#>     BASEGEOGCRS["WGS 84",
#>         DATUM["World Geodetic System 1984",
#>             ELLIPSOID["WGS 84",6378137,298.257223563,
#>                 LENGTHUNIT["metre",1]],
#>             ID["EPSG",6326]],
#>         PRIMEM["Greenwich",0,
#>             ANGLEUNIT["Degree",0.0174532925199433]]],
#>     CONVERSION["unnamed",
#>         METHOD["Popular Visualisation Pseudo Mercator",
#>             ID["EPSG",1024]],
#>         PARAMETER["Latitude of natural origin",0,
#>             ANGLEUNIT["Degree",0.0174532925199433],
#>             ID["EPSG",8801]],
#>         PARAMETER["Longitude of natural origin",0,
#>             ANGLEUNIT["Degree",0.0174532925199433],
#>             ID["EPSG",8802]],
#>         PARAMETER["False easting",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8806]],
#>         PARAMETER["False northing",0,
#>             LENGTHUNIT["metre",1],
#>             ID["EPSG",8807]]],
#>     CS[Cartesian,2],
#>         AXIS["(E)",east,
#>             ORDER[1],
#>             LENGTHUNIT["metre",1,
#>                 ID["EPSG",9001]]],
#>         AXIS["(N)",north,
#>             ORDER[2],
#>             LENGTHUNIT["metre",1,
#>                 ID["EPSG",9001]]]]
# }
```
