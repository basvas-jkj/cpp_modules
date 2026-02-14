# header_units example project

system_header_units("print" "string")
user_header_units("unit.hpp")

add_executable(header_unit_example "main.cpp" )
target_header_units(header_unit_example PRIVATE "unit.hpp" "print" "string")