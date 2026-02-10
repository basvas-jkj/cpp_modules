# Created by Basvas j.k.j <basvas@seznam.cz>
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
elseif(NOT IS_VS)
	message(FATAL_ERROR "${CMAKE_GENERATOR} doesn't support C++ modules.'")
endif()

function("target_modules" target visibility)
	target_sources(${target} ${visibility} FILE_SET CXX_MODULES FILES ${ARGN})
endfunction()
function("target_external_headers" target visibility header)
	if (IS_VS)
		return()
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		message(FATAL_ERROR "${CMAKE_GENERATOR} with ${CMAKE_CXX_COMPILER_ID} is not supported currently.")
	endif()

	set(output "${CMAKE_CURRENT_BINARY_DIR}/pcm_units/${header}.pcm")
	set(PARAMS
			"-std=c++23"
			"-xc++-system-header"
			"--compile" "${header}" 
			"-o" "${output}")
	set(REFERENCE "-fmodule-file=${output}")
	
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
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		message(FATAL_ERROR "${CMAKE_GENERATOR} with ${CMAKE_CXX_COMPILER_ID} is not supported currently.")
	endif()

	set(input "${CMAKE_CURRENT_SOURCE_DIR}/${header}")
	set(output "${CMAKE_CURRENT_BINARY_DIR}/pcm_units/${header}.pcm")
	set(PARAMS
			"-std=c++23"
			"-xc++-user-header"
			"--compile" "${input}"
			"-o" "${output}"
	)
	set(REFERENCE "-fmodule-file=${output}")

	add_custom_command(
		DEPENDS ${input}
		OUTPUT ${output}
		COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
	)
	target_sources(${target} ${visibility} ${output})
	target_compile_options(${target} ${visibility} ${REFERENCE})
endfunction()