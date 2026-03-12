# header_units example project

add_executable(header_units "main.cpp")
system_header_units(header_units PRIVATE "print" "string")
user_header_units(header_units PRIVATE "unit.hpp")