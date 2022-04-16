FROM rocker/tidyverse
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y build-essential cmake curl git git-core lcov make wget
RUN apt-get install -y clang clang-tidy

## Set explicitly
ENV R_HOME="/usr/local/lib/R"
RUN Rscript -e 'install.packages(c("remotes", "devtools"))'

## Copy projects
ARG PROJECTS_TOP_DIR=/root/work
ARG R_PROJECT_DIR="${PROJECTS_TOP_DIR}/anRcppSample"
RUN mkdir -p "${R_PROJECT_DIR}"
COPY ./ "${R_PROJECT_DIR}/"

## Testing an R package
WORKDIR "${R_PROJECT_DIR}"
RUN Rscript -e 'devtools::install(".", dependencies = TRUE)'
RUN Rscript -e 'library(anRcppSample);devtools::test();print(covr::package_coverage());lintr::lint_package();devtools::document()'
RUN R CMD build .
RUN R CMD INSTALL anRcppSample_0.0.0.9000.tar.gz

RUN rm -rf "${R_PROJECT_DIR}/tests/build"
RUN mkdir -p "${R_PROJECT_DIR}/tests/build"
WORKDIR "${R_PROJECT_DIR}/tests/build"
RUN cmake ..
RUN make
RUN echo "library(anRcppSample)" | ./test_sample --output-on-failure
RUN make test

WORKDIR "${R_PROJECT_DIR}/tests/build/CMakeFiles/test_sample.dir"
RUN lcov -d . -c -o coverage.info
RUN lcov -r coverage.info "/usr/*" "*/googletest/*" -o coverageFiltered.info
RUN genhtml -o lcovHtml --num-spaces 4 -s --legend coverageFiltered.info
WORKDIR "${R_PROJECT_DIR}"

RUN echo "-I $(find /usr -name R.h | head -1 | xargs dirname)" "$(Rscript -e 'cat(paste(paste0(" -I ", .libPaths(), "/Rcpp/include"), sep="", collapse=" "))')" > _r_includes
RUN clang-tidy src/*.cpp tests/*.cpp -checks=perf\* -- -I src $(cat _r_includes) -I tests/build/googletest-src/googletest/include || echo "Non-zero exit code"
