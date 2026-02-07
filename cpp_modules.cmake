# Created by Basvas j.k.j
# Unlicensed

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (CMAKE_VERSION VERSION_LESS "3.30.0")
	message(FATAL_ERROR "This version of  CMake (${CMAKE_VERSION}) doesn't support 'import std'.")
elseif(DEFINED CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
	message("Use custom value of CMAKE_EXPERIMENTAL_CXX_IMPORT_STD: ${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD}.")
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "3.31.7")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "3.31.11")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "4.0.2")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "a9e1cf81-9932-4810-974b-6eccaf14e457")
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "4.2.3")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
else()
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
	message(WARNING "Unknown version of CMake. (${CMAKE_VERSION})")
	message(STATUS "Use default value of CMAKE_EXPERIMENTAL_CXX_IMPORT_STD. (${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD})")
endif()

set(IS_VS OFF)
set(IS_NINJA OFF)

if(CMAKE_GENERATOR STREQUAL "Visual Studio 17 2022" OR CMAKE_GENERATOR STREQUAL "Visual Studio 18 2026")
	set(IS_VS ON)
elseif(CMAKE_GENERATOR STREQUAL "Ninja" OR CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")
	set(IS_NINJA ON)
endif()

if (IS_NINJA)
	set(CMAKE_CXX_MODULE_STD ON)
	set(CMAKE_CXX_SCAN_FOR_MODULES ON)
elseif(NOT IS_VS)
	message(FATAL_ERROR "${CMAKE_GENERATOR} doesn't support C++ modules.'")
endif()

function("target_modules" target visibility)
	target_sources(${target} ${visibility} FILE_SET CXX_MODULES FILES ${ARGN})
endfunction()
function("target_external_headers" target visibility header)
	if (IS_VS)
		return()
	endif()

	set(output "${CMAKE_CURRENT_BINARY_DIR}/pcm_units/${header}.pcm")

	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		set(PARAMS "/std:c++23preview" "/exportHeader" "/headerName:angle" "${header}" "/ifcOutput" "${output}")
		set(REFERENCE "/std:c++23preview" "/translateInclude" "/headerUnit:angle" "${header}=${output}")
	elseif (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		set(PARAMS "-std=c++23" "-xc++-system-header" "--precompile" "${header}" -o "${output}")
		set(REFERENCE "-fmodule-file=${output}")
	endif()
	
	add_custom_command(
		OUTPUT ${output}
		COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
	)
	target_sources(${target} ${visibility} ${output})
	target_compile_options(${target} ${visibility} ${REFERENCE})
endfunction()
function("target_headers" target visibility header)
	if (IS_VS)
		return()
	endif()

	set(input "${CMAKE_CURRENT_SOURCE_DIR}/${header}")
	set(output "${CMAKE_CURRENT_BINARY_DIR}/pcm_units/${header}.pcm")

	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		set(PARAMS "/std:c++23preview" "/exportHeader" "${input}" "/ifcOutput" "${output}")
		set(REFERENCE "/headerUnit" "${input}=${output}")
	elseif (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		set(PARAMS "-std=c++23" "-xc++-user-header" "--precompile" "${input}" -o "${output}")
		set(REFERENCE "-fmodule-file=${output}")
	endif()

	add_custom_command(
		DEPENDS ${input}
		OUTPUT ${output}
		COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
	)
	target_sources(${target} ${visibility} ${output})
	target_compile_options(${target} ${visibility} ${REFERENCE})
endfunction()

function("init_cpp_modules")
	set(IS_GCC OFF PARENT_SCOPE)
	set(IS_MSVC OFF PARENT_SCOPE)
	set(IS_CLANG OFF PARENT_SCOPE)

	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		set(IS_GCC ON PARENT_SCOPE)
	elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		set(IS_MSVC ON PARENT_SCOPE)
	elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
		set(IS_CLANG ON PARENT_SCOPE)
	endif()
endfunction()


function("import_std" target)
	if (IS_GCC AND CMAKE_VERSION VERSION_LESS "4.0.0")
		message(FATAL_ERROR "This version of  CMake (${CMAKE_VERSION}) doesn't support 'import std' for GCC.")
	elseif (IS_CLANG)
		message(WARNING "Clang is not guaranteed to work.")
	endif()
	set_target_properties(${target} PROPERTIES
			CXX_STANDARD 23
			CXX_EXTENSIONS OFF
			CXX_STANDARD_REQUIRED ON
		)
endfunction()