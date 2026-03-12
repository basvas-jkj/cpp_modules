cmake_minimum_required (VERSION 3.30)
include("cpp_modules.cmake")

project("cpp_moduly")

add_subdirectory("src/named_modules")
add_subdirectory("src/import_std")
add_subdirectory("src/header_units")
add_subdirectory("src/vcpkg")