# Using Rcpp in C++ unit tests

After installing this package, we can test C++ code in this package with Google Test.

## Test C++ code

```bash
mkdir -p tests/build
cd tests/build
cmake ..
make
make test
cd CMakeFiles/test_sample.dir
lcov -d . -c -o coverage.info
lcov -r coverage.info "/usr/*" "*/googletest/*" "/opt/boost*" -o coverageFiltered.info
genhtml -o lcovHtml --num-spaces 4 -s --legend coverageFiltered.info
cd ../../../..
```

## Test all

```bash
docker build -t rcpp_sample . --progress=plain
```
