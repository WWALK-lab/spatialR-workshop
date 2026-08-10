# Packages --------------------------------------------------
# all packages should already be installed, we just need to load them
source('scripts/00-packages.R')

# Data ------------------------------------------------------
rv <- readRDS("input/cleaned/ruelles-vertes-merged.rds")
buff <- readRDS("input/cleaned/buffers.rds")
pts <- readRDS("input/cleaned/sampling-points.rds")
cc <- rast("input/canopy-cover.tif")

# Buffers ---------------------------------------------------
# let's intersect our land use/canopy cover with the buffers we created
cc_int <- terra::crop(cc, buff)


# for each ruelle's buffer, let's calculate % canopy cover (canopy == 4 in the raster)

# need to have buffers as a SpatVector, part of the terra package, to do this operation
buffers_sv <- vect(buff)

# calculate the frequency of each category of the raster in each buffer
t <- freq(cc, zones = buffers_sv, touches = F)

rv_cc <- buff |>
  rownames_to_column('zone') |>
  mutate(zone = as.numeric(zone)) |>
  left_join(t, by = 'zone') |>
  pivot_wider(
    id_cols = c(zone, geometry),
    names_from = value,
    values_from = count
  ) |>
  rowwise() |>
  mutate(cancov = `4` / sum(c_across(`1`:`4`))) %>%
  select(c(cancov, geometry))

# Sample Points ----------------------------------------------
# we can also extract the raster value at each of our sampling points
# make points into SpatVector
pts_sv <- vect(pts) |> project(crs(cc))
# extract value of raster at each point
landuse <- terra::extract(cc, pts_sv)
# assign column in point df with land cover value
pts$landuse <- landuse$`canopy-cover`

# Save -------------------------------------------------------
# save buffer as final output
# gpkg is a great file output type for sharing and transferring between QGIS / R
write_sf(rv_cc, "output/buffers.gpkg")

# Bonus: Vectorization ---------------------------------------
# if we vectorize the raster, we can calculate the percent of each value
# vectorizing is computationally expensive so I will include the code but not run it
# cc <- st_as_sf(cc) # transform to sf object
# int <- st_intersection(buff, cc) # intersect buffers with canopy
# int <- st_make_valid(int) # validate geometries
# dist <- int %>% group_by(RuelleID, label) %>% mutate(area = st_area(geometry)) # where label is land cover type
# canopy <-dist %>% group_by(RuelleID) %>% summarise(totarea = sum(area),
#                                                    impergr = sum(area[label == 1]),
#                                                    veggr = sum(area[label == 3]),
#                                                    build = sum(area[label == 2]),
#                                                    can = sum(area[label == 4]),
#                                                    wat = sum(area[label == 5]),
#                                                    perimpgr = impergr/totarea,
#                                                    perveggr = veggr/totarea,
#                                                    perbuild = build/totarea,
#                                                    percan = can/totarea,
#                                                    perwat = wat/totarea)
