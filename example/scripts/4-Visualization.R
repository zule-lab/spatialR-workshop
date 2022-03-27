# Packages --------------------------------------------------
p <- c("sf", "osmdata", "ggplot2")
lapply(p, library, character.only=T)

# Data ------------------------------------------------------
rv <- readRDS("input/cleaned/ruelles-vertes-merged.rds")

# OSM Base Data Download -------------------------------------
# set up bounding box - order: xmin, ymin, xmax, ymax
bb <- c(xmin = -74.0788,
        ymin = 45.3414,
        xmax = -73.3894,
        ymax = 45.7224)

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
