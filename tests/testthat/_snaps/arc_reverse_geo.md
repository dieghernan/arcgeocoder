# Errors

    Code
      arc_reverse_geo(0, c(2, 3))
    Condition
      Error in `arc_reverse_geo()`:
      ! `x` and `y` must have the same number of elements.

---

    Code
      arc_reverse_geo("a", "a")
    Condition
      Error in `arc_reverse_geo()`:
      ! `x` and `y` must be numeric.

# Messages

    Code
      out <- arc_reverse_geo(200, 0)
    Message
      
      Longitudes were restricted to [-180, 180].

---

    Code
      out <- arc_reverse_geo(0, 200)
    Message
      
      Latitudes were restricted to [-90, 90].

---

    Code
      out <- arc_reverse_geo(0, 90, verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
      Parameters:
         - location=0,90
         - f=json
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=0,90&f=json

# Returning empty query

    Code
      obj <- arc_reverse_geo(179.9999, 89.999999, featuretypes = "StreetInt")
    Message
      
      No results found for location: 179.9999, 89.999999
      Cannot perform query. Invalid query parameters.
      Details: Unable to find address for the specified location.

---

    Code
      obj_renamed <- arc_reverse_geo(179.9999, 89.999999, address = "adddata",
        featuretypes = "StreetInt")
    Message
      
      No results found for location: 179.9999, 89.999999
      Cannot perform query. Invalid query parameters.
      Details: Unable to find address for the specified location.

# Mock arc_api_call

    Code
      obj <- arc_reverse_geo(-3.6687109, 40.4207414)
    Message
      
      Unable to reach URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=-3.6687109,40.4207414&f=json

