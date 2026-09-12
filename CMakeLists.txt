cmake_minimum_required(VERSION 3.25)

file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" CPP_RELEASE_LAB_VERSION)
string(STRIP "${CPP_RELEASE_LAB_VERSION}" CPP_RELEASE_LAB_VERSION)
if(NOT CPP_RELEASE_LAB_VERSION MATCHES "^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)$")
  message(FATAL_ERROR "VERSION must contain a canonical MAJOR.MINOR.PATCH version")
endif()

project(cpp_release_lab VERSION "${CPP_RELEASE_LAB_VERSION}" LANGUAGES CXX)

include(CTest)
include(GNUInstallDirs)

find_package(fmt CONFIG REQUIRED)

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated/cpp_release_lab")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/include/version.hpp.in"
  "${CMAKE_CURRENT_BINARY_DIR}/generated/cpp_release_lab/version.hpp"
  @ONLY
)

add_executable(cpp-release-lab src/main.cpp)
target_link_libraries(cpp-release-lab PRIVATE fmt::fmt)
target_include_directories(
  cpp-release-lab
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/generated"
)
target_compile_features(cpp-release-lab PRIVATE cxx_std_20)
set_target_properties(
  cpp-release-lab
  PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD_REQUIRED ON
)

if(MSVC)
  target_compile_options(cpp-release-lab PRIVATE /W4 /WX /permissive-)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(
    cpp-release-lab
    PRIVATE -Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Werror
  )
endif()

if(BUILD_TESTING)
  add_test(
    NAME cli.hello
    COMMAND
      "${CMAKE_COMMAND}"
      "-DEXECUTABLE=$<TARGET_FILE:cpp-release-lab>"
      "-DEXPECTED_EXIT=0"
      "-DEXPECTED_STDOUT=Hello, World!\n"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCli.cmake"
  )
  add_test(
    NAME cli.version
    COMMAND
      "${CMAKE_COMMAND}"
      "-DEXECUTABLE=$<TARGET_FILE:cpp-release-lab>"
      "-DCLI_ARGUMENT=--version"
      "-DEXPECTED_EXIT=0"
      "-DEXPECTED_STDOUT=cpp-release-lab ${PROJECT_VERSION}\n"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCli.cmake"
  )
  add_test(
    NAME cli.help
    COMMAND
      "${CMAKE_COMMAND}"
      "-DEXECUTABLE=$<TARGET_FILE:cpp-release-lab>"
      "-DCLI_ARGUMENT=--help"
      "-DEXPECTED_EXIT=0"
      "-DEXPECTED_STDOUT=Usage: cpp-release-lab [--help] [--version]\nPrint a friendly greeting.\n\nOptions:\n  --help     Show this help text.\n  --version  Show the application version.\n"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCli.cmake"
  )
  add_test(
    NAME cli.invalid
    COMMAND
      "${CMAKE_COMMAND}"
      "-DEXECUTABLE=$<TARGET_FILE:cpp-release-lab>"
      "-DCLI_ARGUMENT=--unknown"
      "-DEXPECTED_EXIT=2"
      "-DEXPECTED_STDERR=cpp-release-lab: invalid argument: --unknown\nTry 'cpp-release-lab --help' for usage.\n"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCli.cmake"
  )
  add_test(
    NAME cli.multiple-arguments
    COMMAND
      "${CMAKE_COMMAND}"
      "-DEXECUTABLE=$<TARGET_FILE:cpp-release-lab>"
      "-DCLI_ARGUMENTS=--help;--version"
      "-DEXPECTED_EXIT=2"
      "-DEXPECTED_STDERR=cpp-release-lab: expected at most one argument\nTry 'cpp-release-lab --help' for usage.\n"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCli.cmake"
  )
endif()

install(TARGETS cpp-release-lab RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES LICENSE DESTINATION ".")

set(CPACK_PACKAGE_NAME "cpp-release-lab")
set(CPACK_PACKAGE_VENDOR "AJ Candfield")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A small C++ release-engineering example")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/package")
set(CPACK_PACKAGE_FILE_NAME
    "cpp-release-lab-${PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
if(WIN32)
  set(CPACK_GENERATOR ZIP)
else()
  set(CPACK_GENERATOR TGZ)
endif()
include(CPack)
