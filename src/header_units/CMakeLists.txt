# header_units example project

system_header_units("print" "string")
user_header_units("unit.hpp")

add_executable(header_units "main.cpp" )
target_header_units(header_units PRIVATE "unit.hpp" "print" "string")