## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(sigugr)

sigugr_gpkg <- system.file("extdata", "sigugr.gpkg", package = "sigugr")

sf::st_layers(sigugr_gpkg)

## ----sat----------------------------------------------------------------------
sat_tif <- system.file("extdata", "sat.tif", package = "sigugr")

sat <- terra::rast(sat_tif)

cat(paste("-", names(sat), collapse = "\n"))

## ----mdt----------------------------------------------------------------------
mdt_dir <- system.file("extdata", "mdt", package = "sigugr")

cat(paste("-", list.files(mdt_dir), collapse = "\n"))

## ----clc----------------------------------------------------------------------
clc_gpkg <- system.file("extdata", "clc.gpkg", package = "clc")

sf::st_layers(clc_gpkg)

## ----aggregate----------------------------------------------------------------
temp_dir <- tempdir()

result_files <- aggregate_rasters(mdt_dir, temp_dir, factor = 6)

## ----compose, fig.width=10, fig.height=7, dpi=300, out.width="80%", fig.align='center', fig.cap = "The aggregated and composed raster."----
r_mdt <- compose_raster(temp_dir)

terra::plot(r_mdt)

## ----compose2-----------------------------------------------------------------
mdt <- compose_raster(mdt_dir)

## ----bbox, fig.width=10, fig.height=7, dpi=300, out.width="80%", fig.align='center', fig.cap = "Polygon and bounding box."----
polygon <- sf::st_read(sigugr_gpkg, layer = "lanjaron", quiet = TRUE)

bbox <- generate_bbox(polygon)

plot(sf::st_geometry(bbox))
plot(sf::st_geometry(polygon), add = TRUE)

## ----clip, fig.width=10, fig.height=7, dpi=300, out.width="80%", fig.align='center', fig.cap = "Clipped DTM."----
mdt_bbox <- clip_raster(mdt, bbox, keep_crs = FALSE)

terra::plot(mdt_bbox)

## ----clip-clc, fig.width=10, fig.height=7, dpi=300, out.width="80%", fig.align='center', fig.cap = "Clipped CLC layer."----
clc <- sf::st_read(clc_gpkg, layer = "clc", quiet = TRUE)

clc_polygon <- clip_layer(clc, polygon)

plot(sf::st_geometry(clc_polygon))

## ----save---------------------------------------------------------------------
mdt_tif <- tempfile(fileext = ".tif")
terra::writeRaster(mdt_bbox, mdt_tif, overwrite = TRUE)

clc2_gpkg <- tempfile(fileext = ".gpkg")
sf::st_write(clc_polygon, clc2_gpkg, layer = "clc_polygon", delete_dsn = TRUE, quiet = TRUE)

## -----------------------------------------------------------------------------
evaluate <- FALSE

## ----postgis, eval=evaluate---------------------------------------------------
# conn <- DBI::dbConnect(
#   RPostgres::Postgres(),
#   dbname = "sigugr",
#   host = "localhost",
#   user = "postgres",
#   password = "postgres"
# )
# 
# tables1 <- store_bands(sat_tif, conn, prefix = 'original_')
# 
# tables2 <- store_raster(mdt_tif, conn, table_name = 'mdt')
# 
# tables3 <- store_layers(sigugr_gpkg, conn)
# 
# tables4 <- store_layers(clc2_gpkg, conn)

## ----styles, eval=evaluate----------------------------------------------------
# copy_styles(from = clc_gpkg, to = conn, database = "sigugr", to_layers = "clc_polygon")

## ----echo=FALSE, fig.width=10, fig.height=7, dpi=300, out.width="100%", fig.align='center', fig.cap ="Accessing PostGIS from QGIS."----
knitr::include_graphics("figures/qgis-clc.png")

## ----geoserver, eval=evaluate-------------------------------------------------
# gso <- geoserver(
#   url = "http://localhost:8080/geoserver",
#   user = "admin",
#   password = "geoserver",
#   workspace = "sigugr"
# )
# 
# gso <- gso |>
#   register_datastore_postgis(
#     "sigugr-db",
#     db_name = 'sigugr',
#     host = 'localhost',
#     port = 5432,
#     db_user = 'postgres',
#     db_password = 'postgres',
#     schema = "public"
#   )
# 
# gso |>
#   publish_layer_set(conn)

## ----geoserver2, eval=evaluate------------------------------------------------
# gso |>
#   publish_raster(mdt_tif, layer = 'mdt')
# 
# gso |>
#   publish_bands(sat_tif, prefix = 'original_')

## ----echo=FALSE, fig.width=10, fig.height=7, dpi=300, out.width="100%", fig.align='center', fig.cap ="Accessing GeoServer from QGIS."----
knitr::include_graphics("figures/qgis-mdt.png")

