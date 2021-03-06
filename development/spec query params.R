#' Parse Query URL
#'
#' Parse a query url to return an R function to get the data
#'
#' This function enables the user to supply a
#' query url for a data source and it will parse the parameters returning a function
#'
#' @param url a string defining the url of the query.


parse_query_url <-
  function(url, include_query = FALSE){
    url <- URLdecode(url)
    host <- str_extract(url, "^https.+(\\.com)")
    instance <- str_remove(url, host) %>% str_extract("^/[A-Za-z0-9]+/") %>% str_remove_all("/")
    feature_server <- str_extract(url, "services/.+/FeatureServer") %>% str_remove_all("services/|/FeatureServer")
    layer_id <- str_extract(url, "FeatureServer/.+/query") %>% str_remove_all("FeatureServer/|/query")

    if(include_query){
      query_string <- str_extract(url, "query\\?.+") %>% str_remove("^query\\?")
      parameters <- str_split(query_string, "&") %>% unlist()

      parameter <- str_extract(parameters, "^[A-Za-z0-9]+")
      value <- str_remove(parameters, "[A-Za-z0-9]+=")

      query <- value
      names(query) <- parameter

    }else{
        query <- NULL
      }


    specify_layer_params(host, instance, feature_server, layer_id, query)
  }


# Specify the URL for SSSIs
url <- "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/SSSI_England/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
# Parse the url into a get function
get_sssi <- parse_query_url(url, include_query = TRUE)
# Get the data, passing an additional parameter to only return one feature
one_sssi <- get_sssi(query = c("resultRecordCount" = "1"))
