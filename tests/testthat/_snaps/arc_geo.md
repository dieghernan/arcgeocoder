# Messages

    Code
      out <- arc_geo("Madrid", limit = 200)
    Message
      
      ArcGIS REST API provides 50 results as a maximum.  Your query may be incomplete

---

    Code
      out <- arc_geo("Madrid", verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=Madrid
         - f=json
         - maxLocations=1
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Madrid&f=json&maxLocations=1

# Use categories single

    Code
      out <- arc_geo("", category = "Gas Station", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Gas Station
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Gas%20Station

---

    Code
      out2 <- arc_geo("", category = "Restaurant", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Restaurant
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Restaurant

