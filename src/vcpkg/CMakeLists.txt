# vcpkg example project

find_package(nlohmann_json CONFIG REQUIRED)

add_executable(vcpkg "main.cpp")
target_link_libraries(vcpkg PRIVATE nlohmann_json::nlohmann_json)
vcpkg_header_units(vcpkg PRIVATE "nlohmann/json.hpp")