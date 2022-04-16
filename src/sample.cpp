#include "sample.h"
#include <numeric>

double sample_sum_cpp(const Rcpp::NumericVector& xs) {
    constexpr double init = 0.0;
    return std::accumulate(xs.begin(), xs.end(), init);
}
