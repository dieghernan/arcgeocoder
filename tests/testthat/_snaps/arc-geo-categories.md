# arc_geo_categories() validates locations and reserved arguments

    Code
      arc_geo_categories("Food")
    Condition
      Error:
      ! Provide both `x` and `y`, or provide a valid `bbox`.

---

    Code
      arc_geo_categories("Food", "a", "a")
    Condition
      Error:
      ! `x` and `y` must both be numeric.

---

    Code
      arc_geo_categories("Food", 0, 0, address = "Error")
    Condition
      Error in `arc_geo()`:
      ! formal argument "address" matched by multiple actual arguments

---

    Code
      arc_geo_categories("Food", 0, 0, progressbar = TRUE)
    Condition
      Error in `arc_geo()`:
      ! formal argument "progressbar" matched by multiple actual arguments

---

    Code
      arc_geo_categories("Food", 0, 0, return_addresses = TRUE)
    Condition
      Error in `arc_geo()`:
      ! formal argument "return_addresses" matched by multiple actual arguments

# arc_geo_categories() reports adjusted and incomplete locations

    Code
      out <- arc_geo_categories("POI", 200, 0)
    Message
      Longitude values outside [-180, 180] were replaced with the nearest boundary.

---

    Code
      out <- arc_geo_categories("Address,Postal,Coordinate System,POI", 0, 200)
    Message
      Latitude values outside [-90, 90] were replaced with the nearest boundary.
      The ArcGIS REST API returned no results for query: 
      The ArcGIS REST API returned no results for category: Address
      The ArcGIS REST API returned no results for query: 
      The ArcGIS REST API returned no results for category: Postal
      The ArcGIS REST API returned no results for query: 
      The ArcGIS REST API returned no results for category: Coordinate System
      The ArcGIS REST API returned no results for query: 
      The ArcGIS REST API returned no results for category: POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, verbose = TRUE)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = 3.7242, bbox = c(-3.8, 40.3, -3.65, 40.5))
    Message
      Both `x` and `y` are required. The location was ignored.

---

    Code
      out <- arc_geo_categories("POI", y = 3.7242, bbox = c(-3.8, 40.3, -3.65, 40.5))
    Message
      Both `x` and `y` are required. The location was ignored.

# arc_geo_categories() validates and caps bounding boxes

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = "uno",
        verbose = TRUE)
    Message
      `bbox` must contain at least four values and was ignored.
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c("uno", NA),
      verbose = TRUE)
    Message
      `bbox` contains `NA` values and was ignored.
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = LETTERS[1:4],
      verbose = TRUE)
    Message
      `bbox` must be numeric and was ignored.
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-200, -89,
        200, 89), verbose = TRUE)
    Message
      `bbox` longitude values outside [-180, 180] were replaced with the nearest boundary.
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-180,-89,180,89
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-180,-89,180,89&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-100, -95,
        100, 95), verbose = TRUE)
    Message
      `bbox` latitude values outside [-90, 90] were replaced with the nearest boundary.
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-100,-90,100,90
         - category=POI
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-100,-90,100,90&category=POI

# arc_geo_categories() adds query parameters consistently

    Code
      out <- arc_geo_categories("POI,Address", x = -3.7242, y = 40.39094, name = "Bar",
        limit = 20, lon = "aaaa", lat = "bbbb", bbox = c(-3.8, 40.3, -3.65, 40.5),
        sourcecountry = "ES", verbose = TRUE, outsr = 102100, langcode = "ES",
        custom_query = list(outFields = "LongLabel"))
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
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
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=POI
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Request parameters:
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
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=Address

