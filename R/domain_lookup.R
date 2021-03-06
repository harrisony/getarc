#' Domain lookup
#'
#' Get the domains for each coded field
#'
#' This function accepts an object generated by \code{get_layer_details} and returns a look up table of the coded domains
#'
#' @param layer_details a list object generated by \code{get_layer_details}
#' @importFrom tibble tibble
#' @importFrom purrr map_df
#' @importFrom dplyr bind_rows
#' @importFrom dplyr bind_cols
#' @importFrom purrr map2
#' @return a tibble with three columns: the field name, the descriptive value and the coded value
domain_lookup <-
  function(layer_details){

    layer_fields <-
      layer_details$fields

    # If all of the domains are empty then return and empty tibble of the right structure
    if(all(is.na(layer_fields$domain))){
      return(tibble(field_name = character(0), name = character(0), code = character(0)))
    }

    coded_fields <- layer_fields$domain$type == "codedValue"
    coded_fields[is.na(coded_fields)] <- FALSE

    #layer_fields$domain$codedValues[coded_fields]
    field_name <- layer_fields$name[coded_fields]


    dplyr::bind_rows(
      purrr::map2(
        .x = layer_fields$name[coded_fields],
        .y = layer_fields$domain$codedValues[coded_fields],
        ~ dplyr::bind_cols(tibble::tibble(field_name = .x),
                           # Sometimes the code is a character and this stops the df from binding
                           purrr::map_df(.y, as.character))
      )
    )
  }
