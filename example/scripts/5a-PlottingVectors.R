# Theme -----------------------------------------------------
# Palette set-up in separate script for ease
source('scripts/0-palette.R')

# define theme for ggplot - can do this in the ggplot script as well if desired
th <- theme(panel.border = element_rect(size = 1, fill = NA),
            panel.background = element_rect(fill = canadacol),
            panel.grid = element_line(color = gridcol2, size = 0.2),
            axis.text = element_text(size = 11, color = 'black'),
            axis.title = element_blank())

# Plot -------------------------------------------------------
# transform all layers so they have the same CRS 
# use EPSG 3347 - same projection that Statistics Canada uses
mtlcrs <- 3347
rv <- st_transform(rv, mtlcrs)
allpolys <- st_transform(allpolys, mtlcrs)
wmpols <- st_transform(wmpols, mtlcrs)

# want the bounds of our map to be slightly smaller than the entire island
bbi <- st_bbox(st_buffer(allpolys, 0.75))

# plot all layers together with theme we set above 
# if we were plotting the raster we could use the geom_stars function
ggplot() +
  geom_sf(fill = montrealcol, data = allpolys) + 
  geom_sf(fill = rvcol, col = NA, data = rv) + 
  geom_sf(fill = watercol, col = "#5b5b5b", data = wmpols) + 
  coord_sf(xlim = c(bbi['xmin'], bbi['xmax']),
           ylim = c(bbi['ymin'], bbi['ymax'])) +
  th


# Save -------------------------------------------------------
ggsave(
  'graphics/ruelles-vertes.png',
  width = 10,
  height = 10,
  dpi = 320
)