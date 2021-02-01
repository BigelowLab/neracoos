#' Retrieve the NERACOOS base URL
#'
#' @export
#' @return character, URL for NERACOOS
neracoos_base_url <- function(){
  return("http://www.neracoos.org")
}

#' Retrieve the base URL for the NERACOOS thredds server for buoys
#' 
#' @seealso \href{http://www.neracoos.org/datatools/data_services}{NERACOOS Data Servcies}
#'
#' @export
#' @param what character, extension for URL either 'html' or 'xml'
#' @param catalog character, specifes the 'default', or 'sos' 
#' @return character URL
thredds_base_url <- function(what = c("html", "xml")[1],
                             catalog = c("default", "sos")[1]){
  
  branch <- switch(tolower(catalog[1]),
                   "sos" = "sos_catalog",
                   "catalog")
  file.path(neracoos_base_url(), 
            "thredds", 
            paste(branch, tolower(what[1]), sep = "."))
}


#' Given a catalog uri return a \code{\link[thredds]{CatalogNode}}
#'
#' @export
#' @param program character, the name of the program, if not found
#'   then the top level catalog is returned
#' @param uri character, the url for the catalog node
#' @return \code{\link[thredds]{CatalogNode}}
get_catalog <- function(program = "University of Maine Buoys",
                        uri = thredds_base_url(what = "xml")){

  Top <- thredds::CatalogNode$new(uri)
  cnames <- Top$get_catalog_names()
  ix <- grep(program[1], cnames, fixed = TRUE)
  if (length(ix) > 0){
    X <- Top$get_catalogs(cnames[ix[1]])[[1]]
  } else {
    X <- Top
  }
  return(X)
}


#' Get Maine a Maine buoy reference
#'
#' @export
#' @param suite character, one of these \url{http://www.neracoos.org/thredds/UMO_all.html}{UMO_all}
#' @param buoy character, one of the buoys listed here \url{http://www.neracoos.org/thredds/UMO_historical_realtime_agg.html}{Historic/Realtime Aggregations}
#' @param dataset character, one of the instruments listed here \url{http://www.neracoos.org/thredds/UMO_historical_realtime_agg.html}{datasets}
#' @param form character, either "url" or "ncdf" to specify the type of output
#' @return either a character URL to a dataset, ncdf4 class dataset object, or NULL
get_Maine_buoy <- function(
  suite = "Historic and Realtime Aggregations",
  buoy = "A01",
  dataset = "CTD 1m",
  form = c("url", "ncdf")[1]){

  return_value <- NULL

  if (FALSE){
    suite = "Historic and Realtime Aggregations"
    buoy = "A01"
    dataset = "CTD 1m"
    form = c("url", "ncdf")[1]
  }

  Top <- get_catalog(program = "University of Maine Buoys")
  cnames <- Top$get_catalog_names()
  ix <- grepl(suite[1], cnames, fixed = TRUE)

  if (!any(ix)){
    warning("suite not found: ", suite[1])
    return(return_value)
  } else {
    X <- Top$get_catalogs(cnames[ix][1])[[1]]
  }

  d <- X$list_datasets(form = "table") %>%
    dplyr::as_tibble() %>%
    dplyr::filter(.data$name == dataset[1] & grepl(buoy[1], .data$ID, fixed = TRUE))


  if (nrow(d) == 0){
    warning(sprintf("dataset, %s, not found for buoy, %s", dataset[1], buoy[1]))
    return(return_value)
  } else {
    d_uri <- d$urlPath
    services <- Top$list_services()
    base_uri <- services[['odap']]['base']
    return_value <- paste0(neracoos_base_url(), base_uri, d_uri)
  }

  if ((tolower(form[1]) == 'ncdf') && !is.null(return_value)){
    return_value <- try(ncdf4::nc_open(return_value))
    if (inherits(return_value, "try-error")){
      cat(return_value, "\n")
      return_value <- NULL
    }
  }

  return(return_value)
}