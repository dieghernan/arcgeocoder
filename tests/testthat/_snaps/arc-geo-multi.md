# arc_geo_multi() validates address components

    Code
      arc_geo_multi()
    Condition
      Error in `input_multi()`:
      ! Provide at least one address component that is not `NA` or `NULL`.

---

    Code
      arc_geo_multi("a", c("a", "b"))
    Condition
      Error in `input_multi()`:
      ! All supplied address components must have the same length.

---

    Code
      arc_geo_multi(NA)
    Condition
      Error in `arc_geo_multi()`:
      ! Provide at least one address component that is not `NA` or `NULL`.

# arc_geo_multi() reports capped limits and verbose requests

    Code
      out <- arc_geo_multi("Madrid", limit = 200)
    Message
      The ArcGIS REST API limits each request to 50 results. `limit` was reduced to 50.

---

    Code
      out <- arc_geo_multi(address = "Calle Mayor", city = "Madrid", countrycode = "ESP",
        verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - address=Calle Mayor
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Calle%20Mayor&city=Madrid&countryCode=ESP&f=json&maxLocations=1

# arc_geo_multi() filters results by category

    Code
      out <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "POI", custom_query = list(outFields = "LongLabel,Type", location = "-117.92712,33.81563"),
        verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=POI

---

    Code
      out2 <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "Address", custom_query = list(outFields = "LongLabel,Type",
          location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Address
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Address

