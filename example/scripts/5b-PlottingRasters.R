# Packages --------------------------------------------------
p <- c("stars", "basemaps", "ggplot2")
lapply(p, library, character.only=T)


# Data --------------------------------------------------------------------
cancov <- read_stars('input/canopy-cover.tif')
buff <- readRDS("input/cleaned/buffers.rds")
# let's intersect our land use/canopy cover with the buffers we created 
cc_int <- cancov[buff]


# Plot --------------------------------------------------------------------

# get bounding box of our layer of interest, buffers
bbox <- st_bbox(cc_int)



raster_plot <- ggplot() + 
  geom_stars(data = cc_int) +
  theme_void() +
  coord_equal()


# Save --------------------------------------------------------------------


ggsave(
  'graphics/canopy-cover.png',
  raster_plot,
  width = 10,
  height = 10,
  dpi = 320
)