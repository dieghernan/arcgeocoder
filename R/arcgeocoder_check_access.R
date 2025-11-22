#' Check access to ArcGIS REST
#'
#' @family api_management
#'
#' @description
#' Check if **R** has access to resources at ArcGIS REST API
#' <`r arcurl("over")`>.
#'
#' @return a logical.
#'
#' @examples
#' \donttest{
#' arcgeocoder_check_access()
#' }
#' @keywords internal
#' @export
arcgeocoder_check_access <- function() {
  api <- paste0(
    "https://geocode.arcgis.com/arcgis/rest/services/",
    "World/GeocodeServer/reverseGeocode?"
  )

  # Compose url
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
  if (result_json$location$x == 0) {
    res <- TRUE
  } else {
    res <- FALSE
  }
  res
  # nocov end
}

skip_if_api_server <- function() {
  # nocov start
  if (arcgeocoder_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("ArcGIS REST API not reachable")
  }
  invisible()
  # nocov end
}


#' Helper function for centralize API queries
#'
#' @description
#' A wrapper of [utils::download.file()]. On warning on error it will
#' retry the call.
#'
#'
#' @family api_management
#'
#' @inheritParams utils::download.file
#' @return A logical `TRUE/FALSE`
#'
#' @keywords internal
#'
#' @noRd
arc_api_call <- function(url, destfile, quiet) {
  if (!quiet) {
    decomp <- unlist(strsplit(url, "?", fixed = TRUE))
    params <- unlist(strsplit(decomp[2], "&"))
    url <- URLencode(url)
    message(
      "\nEntry point: ",
      decomp[1],
      "?\nParameters:\n",
      paste0("   - ", params, collapse = "\n"),
      "\nurl: ",
      url
    )
  }

  url <- URLencode(url)
  # nocov start
  dwn_res <-
    tryCatch(
      download.file(url, destfile = destfile, quiet = TRUE, mode = "wb"),
      warning = function(e) {
        FALSE
      },
      error = function(e) {
        FALSE
      }
    )
  # nocov end

  # nocov start
  if (isFALSE(dwn_res)) {
    if (isFALSE(quiet)) {
      message("\nRetrying query")
    }
    Sys.sleep(1)

    dwn_res <-
      tryCatch(
        download.file(url, destfile = destfile, quiet = TRUE, mode = "wb"),
        warning = function(e) {
          FALSE
        },
        error = function(e) {
          FALSE
        }
      )
  }

  if (isFALSE(dwn_res)) {
    return(FALSE)
  }
  res <- TRUE
  res
  # nocov end
}
