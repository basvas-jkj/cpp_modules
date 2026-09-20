# header_units example project

add_executable(header_units "main.cpp")
target_header_units(header_units SYSTEM PRIVATE "print" "string")
target_header_units(header_units USER PRIVATE "unit.hpp")