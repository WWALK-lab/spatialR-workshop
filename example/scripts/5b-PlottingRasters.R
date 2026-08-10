# Packages --------------------------------------------------
source('scripts/00-packages.R')
source('scripts/0-palette.R')


# Data --------------------------------------------------------------------
cancov <- rast('input/canopy-cover.tif')
buff <- readRDS("input/cleaned/buffers.rds")

# let's intersect our land use/canopy cover with the buffers we created
# first we crop to the extent of the polygons
cc_crop <- crop(cancov, buff)
# then mask out everything outside the actual polygon geometry
cc_int <- mask(cc_crop, buff)


# Plot --------------------------------------------------------------------

# get bounding box of our layer of interest, buffers

# clarify what the categories in the raster mean
cls <- data.frame(
  id = 1:5,
  cover = c("low_imp", "high_imp", "low_veg", "high_veg", "water")
)
levels(cc_int) <- cls

raster_plot <-
  ggplot() +
  geom_spatraster(data = cc_int) +
  scale_fill_manual(
    values = c('lightgrey', 'darkgrey', 'lightgreen', 'darkgreen', 'darkblue'),
    na.value = NA
  )


raster_plot

# Save --------------------------------------------------------------------

ggsave(
  'graphics/canopy-cover.png',
  raster_plot,
  width = 10,
  height = 10,
  dpi = 320
)
