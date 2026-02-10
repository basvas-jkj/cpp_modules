# vcpkg example project

find_package(nlohmann_json CONFIG REQUIRED)

add_executable(vcpkg_example "main.cpp")
target_link_libraries(vcpkg_example PRIVATE nlohmann_json::nlohmann_json)