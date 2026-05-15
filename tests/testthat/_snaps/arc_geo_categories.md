# Messages

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, verbose = TRUE)
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

# Messages bbox

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = "uno",
        verbose = TRUE)
    Message
      `bbox` has fewer than 4 values. The `bbox` argument will not be used
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c("uno", NA),
      verbose = TRUE)
    Message
      `bbox` has NA values. The `bbox` argument will not be used
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = LETTERS[1:4],
      verbose = TRUE)
    Message
      `bbox` is not numeric. The `bbox` argument will not be used
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-200, -89,
        200, 89), verbose = TRUE)
    Message
      
      `bbox` xmin and xmax have been restricted to [-180, 180]
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-180,-89,180,89
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-180,-89,180,89&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-200, -89,
        200, 89), verbose = TRUE)
    Message
      
      `bbox` xmin and xmax have been restricted to [-180, 180]
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-180,-89,180,89
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-180,-89,180,89&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-100, -95,
        100, 95), verbose = TRUE)
    Message
      
      `bbox` ymin and ymax have been restricted to [-90, 90]
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-100,-90,100,90
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-100,-90,100,90&category=POI

# Test with all params

    Code
      out <- arc_geo_categories("POI,Address", x = -3.7242, y = 40.39094, name = "Bar",
        limit = 20, lon = "aaaa", lat = "bbbb", bbox = c(-3.8, 40.3, -3.65, 40.5),
        sourcecountry = "ES", verbose = TRUE, outsr = 102100, langcode = "ES",
        custom_query = list(outFields = "LongLabel"))
    Message
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=Bar
         - f=json
         - maxLocations=20
         - outFields=LongLabel
         - location=-3.7242,40.39094
         - searchExtent=-3.8,40.3,-3.65,40.5
         - sourceCountry=ES
         - outSR=102100
         - langCode=ES
         - category=POI
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=POI
      
      Entry point: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=Bar
         - f=json
         - maxLocations=20
         - outFields=LongLabel
         - location=-3.7242,40.39094
         - searchExtent=-3.8,40.3,-3.65,40.5
         - sourceCountry=ES
         - outSR=102100
         - langCode=ES
         - category=Address
      url: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=Address
      
      No results for query Bar
      (category: Address)

