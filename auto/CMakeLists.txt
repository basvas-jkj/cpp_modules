cmake_minimum_required (VERSION 3.30)
include("cpp_auto_moduly.cmake")
project("cpp_auto_moduly")

add_subdirectory("src/named_modules")
add_subdirectory("src/import_std")

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	add_subdirectory("src/header_units")
	add_subdirectory("src/vcpkg")
endif()