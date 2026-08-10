# Packages --------------------------------------------------
# all packages should already be installed, we just need to load them
source('scripts/00-packages.R')

# Data ------------------------------------------------------
# let's load in our vector ruelles vertes data
rv <- readRDS("input/cleaned/ruelles-vertes-transformed.rds")

# Analysis --------------------------------------------------
# MERGE
# when initially investigating data, we saw that ruelles had multiple polygons even when they had the same ID
# let's merge all polygons with the same ID so that we aren't doing multiple calculations for one alley
rv_m <- rv |>
  dplyr::group_by(RUELLE_ID) |>
  dplyr::summarise(
    geometry = st_union(geometry),
    nhood = first(PROPRIETAI),
    codenhood = first(CODE_ARR),
    date = first(DATE_AMENA)
  )

# AREA
# let's do some common spatial operations
# let's calculate the area of each ruelles vertes
rv_m$area <- st_area(rv_m)
class(rv_m$area) # this function returns a vector of class "units"
# if we want to use this info in future operations - we need to convert from units to double
rv_m$area <- as.double(rv_m$area)

# BUFFER
# let's calculate a buffer around each ruelle so we can extract canopy cover
buff <- st_buffer(rv_m, 50) # important note: our projection is in m so the number we use here is m
# let's visualize the buffers just to make sure everything looks good
mapview(rv_m, col.regions = "red") + mapview(buff) # they look good!

# SAMPLE
# sometimes we want to randomly (or very not randomly) sample areas for fieldwork
# we can use st_sample to generate as many points as we want in our areas of interest
samp <- st_sample(rv_m, c(3, 3), type = "random", by_polygon = F) |>
  st_as_sf()
# let's visualize, to check
mapview(rv_m, col.regions = "red") + mapview(samp) # looks great!
# these sampling points aren't very useful for us without the associated RUELLE_ID values...

# SPATIAL JOIN
# let's use st_intersects to join the information from the ruelles to the sampling points
samp_join <- st_join(samp, rv_m, join = st_intersects)

# Save ------------------------------------------------------
# save merged ruelles
saveRDS(rv_m, "input/cleaned/ruelles-vertes-merged.rds")
# save buffers as intermediate for 3-RasterAnalysis.R
saveRDS(buff, "input/cleaned/buffers.rds")
# save sampling points
saveRDS(samp_join, "input/cleaned/sampling-points.rds")
