# Errors

    Code
      arc_geo_categories("Food")
    Condition
      Error in `arc_geo_categories()`:
      ! Provide either a valid combination of `x` and `y` arguments or a valid `bbox`.

---

    Code
      arc_geo_categories("Food", "a", "a")
    Condition
      Error in `validate_location()`:
      ! `x` and `y` must be numeric.

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

# Messages

    Code
      out <- arc_geo_categories("POI", 200, 0)
    Message
      
      Longitudes were restricted to [-180, 180].

---

    Code
      out <- arc_geo_categories("Address,Postal,Coordinate System,POI", 0, 200)
    Message
      
      Latitudes were restricted to [-90, 90].
      
      No results found for query: 
      No results found for category: Address
      
      No results found for query: 
      No results found for category: Postal
      
      No results found for query: 
      No results found for category: Coordinate System
      
      No results found for query: 
      No results found for category: POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, verbose = TRUE)
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = 3.7242, bbox = c(-3.8, 40.3, -3.65, 40.5))
    Message
      Either `x` or `y` is missing. The location will not be used.

---

    Code
      out <- arc_geo_categories("POI", y = 3.7242, bbox = c(-3.8, 40.3, -3.65, 40.5))
    Message
      Either `x` or `y` is missing. The location will not be used.

# Messages bbox

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = "uno",
        verbose = TRUE)
    Message
      `bbox` has fewer than four values and will not be used.
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c("uno", NA),
      verbose = TRUE)
    Message
      `bbox` contains `NA` values and will not be used.
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = LETTERS[1:4],
      verbose = TRUE)
    Message
      `bbox` must be numeric and will not be used.
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-200, -89,
        200, 89), verbose = TRUE)
    Message
      
      `bbox` xmin and xmax were restricted to [-180, 180].
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-180,-89,180,89
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-180,-89,180,89&category=POI

---

    Code
      out <- arc_geo_categories("POI", x = -3.7242, y = 40.39094, bbox = c(-100, -95,
        100, 95), verbose = TRUE)
    Message
      
      `bbox` ymin and ymax were restricted to [-90, 90].
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
      Parameters:
         - SingleLine=
         - f=json
         - maxLocations=1
         - location=-3.7242,40.39094
         - searchExtent=-100,-90,100,90
         - category=POI
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=&f=json&maxLocations=1&location=-3.7242,40.39094&searchExtent=-100,-90,100,90&category=POI

# Test with all params

    Code
      out <- arc_geo_categories("POI,Address", x = -3.7242, y = 40.39094, name = "Bar",
        limit = 20, lon = "aaaa", lat = "bbbb", bbox = c(-3.8, 40.3, -3.65, 40.5),
        sourcecountry = "ES", verbose = TRUE, outsr = 102100, langcode = "ES",
        custom_query = list(outFields = "LongLabel"))
    Message
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
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
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=POI
      
      Endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?
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
      URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?SingleLine=Bar&f=json&maxLocations=20&outFields=LongLabel&location=-3.7242,40.39094&searchExtent=-3.8,40.3,-3.65,40.5&sourceCountry=ES&outSR=102100&langCode=ES&category=Address
      
      No results found for query: Bar
      No results found for category: Address

