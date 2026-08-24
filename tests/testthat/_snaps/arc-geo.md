# arc_geo() returns missing coordinates for unmatched addresses

    Code
      obj <- arc_geo("alsksjdhfg 561bata lorem ipsum")
    Message
      The ArcGIS REST API returned no results for query: alsksjdhfg 561bata lorem ipsum

---

    Code
      obj_renamed <- arc_geo("alsksjdhfg 561bata lorem ipsum", lat = "lata", long = "longa")
    Message
      The ArcGIS REST API returned no results for query: alsksjdhfg 561bata lorem ipsum

# arc_geo() reports capped limits and verbose requests

    Code
      out <- arc_geo("Madrid", limit = 200)
    Message
      The ArcGIS REST API limits each request to 50 results. `limit` was reduced to 50.

---

    Code
      out <- arc_geo("Madrid", verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=Madrid
         - f=json
         - maxLocations=1
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Madrid&f=json&maxLocations=1

# arc_geo() filters results by category

    Code
      out <- arc_geo("", category = "Gas Station", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Gas Station
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Gas%20Station

---

    Code
      out2 <- arc_geo("", category = "Restaurant", custom_query = list(outFields = "LongLabel,Type",
        location = "-117.92712,33.81563"), verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - outFields=LongLabel,Type
         - location=-117.92712,33.81563
         - category=Restaurant
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&outFields=LongLabel,Type&location=-117.92712,33.81563&category=Restaurant

# arc_geo() returns missing coordinates when the API request fails

    Code
      obj <- arc_geo("Madrid")
    Message
      Unable to reach the ArcGIS REST API endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Madrid&f=json&maxLocations=1

