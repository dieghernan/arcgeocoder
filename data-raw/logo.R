## code to prepare `logo` dataset goes here

rm(list = ls())

library(giscoR)
library(dplyr)
library(sf)
library(ggplot2)
library(hexSticker)

mad <- gisco_get_coastallines(resolution = 60) %>%
  st_transform("+proj=robin")
mad2 <- st_buffer(mad, -20 * 1000)
small <- !st_is_empty(mad2)
mad2 <- mad2[small, ]
mad <- mad[small, ]


set.seed(1234)
r <- st_sample(mad, 2000)

max(st_coordinates(r)[2, ])
max(st_coordinates(r))

st_bbox(mad)

## Section----



df1 <- data.frame(
  label = "arc",
  lon = -3.544387,
  lat = 40.55039
)

p1 <- st_as_sf(df1, coords = c("lon", "lat"), crs = 4326) %>% st_transform(3857)

df2 <- data.frame(
  label = "geocoder",
  lon = -3.405387,
  lat = 40.55039
)

p2 <- st_as_sf(df2, coords = c("lon", "lat"), crs = 4326) %>% st_transform(3857)

library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Nunito Sans", "nunito")

showtext_auto()

map <- ggplot(mad) +
  geom_sf(fill = "#130d4e", col = "#130d4e", linewidth = 0.01) +
  geom_sf(data = r, col = "white", size = 0.0001) +
  theme_void()



map

sticker(map,
  s_width = 2,
  s_height = 1.5,
  s_x = 1,
  s_y = 0.9,
  p_family = "nunito",
  filename = "man/figures/logo.png",
  h_fill = "#130d4e",
  h_color = "#130d4e",
  package = "arcgeocoder",
  p_y = 1.57,
  p_size = 17
)
