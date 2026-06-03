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

  if (isFALSE(api_res)) {
    return(FALSE)
  }

  result_json <- jsonlite::fromJSON(destfile)

  result_json$location$x == 0
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

  dwn_res <- arc_download_file(url, destfile)

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
}
