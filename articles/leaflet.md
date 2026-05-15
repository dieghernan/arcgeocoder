# arcgeocoder and leaflet maps

## Example

The following example shows how to create an interactive [leaflet
map](https://rstudio.github.io/leaflet/) with data retrieved with
**arcgeocoder**.

This widget is browsable and filterable thanks to **crosstalk** and
**reactable**:

``` r

# Coffee shops and bakeries around the Eiffel Tower.

library(arcgeocoder)
library(leaflet)
library(dplyr)
library(reactable)
library(crosstalk)

# Step 1: Locate the Eiffel Tower.
eiffel_tower <- arc_geo_multi("Eiffel Tower",
  city = "Paris", countrycode = "FR",
  category = "POI"
)

# Base URL for icons.
icon_url <- paste0(
  "https://raw.githubusercontent.com/dieghernan/arcgeocoder/",
  "main/vignettes/articles/"
)

eiffel_icon <- makeIcon(
  iconUrl = paste0(icon_url, "eiffel-tower.png"),
  iconWidth = 50, iconHeight = 50,
  iconAnchorX = 25, iconAnchorY = 25
)

# Step 2: Find nearby coffee shops and bakeries.
cf_bk <- arc_geo_categories(
  category = c("Coffee Shop", "Bakery"),
  x = eiffel_tower$lon, y = eiffel_tower$lat,
  limit = 50,
  full_results = TRUE
)

# Create labels and icons.
labs <- paste0("<strong>", cf_bk$PlaceName, "</strong><br>", cf_bk$StAddr)

# Assign icons.
leaf_icons <- icons(
  ifelse(cf_bk$Type == "Coffee Shop",
    paste0(icon_url, "coffee-cup.png"),
    paste0(icon_url, "croissant.png")
  ),
  iconWidth = 20, iconHeight = 20,
  iconAnchorX = 10, iconAnchorY = 10
)

# Step 3: Create a crosstalk object.
cf_bk_data <- cf_bk |>
  select(Place = ShortLabel, Type, Address = Place_addr, City, URL, Phone) |>
  SharedData$new(group = "Food")

# Step 4: Create a leaflet map with crosstalk.
# Initialize the leaflet map.
lmend <- leaflet(
  data = cf_bk_data,
  elementId = "EiffelTower", width = "100%", height = "60vh",
  options = leafletOptions(minZoom = 12)
) |>
  setView(eiffel_tower$lon, eiffel_tower$lat, zoom = 16) |>
  addProviderTiles(
    provider = "CartoDB.Positron",
    group = "CartoDB.Positron"
  ) |>
  addTiles(group = "OSM") |>
  addMarkers(data = eiffel_tower, ~lon, ~lat, icon = eiffel_icon) |>
  addMarkers(
    lat = cf_bk$lat, lng = cf_bk$lon, popup = labs, icon = leaf_icons
  ) |>
  addLayersControl(
    baseGroups = c("CartoDB.Positron", "OSM"),
    position = "topleft",
    options = layersControlOptions(collapsed = FALSE)
  )

# Step 5: Create a reactable for filtering.
tb <- reactable(cf_bk_data,
  selection = "multiple",
  onClick = "select",
  rowStyle = list(cursor = "pointer"),
  filterable = TRUE,
  searchable = TRUE,
  showPageSizeOptions = TRUE,
  striped = TRUE,
  defaultColDef = colDef(vAlign = "center", minWidth = 150),
  paginationType = "jump",
  elementId = "coffees",
  columns = list(
    Place = colDef(
      sticky = "left", rowHeader = TRUE, name = "",
      cell = function(value) {
        htmltools::strong(value)
      }
    ),
    URL = colDef(cell = function(value) {
      # Render as a link.
      if (any(is.null(value), is.na(value))) {
        return("")
      }
      htmltools::a(href = value, target = "_blank", as.character(value))
    }),
    Phone = colDef(cell = function(value) {
      # Render as a link.
      if (any(is.null(value), is.na(value))) {
        return("")
      }
      clearphone <- gsub("-", "", value)
      clearphone <- gsub(" ", "", clearphone)
      htmltools::a(
        href = paste0("tel:", clearphone), target = "_blank",
        as.character(value)
      )
    })
  )
)
```

## Widget

``` r

# Last step: Display all components.
htmltools::browsable(
  htmltools::tagList(lmend, tb)
)
```

## Attributions

- [Eiffel tower icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/eiffel-tower "eiffel tower icons")
- [Mug icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/mug "mug icons")
- [Croissant icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/croissant "croissant icons")
