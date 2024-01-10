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

