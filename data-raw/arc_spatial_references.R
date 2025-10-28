## code to prepare `arc_spatial_references` dataset goes here
rm(list = ls())
library(dplyr)
library(jsonlite)

# Use https://github.com/Esri/projection-engine-db-doc

entry <- paste0(
  "https://raw.githubusercontent.com/Esri/",
  "projection-engine-db-doc/master/json/"
)

proj_url <- c(
  "pe_list_projcs.json",
  "pe_list_geogcs.json",
  "pe_list_vertcs.json"
)

end <- lapply(proj_url, function(x) {
  final <- fromJSON(paste0(entry, x))

  df <- as_tibble(final[[1]])
  df$projtype <- names(final)
  # ext <- df$extent

  df_2 <- df %>%
    select(-extent, -version) %>%
    # bind_cols(ext) %>%
    relocate(projtype, .before = 1)

  dep <- ifelse(df_2$deprecated == "no", FALSE, TRUE)
  df_2$deprecated <- dep

  as_tibble(df_2)
})

prev <- bind_rows(end)
# Relocate cols

arc_spatial_references <- prev %>%
  select(
    projtype,
    wkid,
    latestWkid,
    authority,
    deprecated,
    description,
    areaname,
    wkt
  )

usethis::use_data(arc_spatial_references, overwrite = TRUE)
