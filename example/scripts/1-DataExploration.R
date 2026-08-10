# Packages --------------------------------------------------
# all packages should already be installed, we just need to load them
source('scripts/00-packages.R')

# Data ------------------------------------------------------
# let's load in the Ruelles Vertes data that can be found at https://donnees.montreal.ca/ville-de-montreal/ruelles-vertes
# this is vector data so we will use sf
# shapefile containing the polygons for 935 ruelles vertes across Montreal
rv <- read_sf("input/ruelles-vertes.shp")

# okay, now let's load in some canopy cover data
# this is raster data, so we will use stars
# tif file containing pixels of land cover type across Montreal
cc <- rast("input/canopy-cover.tif")

# Data Investigation/Cleaning --------------------------------
# let's look at the attributes of our ruelles vertes data
head(rv)
# there is some very important information in this data summary
# notably - CRS, data attributes, and geometry column

cc
# rasters look very different than vectors when investigating them
# there are important things to note here as well
# stars object info is often easier to understand if we extract it with sf functions
st_crs(cc)
# this looks like a lot but what is important is that the EPSG (9001)
# is different from the EPSG number in rv - these datasets are projected differently

# let's reproject so that these match
# rasters take a long time to reproject
# for simplicity, let's match rv to cc
# if you wanted to transform the raster, you would use function terra::project()
rv <- st_transform(rv, crs = st_crs(cc))

# Visual Investigation --------------------------------------
# really important to visually inspect spatial data - that is the easiest way to find issues
# investigate ruelles first
mapview(rv)
# then canopy cover (with non-interactive plot because it is a large raster)
plot(cc)

# then do a very quick plot of both together to make sure they line up
ggplot() +
  geom_spatraster(data = cc) +
  geom_sf(data = rv, colour = 'red')

# Save ------------------------------------------------------
# cool! everything looks okay so far. Let's save our transformed vector layer and move on
saveRDS(rv, "input/cleaned/ruelles-vertes-transformed.rds")
