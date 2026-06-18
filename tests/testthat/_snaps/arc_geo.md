# Returning empty query

    Code
      obj <- arc_geo("alsksjdhfg 561bata lorem ipsum")
    Message
      
      No results found for query: alsksjdhfg 561bata lorem ipsum

---

    Code
      obj_renamed <- arc_geo("alsksjdhfg 561bata lorem ipsum", lat = "lata", long = "longa")
    Message
      
      No results found for query: alsksjdhfg 561bata lorem ipsum

# Messages

    Code
      out <- arc_geo("Madrid", limit = 200)
    Message
      
      The ArcGIS REST API returns at most 50 results per request. Only the first 50 results will be requested.

---

    Code
      out <- arc_geo("Madrid", verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=Madrid
         - f=json
         - maxLocations=1
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Madrid&f=json&maxLocations=1

# Use categories single

    Code
      out <- arc_geo("", category = "Gas Station", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Gas Station
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Gas%20Station

---

    Code
      out2 <- arc_geo("", category = "Restaurant", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Restaurant
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Restaurant

# Mock arc_api_call

    Code
      obj <- arc_geo("Madrid")
    Message
      
      URL is unreachable: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Madrid&f=json&maxLocations=1

