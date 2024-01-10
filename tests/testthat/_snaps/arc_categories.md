# Messages

    Code
      out <- arc_categories(verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer?
      Parameters:
         - f=pjson
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer?f=pjson

# Use test single

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

# Use test multi

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

