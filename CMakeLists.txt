cmake_minimum_required (VERSION 3.30)
include("cpp_modules.cmake")
project("cpp_moduly")

add_library(cwl)
target_modules(cwl PUBLIC "src/cwl.cppm")

add_executable(pokus "src/main.cpp")
target_link_libraries(pokus PRIVATE cwl)