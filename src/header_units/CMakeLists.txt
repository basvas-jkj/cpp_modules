# header_units example project

add_executable(header_unit_example "main.cpp" )
target_headers(header_unit_example PRIVATE "unit.hpp")
target_external_headers(header_unit_example PRIVATE "print")
target_external_headers(header_unit_example PRIVATE "string")
