#' Check access to ArcGIS REST
#'
#' @description
#' Checks whether \R can access resources at the ArcGIS REST API
#' <`r arcurl("over")`>.
#'
#' @return A logical value.
#'
#' @family api_management
#'
#' @examples
#' \donttest{
#' arcgeocoder_check_access()
#' }
#' @keywords internal
#' @export
#' @encoding UTF-8
arcgeocoder_check_access <- function() {
  api <- arc_endpoint_url("reverseGeocode")

  # Compose URL.
  url <- paste0(api, "location=0,0&f=json")
  destfile <- tempfile(fileext = ".json")

  api_res <- arc_api_call(url, destfile, TRUE)

  # nocov start
  if (isFALSE(api_res)) {
    return(FALSE)
  }
  # nocov end
  result_json <- jsonlite::fromJSON(destfile)

  # nocov start
  result_json$location$x == 0
  # nocov end
}

skip_if_api_server <- function() {
  # nocov start
  if (arcgeocoder_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("ArcGIS REST API not reachable.")
  }
  invisible()
  # nocov end
}

#' Centralize API queries
#'
#' @description
#' A wrapper around [utils::download.file()]. On warning or error, it retries
#' the call.
#'
#' @inheritParams utils::download.file
#'
#' @return A logical `TRUE` or `FALSE`.
#'
#' @family api_management
#'
#' @keywords internal
#' @noRd
arc_api_call <- function(url, destfile, quiet) {
  if (!quiet) {
    message_api_call(url)
  }

  url <- URLencode(url)
  # nocov start
  dwn_res <- arc_download_file(url, destfile)
  # nocov end

  # nocov start
  if (isFALSE(dwn_res)) {
    if (isFALSE(quiet)) {
      message("\nRetrying query.")
    }
    Sys.sleep(1)

    dwn_res <- arc_download_file(url, destfile)
  }

  if (isFALSE(dwn_res)) {
    return(FALSE)
  }
  TRUE
  # nocov end
}
