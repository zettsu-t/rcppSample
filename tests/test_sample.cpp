#include "sample.h"
#include <cstring>
#include <gtest/gtest.h>
#define R_INTERFACE_PTRS
#include <Rembedded.h>
#include <Rinterface.h>

namespace {
int custom_r_readconsole(const char *prompt, unsigned char *buf, int buflen, int hist) {
    constexpr int return_code = 1;
    const std::string r_code{"library(anRcppSample)\n"};
    const auto r_code_buf_size = r_code.size() + 1;

    if (!buf || !buflen) {
        return return_code;
    }
    *buf = '\0';

    if (static_cast<decltype(r_code_buf_size)>(buflen) < r_code_buf_size) {
        return return_code;
    }

    std::strncpy(reinterpret_cast<char*>(buf), r_code.c_str(), r_code_buf_size);
    return return_code;
}
} // namespace

class TestAll : public ::testing::Test {};
TEST_F(TestAll, Small) {
    const Rcpp::NumericVector arg {1.0, 0.5, 0.25};
    const auto actual = sample_sum_cpp(arg);
    EXPECT_EQ(1.75, actual);
}

int main(int argc, char *argv[]) {
    char name[] = "test_sample";
    char arg1[] = "--no-save";
    char *args[]{name, arg1, nullptr};
    Rf_initEmbeddedR((sizeof(args) / sizeof(args[0])) - 1, args);
    ptr_R_ReadConsole = custom_r_readconsole;
    R_ReplDLLinit();
    R_ReplDLLdo1();

    ::testing::InitGoogleTest(&argc, argv);
    auto result = RUN_ALL_TESTS();
    Rf_endEmbeddedR(0);
    return result;
}
