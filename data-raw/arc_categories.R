## code to prepare `arc_categories` dataset goes here

# Step 1: Download ----
url <- paste0(
  "https://geocode.arcgis.com/arcgis/rest/",
  "services/World/GeocodeServer?f=pjson"
)

# Download to temp file
json <- tempfile(fileext = ".json")
res <- arc_api_call(url, json, FALSE)


# Step 2: Read and parse results ----
result_init <- jsonlite::fromJSON(json, flatten = FALSE)

# Get categories
cats <- as.list(result_init$categories)

# top names
topnames <- cats$name

# Second level cats, no localized
second_lev <- lapply(cats$categories, function(x) {
  x[!grepl("local", names(x), fixed = TRUE)]
})

# There are special cases here...
lng_list <- lengths(second_lev)

# When lenght 1 is trivial
seq_tot <- seq_len(length(second_lev))
easy <- lapply(seq_tot[lng_list == 1], function(x) {
  end <- as.data.frame(second_lev[x])
  names(end) <- "level_2"
  end$level_1 <- topnames[x]
  end
})

easy_end <- dplyr::bind_rows(easy)
# For others (POI) not so easy...

n_hard <- seq_tot[lng_list > 1]

pois <- second_lev[[n_hard]]$categories
pois_sub <- second_lev[[n_hard]]$name
pois_end <- lapply(pois, function(x) {
  x$name
})

# Compose sub data frames
n_pois <- seq_len(length(pois_sub))

pois_2nd_lev <- lapply(n_pois, function(x) {
  end <- data.frame(level_3 = unlist(pois_end[x]))
  end$level_2 <- pois_sub[x]
  end
})

pois_tbl <- dplyr::bind_rows(pois_2nd_lev)

pois_tbl$level_1 <- topnames[n_hard]

# End, rename and reorder cols

all_end <- dplyr::bind_rows(easy_end, pois_tbl)

all_end <- all_end[, c(2, 1, 3)]

arc_categories <- dplyr::as_tibble(all_end)


usethis::use_data(arc_categories, overwrite = TRUE)
