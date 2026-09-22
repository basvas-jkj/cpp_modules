# named_modules example project

add_library(cwl)
target_sources(cwl PUBLIC "cwl.cpp")
target_modules(cwl PUBLIC "cwl.mpp")

add_executable(named_modules "main.cpp")
target_link_libraries(named_modules cwl)