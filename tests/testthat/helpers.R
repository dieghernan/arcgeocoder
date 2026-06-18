skip_if_api_server <- function() {
  if (arcgeocoder_check_access()) {
    return(invisible(TRUE))
  }

  testthat::skip("ArcGIS REST API not reachable.")

  invisible()
}
