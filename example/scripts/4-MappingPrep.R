# Packages --------------------------------------------------
source('scripts/00-packages.R')
# Data ------------------------------------------------------
rv <- readRDS("input/cleaned/ruelles-vertes-merged.rds")

# OSM Base Data Download -------------------------------------
# set up bounding box - order: xmin, ymin, xmax, ymax
bb <- c(xmin = -74.0788, ymin = 45.3414, xmax = -73.3894, ymax = 45.7224)

# Island boundary using osmdata
mtl <- opq(bb) |> # this make a call for any data found within our coordinates
  add_osm_feature(key = 'place', value = 'island') |> # we select any features that are places + islands
  osmdata_sf() # transform it into sf object
# we are returned a list of different types of geometries that match our request
# we will select the ones we are interested in and combine
multipolys <- st_make_valid(mtl$osm_multipolygons) # grab multipolygons (large islands)
polys <- st_make_valid(mtl$osm_polygons) # grab polygons (small islands)
polys <- st_cast(polys, "MULTIPOLYGON")
allpolys <- st_as_sf(st_union(polys, multipolys)) # combine geometries and cast as sf
st_crs(allpolys) = 4326 # set CRS as EPSG 4326

# Water
# going to do the same thing as above but we want water features within our coordinates
water <- opq(bb) |>
  add_osm_feature(key = 'natural', value = 'water') |>
  osmdata_sf()
wmpols <- water$osm_multipolygons
wmpols <- st_cast(wmpols, "MULTIPOLYGON")
wmpols <- st_as_sf(st_make_valid(wmpols))
st_crs(wmpols) = 4326

# save for use in mapping later

write_sf(allpolys, 'output/islands.gpkg')
write_sf(wmpols, 'output/water.gpkg')


# basemaps Data Download --------------------------------------------------

# set up bounding box - order: xmin, ymin, xmax, ymax
bb <- c(xmin = -74.0788, ymin = 45.3414, xmax = -73.3894, ymax = 45.7224)

# or use layer to create bounding box
# this creates a bounding box around all the ruelles vertes
bb_layer <- st_bbox(rv)

# view all available maps
get_maptypes()

# you can add the basemap as a layer
bbox <- st_bbox(bb)
st_crs(bbox) = 4326

ggplot() +
  basemap_gglayer(bbox, map_service = "carto", map_type = "light") +
  scale_fill_identity() +
  coord_sf()

# you can also make it as a ggplot
basemap_ggplot(bbox, map_service = "carto", map_type = "dark")

# and there are different spatial classes you can use, such as stars where the basemap is returned as a stars object
basemap_stars(bbox, map_service = "osm", map_type = "streets")
