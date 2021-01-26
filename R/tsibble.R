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
