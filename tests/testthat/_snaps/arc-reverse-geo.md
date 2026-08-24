# arc_reverse_geo() validates coordinate inputs

    Code
      arc_reverse_geo(0, c(2, 3))
    Condition
      Error in `arc_reverse_geo()`:
      ! `x` and `y` must have the same length.

---

    Code
      arc_reverse_geo("a", "a")
    Condition
      Error in `arc_reverse_geo()`:
      ! `x` and `y` must both be numeric.

# arc_reverse_geo() reports capped coordinates and verbose requests

    Code
      out <- arc_reverse_geo(200, 0)
    Message
      Longitude values outside [-180, 180] were replaced with the nearest boundary.

---

    Code
      out <- arc_reverse_geo(0, 200)
    Message
      Latitude values outside [-90, 90] were replaced with the nearest boundary.

---

    Code
      out <- arc_reverse_geo(0, 90, verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
      Request parameters:
         - location=0,90
         - f=json
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=0,90&f=json

# arc_reverse_geo() returns missing addresses for unmatched points

    Code
      obj <- arc_reverse_geo(179.9999, 89.999999, featuretypes = "StreetInt")
    Message
      The ArcGIS REST API returned an error for location: 179.9999, 89.999999
      Message: Cannot perform query. Invalid query parameters.
      Details: Unable to find address for the specified location.

---

    Code
      obj_renamed <- arc_reverse_geo(179.9999, 89.999999, address = "adddata",
        featuretypes = "StreetInt")
    Message
      The ArcGIS REST API returned an error for location: 179.9999, 89.999999
      Message: Cannot perform query. Invalid query parameters.
      Details: Unable to find address for the specified location.

# arc_reverse_geo() returns missing data when the API request fails

    Code
      obj <- arc_reverse_geo(-3.6687109, 40.4207414)
    Message
      Unable to reach the ArcGIS REST API endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-3.6687109,40.4207414&f=json

