#ifndef SRC_SAMPLE_H
#define SRC_SAMPLE_H

#include <Rcpp.h>

//' Sum in C++
//'
//' @param xs A numeric vector to sum
//' @return The sum of xs
// [[Rcpp::export]]
extern double sample_sum_cpp(const Rcpp::NumericVector& xs);

#endif // SRC_SAMPLE_H
