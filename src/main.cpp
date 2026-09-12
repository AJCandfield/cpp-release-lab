#include <cstdio>
#include <string_view>

#include <fmt/format.h>

#include "cpp_release_lab/version.hpp"

int main(int argc, char* argv[]) {
  if (argc == 1) {
    fmt::print("Hello, World!\n");
    return 0;
  }

  const std::string_view argument{argv[1]};

  if (argc == 2 && argument == "--version") {
    fmt::print("cpp-release-lab {}\n", cpp_release_lab::version);
    return 0;
  }

  if (argc == 2 && argument == "--help") {
    fmt::print(
        "Usage: cpp-release-lab [--help] [--version]\n"
        "Print a friendly greeting.\n\n"
        "Options:\n"
        "  --help     Show this help text.\n"
        "  --version  Show the application version.\n");
    return 0;
  }

  if (argc == 2) {
    fmt::print(stderr, "cpp-release-lab: invalid argument: {}\n", argument);
  } else {
    fmt::print(stderr, "cpp-release-lab: expected at most one argument\n");
  }
  fmt::print(stderr, "Try 'cpp-release-lab --help' for usage.\n");
  return 2;
}
