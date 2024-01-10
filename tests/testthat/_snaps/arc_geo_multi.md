# Messages

    Code
      out <- arc_geo_multi("Madrid", limit = 200)
    Message
      
      ArcGIS REST API provides 50 results as a maximum.  Your query may be incomplete

---

    Code
      out <- arc_geo_multi(address = "Calle Mayor", city = "Madrid", countrycode = "ESP",
        verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Calle Mayor
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Calle%20Mayor&city=Madrid&countryCode=ESP&f=json&maxLocations=1

# Use categories multi

    Code
      out <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "POI", custom_query = list(outFields = "LongLabel,Type", location = "-117.92712,33.81563"),
        verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=POI

---

    Code
      out2 <- arc_geo_multi(address = "Atocha", city = "Madrid", countrycode = "ESP",
        category = "Address", custom_query = list(outFields = "LongLabel,Type",
          location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - address=Atocha
         - city=Madrid
         - countryCode=ESP
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Address
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?address=Atocha&city=Madrid&countryCode=ESP&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Address

