#' Test if ncdf4 object has a dimension
#'
#' @export
#' @param x ncdf4 class object
#' @param name character, name of the dimension
#' @return logical TRUE if the dimension is present
nc_has_dim <- function(x, name = "time"){
  name %in% names(x$dim)
}

#' Test if ncdf4 object has a variable
#'
#' @export
#' @param x ncdf4 class object
#' @param name character, name of the variable
#' @return logical TRUE if the variable is present
nc_has_var <- function(x, name = "foo"){
  name %in% names(x$var)
}


#' Retrieve the time dimension from a ncdf4 class object
#'
#' @export
#' @param x ncdf4 class object
#' @return numerc vector of POSIXct
nc_get_time <- function(x){

  stopifnot(nc_has_dim(x, "time"))

  time <- x$dim$time$vals
  t0 <- as.POSIXct(x$dim$time$units,
                   format = "days since %Y-%m-%d %H:%M:%S",
                   tz = "UTC")
  return( time * (24 * 60 * 60) + t0 )
}


#' Retrieve a variable by name
#'
#' @export
#' @param x ncdf4 class object
#' @param name the name of the variable to retrieve
#' @param ... other arguments for \code{\link[ncdf4]{ncvar_get}}
#' @return vector of variable values
nc_get_var <- function(x, name = "salinity", ...){

  stopifnot(nc_has_var(x, name))

  return(ncdf4::ncvar_get(x, name, ...))
}

#' Retrieve a dimension by name
#'
#' @export
#' @param x ncdf4 class object
#' @param name the name of the dimension to retrieve
#' @return vector of dimension values
nc_get_dim <- function(x, name = "lon"){

  stopifnot(nc_has_dim(x, name))

  return(x$dim[[name]]$vals)
}

#' Retrieve location information (lon, lat, z)
#' @export
#' @param x ncdf4 class object
#' @param dims character, the name of the dimensions to retrieve
#' @return a named list
nc_get_location <- function(x, dims = c("lon", "lat", "depth")){

  sapply(dims,
         function(name){
           nc_get_dim(x, name)
         }, simplify = FALSE)

}

#' Retrieve a table of dimensions and variables by name.  Dimensions
#' and variables must have same length.
#'
#' @export
#' @param x ncdf4 class object
#' @param dnames character, the name of the dimensions to retrieve
#' @param vnames character, the name of the variables to retrieve
#' @param ... other arguments for \code{nc_get_var}
#' @return table of dimensions and variables
nc_get_table <- function(x, dnames = "time",
                         vnames = c("conductivity",
                                    "temperature",
                                    "salinity",
                                    "sigma_t"),
                         ...){

  if (FALSE){
    dnames = "time"
    vnames = c("conductivity",
               "temperature",
               "salinity",
               "sigma_t")
  }

  d <- sapply(dnames,
              function(name){
                if (name == "time"){
                  r <- nc_get_time(x)
                } else {
                  r <- nc_get_dim(x, name)
                }
                r
              }, simplify = FALSE)
  v <- sapply(vnames,
              function(name){
                nc_get_var(x, name, ...)
              }, simplify = FALSE)
  r <- d %>%
    dplyr::as_tibble() %>%
    dplyr::bind_cols(v %>% dplyr::as_tibble())

  return(r)
}
