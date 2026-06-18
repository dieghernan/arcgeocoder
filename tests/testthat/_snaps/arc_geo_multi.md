# Errors

    Code
      arc_geo_multi()
    Condition
      Error in `input_multi()`:
      ! Provide at least one address component that is not `NA`.

---

    Code
      arc_geo_multi("a", c("a", "b"))
    Condition
      Error in `input_multi()`:
      ! When providing multiple address components, their lengths must be the same.

---

    Code
      arc_geo_multi(NA)
    Condition
      Error in `arc_geo_multi()`:
      ! Provide at least one address component that is not `NA`.

# Messages

    Code
      out <- arc_geo_multi("Madrid", limit = 200)
    Message
      
      The ArcGIS REST API returns at most 50 results per request. Only the first 50 results will be requested.

---

    Code
      out <- arc_geo_multi(address = "Calle Mayor", city = "Madrid", countrycode = "ESP",
        verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Calle Mayor
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Calle%20Mayor&city=Madrid&countryCode=ESP&f=json&maxLocations=1

# Use categories multi

    Code
      out <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "POI", custom_query = list(outFields = "LongLabel,Type", location = "-117.92712,33.81563"),
        verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=POI

---

    Code
      out2 <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "Address", custom_query = list(outFields = "LongLabel,Type",
          location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Address
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Address

