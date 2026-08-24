# arc_api_call() retries failed downloads once

    Code
      arc_api_call(url, destfile, FALSE, wait = function(...) NULL)
    Message
      Request endpoint: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?
      Request parameters:
         - location=0,0
         - f=json
      Encoded URL: https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?location=0,0&f=json
      The request failed. Retrying once.
    Output
      [1] FALSE

