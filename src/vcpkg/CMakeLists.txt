# vcpkg example project

find_package(nlohmann_json CONFIG REQUIRED)

vcpkg_header_units("nlohmann/json.hpp")

add_executable(vcpkg_example "main.cpp")
target_link_libraries(vcpkg_example PRIVATE nlohmann_json::nlohmann_json)
target_header_units(vcpkg_example PRIVATE "nlohmann/json.hpp")