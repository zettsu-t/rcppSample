#' Sum in C++
#'
#' @param xs A numeric vector to sum
#' @return The sum of xs
#'
#' @export
#' @useDynLib anRcppSample, .registration=TRUE
#' @importFrom Rcpp sourceCpp
sample_sum_r <- function(xs) {
  sample_sum_cpp(xs)
}
