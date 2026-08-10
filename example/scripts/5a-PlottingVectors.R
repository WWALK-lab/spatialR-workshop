# Packages --------------------------------------------------
source('scripts/00-packages.R')


# Data --------------------------------------------------------------------

rv <- read_sf("output/buffers.gpkg")
allpolys <- read_sf("output/islands.gpkg")
wmpols <- read_sf("output/water.gpkg")


# Theme -----------------------------------------------------
# Palette set-up in separate script for ease if we want same colours across multiple maps
source('scripts/0-palette.R')

# define theme for ggplot - can do this in the ggplot script as well if desired
th <- theme(
  panel.border = element_rect(linewidth = 1, fill = NA),
  panel.background = element_rect(fill = canadacol),
  panel.grid = element_line(color = gridcol2, linewidth = 0.2),
  axis.text = element_text(size = 11, color = 'black'),
  axis.title = element_blank()
)

# Plot -------------------------------------------------------
# transform all layers so they have the same CRS
# use EPSG 3347 - same projection that Statistics Canada uses
mtlcrs <- 3347
rv_m <- st_transform(rv, mtlcrs)
allpolys_m <- st_transform(allpolys, mtlcrs)
wmpols_m <- st_transform(wmpols, mtlcrs)

# want the bounds of our map to be slightly smaller than the entire island
bbi <- st_bbox(st_buffer(allpolys_m, 0.75))


# plot all layers together with theme we set above
# if we were plotting the raster we could use the geom_stars function
plot <- ggplot() +
  geom_sf(fill = montrealcol, data = allpolys_m) +
  geom_sf(aes(fill = cancov), data = rv_m) +
  geom_sf(fill = watercol, col = "#5b5b5b", data = wmpols_m) +
  scale_fill_viridis_c(direction = -1) +
  coord_sf(
    xlim = c(bbi['xmin'], bbi['xmax']),
    ylim = c(bbi['ymin'], bbi['ymax'])
  ) +
  th

plot


# Save -------------------------------------------------------
ggsave(
  'graphics/ruelles-vertes.png',
  plot,
  width = 10,
  height = 10,
  dpi = 320
)
