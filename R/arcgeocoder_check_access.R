#' Check access to the ArcGIS REST API
#'
#' @description
#' Checks whether the current \R session can access the ArcGIS REST API at
#' <`r arcurl("over")`>.
#'
#' @returns `TRUE` if the service is accessible, otherwise `FALSE`.
#'
#' @keywords internal
#'
#' @export
#' @encoding UTF-8
#'
#' @examples
#' \donttest{
#' arcgeocoder_check_access()
#' }
arcgeocoder_check_access <- function() {
  if (on_cran()) {
    return(FALSE)
  }

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

#' Send API queries with one retry
#'
#' @description
#' A wrapper around [utils::download.file()] that retries the request once after
#' a warning or error.
#'
#' @param url URL to download.
#' @param destfile Path where the downloaded file will be saved.
#' @param quiet A logical value indicating whether to suppress request details.
#'
#' @returns `TRUE` if the file was downloaded, otherwise `FALSE`.
#'
#' @noRd
arc_api_call <- function(url, destfile, quiet) {
  if (!quiet) {
    message_api_call(url)
  }

  url <- URLencode(url)

  dwn_res <- arc_download_file(url, destfile)

  if (isFALSE(dwn_res)) {
    if (isFALSE(quiet)) {
      message("\nRetrying request.")
    }
    Sys.sleep(1)

    dwn_res <- arc_download_file(url, destfile)
  }

  if (isFALSE(dwn_res)) {
    return(FALSE)
  }
  TRUE
}

#' Check whether the current session is running on CRAN
#'
#' @returns `TRUE` when running on CRAN, otherwise `FALSE`.
#' @noRd
on_cran <- function() {
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive()
  } else {
    !isTRUE(as.logical(env))
  }
}
