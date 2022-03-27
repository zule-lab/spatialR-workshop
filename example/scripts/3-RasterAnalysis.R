# Packages --------------------------------------------------
# all packages should already be installed, we just need to load them
p <- c("sf", "stars", "dplyr", "mapview")
lapply(p, library, character.only=T)

# Data ------------------------------------------------------
rv <- readRDS("input/cleaned/ruelles-vertes-merged.rds")
buff <- readRDS("input/cleaned/buffers.rds")
pts <- readRDS("input/cleaned/sampling-points.rds")
cc <- read_stars("input/canopy-cover.tif")

# Buffers ---------------------------------------------------
# let's intersect our land use/canopy cover with the buffers we created 
cc_int <- cc[buff]
mapview(cc_int)

# let's calculate the percent of canopy cover (value == 4) in each ruelle
# number of canopy cover pixels / total number of pixels
f <- function(x) { length(which(x == 4)) / length(x) }
# aggregated for each ruelle individually
tot <- aggregate(cc, buff, f)
# now add the percent canopy values to the buffer dataset
buff$percan <- tot$canopy.cover.tif

# NOTE: if we were doing an analysis with a raster like temperature
# we could aggregate across each buffer and return a value using a function - like mean, max, min, etc.
a <- aggregate(cc, buff, max)

# Sample Points ----------------------------------------------
# we can also extract the raster value at each of our sampling points 
pts$landuse <- st_extract(cc, pts)

# Save -------------------------------------------------------
# save buffer as final output 
# gpkg is a great file output type - and currently how we contribute to the ZULE repository
write_sf(buff, "output/buffers.gpkg")

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
