skip_if_no_api_server <- function() {
  if (arcgeocoder_check_access()) {
    return(invisible(TRUE))
  }

  testthat::skip("ArcGIS REST API not reachable.")
}

local_mock_arc_api <- function(
  fixture = "find-address-candidates.json",
  env = parent.frame()
) {
  fixture_path <- testthat::test_path("fixtures", fixture)
  calls <- new.env(parent = emptyenv())
  calls$url <- character()
  calls$quiet <- logical()

  testthat::local_mocked_bindings(
    arc_api_call = function(url, destfile, quiet, ...) {
      calls$url <- c(calls$url, url)
      calls$quiet <- c(calls$quiet, quiet)
      if (!quiet) {
        message_api_call(url)
      }
      file.copy(fixture_path, destfile, overwrite = TRUE)
    },
    .env = env
  )

  calls
}
