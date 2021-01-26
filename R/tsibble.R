#' Compute difftime on a vector in user specified units
#' 
#' @export
#' @seealso \href{https://stackoverflow.com/questions/40470389/diff-for-posixct-with-units-like-in-difftime}{stackoverflow post}
#' @param x POSIXct time vector
#' @param units character, one of "secs" (default), "mins", "hours", "days"
#' @return \code{difftime} object with specified units
diff_time <- function(x, units= c("secs", "mins", "hours", "days")[1]) {
  
  div = c("secs"=1, "mins"=60, "hours"=3600, "days" = 3600*24)
  
  if(is.na(match(units, names(div)))) {
    stop(sprintf('Please specify either units as one of: %s', paste(names(div), collapse = ", ")))
  } else {
    x = diff(as.numeric(x))/div[match(units, names(div))]
    as.difftime(x, units=units) 
  }
}

#' Convert a buoy tibble to a tsibble
#'
#' @export
#' @param x tibble of buoy data
#' @return tsibble
buoy_tsibble <- function(x){
  x <- x %>%
    dplyr::arrange(.data$time) %>%
    dplyr::distinct(.data$time, .keep_all = TRUE) %>%
    tsibble::as_tsibble(index = .data$time, regular = FALSE)
}

#' Regularize an irregular tsibble using the specified interval and function
#'
#' @seealso \code{\link[tsibble]{index_by}}
#' @seealso \code{\link[lubridate]{round_date}}
#' @seealso \href{https://blog.earo.me/2018/12/20/reintro-tsibble/#new-time-based-verbs}{blog-post}
#' @export
#' @param x irregular tsibble
#' @param unit character, the regularization interval, by default "30 min"
#' @param fun function, the name of the function to apply for the regularization, by default `lubridate::date_round`
#' @return regularized tsibble
regularize <- function(x,
                       unit = "30 min",
                       fun = lubridate::round_date){
 x %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(time = fun(.data$time, unit)) %>%
    tsibble::as_tsibble(index = .data$time, regular = TRUE)
}
