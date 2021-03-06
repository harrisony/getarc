require(sf)

one_row <- query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
                       query = c(resultRecordCount = 1))
one_row_bng <- query_layer(
  endpoint = endpoints$gb_wood_pasture_parkland,
  crs = 27700,
  query = c(resultRecordCount = 1)
)

small_feature <-
  query_layer(endpoints$gb_wood_pasture_parkland,
              query = c("where" = "Shape__Area < 30", resultRecordCount = 1))


sql_query <- query_layer(
  endpoint = endpoints$gb_wood_pasture_parkland,
  query = c(resultRecordCount = 1,
            where = "SUBTYPE = 'Parkland' AND INTERPQUAL = 'Medium'")
)
# Perform a spatial query
bbox <-
  st_bbox(c(
    xmin = -1.310819,
    ymin = 51.369722,
    xmax = -1.307946,
    ymax = 51.371520
  ),
  crs = 4326)

spatial_query_bbox <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = bbox)

point <- st_as_sf(data.frame(x = 448171, y = 163733), coords = c("x", "y"), crs = 27700)


spatial_query_point <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = point)

buffer <- st_buffer(point, 1000)

spatial_query_buffer <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = buffer)

ms_nogeom <-
  query_layer(
    endpoints$english_counties,
    return_geometry = FALSE,
    query = c(resultRecordCount = 1)
  )
fs_nogeom <-
  query_layer(endpoint = endpoints$ancient_woodland_england,
    return_geometry = FALSE,
    query = c(resultRecordCount = 1)
  )


awi_2510 <-
  query_layer(endpoint = endpoints$ancient_woodland_england,
            query = c(resultRecordCount = 2510,
                      outFields = "objectid"),
            return_geometry = FALSE)



tibble(OBJECTID = character(0),
       NAME = character(0)
)

no_awi <-
query_layer(endpoint = endpoints$ancient_woodland_england,
            query = c(where = "1=2"),
            out_fields = c("NAME", "OBJECTID"),
            return_geometry = FALSE
)


test_that("query layer works", {
  # Check that resultRecordCount = 1 works
  expect_equal(nrow(one_row),
               1)
  # Check that the function returns a data frame
  expect_equal(class(one_row),
               c("sf", "data.frame"))
  # Test that it transforms data when the crs != 4326
  expect_equal(st_crs(one_row_bng)$epsg,
               27700)
  # Check that sql  where query works
  expect_equal(sql_query$SUBTYPE, "Parkland")
  expect_equal(sql_query$INTERPQUAL, "Medium")
  # Did the spatial query only return one result?
  expect_equal(nrow(spatial_query_bbox),
               1)

  expect_equal(nrow(spatial_query_buffer) >= 1,
               TRUE)
  expect_equal(nrow(spatial_query_point) >= 1,
               TRUE)

  expect_warning(query_layer(endpoint = endpoints$gb_wood_pasture_parkland, query = c(where = "1 = 2")))
  # Does the area query have the desired result
  expect_equal(small_feature$Shape__Area < 30, TRUE)
  # return_geometry = FALSE returns a data.frame for both map servers and feature servers
  expect_equal("data.frame" %in% class(ms_nogeom), TRUE)
  expect_equal("data.frame" %in% class(fs_nogeom), TRUE)

  # the return record count param works properly with get by fids method
  expect_equal(nrow(awi_2510), 2510)

  expect_equal(no_awi, tibble(OBJECTID = character(0),
                              NAME = character(0)
  ))


})
