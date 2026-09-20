# Created by Basvas j.k.j <basvas@seznam.cz>
# https://github.com/basvas-jkj/cpp_modules
# Unlicensed <https://unlicense.org>

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
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
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "4.3.4")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
elseif(CMAKE_VERSION VERSION_LESS_EQUAL "4.4.3")
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "f35a9ac6-8463-4d38-8eec-5d6008153e7d")
else()
	set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "f35a9ac6-8463-4d38-8eec-5d6008153e7d")
	message(WARNING "Unknown version of CMake. (${CMAKE_VERSION})")
	message(STATUS "Use default value of CMAKE_EXPERIMENTAL_CXX_IMPORT_STD. (${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD})")
endif()

set(IS_VS OFF)
set(IS_NINJA OFF)
set(visibilities PUBLIC PRIVATE INTERFACE)

if(CMAKE_GENERATOR STREQUAL "Visual Studio 17 2022" OR CMAKE_GENERATOR STREQUAL "Visual Studio 18 2026")
	set(IS_VS ON)
	set(CMAKE_CXX_MODULE_STD ON)

	if (CMAKE_GENERATOR_TOOLSET STREQUAL "ClangCl")
		message(FATAL_ERROR "Clang-cl doesn't support modules with ${CMAKE_GENERATOR}.")
	endif()
elseif(CMAKE_GENERATOR STREQUAL "Ninja" OR CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")
	set(IS_NINJA ON)
	set(CMAKE_CXX_MODULE_STD ON)
else()
	message(FATAL_ERROR "${CMAKE_GENERATOR} doesn't support C++ modules.'")
endif()

macro(__parse_fileset visibility)
	set(single FILE_SET)
	set(multi BASE_DIRS FILES)
	cmake_parse_arguments("arg_${visibility}" "" "${single}" "${multi}" "${ARGN}")

	if (arg_${visibility}_FILE_SET AND NOT arg_${visibility}_UNPARSED_ARGUMENTS)
		set(fileset_${visibility} ON)
	else()
		set(fileset_${visibility} OFF)
	endif()
endmacro()
macro(__parse_args)
	cmake_parse_arguments(arg "" "" "${visibilities}" "${ARGV}")

	foreach(v IN LISTS visibilities)
		if (arg_${v})
			__parse_fileset(${v})
		endif()
	endforeach()
endmacro()

function("target_modules" target)
	__parse_args(${ARGN})

	foreach(v IN LISTS visibilities)
		if (fileset_${v} STREQUAL "ON")
			target_sources(${target} ${v}
				FILE_SET ${arg_${v}_FILE_SET}
				TYPE CXX_MODULES
				BASE_DIRS ${arg_${v}_BASE_DIRS}
				FILES ${arg_${v}_FILES}
			)
		elseif (fileset_${v} STREQUAL "OFF")
			target_sources(${target} ${v} FILE_SET cxx_modules_${v} TYPE CXX_MODULES FILES ${arg_${v}})
		endif()
	endforeach()
endfunction()
function("target_headers" target)
	__parse_args(${ARGN})

	foreach(v IN LISTS visibilities)
		if (fileset_${v} STREQUAL "ON")
			target_sources(${target} ${v}
				FILE_SET ${arg_${v}_FILE_SET}
				TYPE HEADERS
				BASE_DIRS ${arg_${v}_BASE_DIRS}
				FILES ${arg_${v}_FILES}
			)
		elseif (fileset_${v} STREQUAL "OFF")
			target_sources(${target} ${v} FILE_SET headers_${v} TYPE HEADERS FILES ${arg_${v}})
		endif()
	endforeach()
endfunction()
function("target_header_units" target type)
	if(IS_VS)
		return()
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		message(FATAL_ERROR "${CMAKE_GENERATOR} with ${CMAKE_CXX_COMPILER_ID} is not supported currently.")
	elseif(NOT (type STREQUAL "SYSTEM" OR type STREQUAL "USER" OR type STREQUAL "VCPKG"))
		message(SEND_ERROR "Header unit can't have ${type} type (supported values: SYSTEM, USER, VCPKG).")
		return()
	endif()

	cmake_parse_arguments(arg "" "" "${visibilities}" "${ARGN}")

	foreach(v IN LISTS visibilities)
		foreach(header IN LISTS arg_${v})
			__init_header_pcm("${header}" pcm_path)
			__init_target_name("${header}" header_unit_target)
			__init_reference("${header}" "${pcm_path}" REFERENCE)
		
			__add_header_unit("${type}" "${header_unit_target}" "${header}" "${pcm_path}")
			add_dependencies(${target} "${header_unit_target}")
			target_compile_options(${target} ${v} ${REFERENCE})
		endforeach()
	endforeach()
endfunction()

function(__init_header_pcm header pcm)
	set(${pcm} "${CMAKE_CURRENT_BINARY_DIR}/pcm_units/${header}.pcm" PARENT_SCOPE)
endfunction()
function(__init_target_name file_name target_name)
	string(MD5 file_hash "${CMAKE_CURRENT_LIST_FILE}")
	string(REGEX REPLACE "[^A-Za-z0-9_+\\-\\.]" "_" sanitised ${file_name})
	set(${target_name} "${sanitised}_${file_hash}" PARENT_SCOPE)
endfunction()
function(__init_reference header pcm reference)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
		set(${reference} "-fmodule-file=${pcm}" PARENT_SCOPE)
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		#g++ -fmodules  unit.hpp main.cpp
		set(${reference} "-fmodules" "-include" "${header}" PARENT_SCOPE)
	else()
		message(WARNING "${CMAKE_GENERATOR} with ${CMAKE_CXX_COMPILER_ID} is not supported currently.")
	endif()
endfunction()
function(__add_header_unit type header_unit_target header pcm_path)
	if(TARGET "${header_unit_target}")
		return()
	endif()
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
		if (CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
			set(std "/std:c++latest")
		else()
			set(std "-std=c++${CMAKE_CXX_STANDARD}")
		endif()
		
		
		if (type STREQUAL "SYSTEM")
			set(PARAMS
				${std}
				"-xc++-system-header"
				"--precompile" "${header}"
				"-o" "${pcm_path}"
			)
		elseif(type STREQUAL "USER")
			set(PARAMS
				${std}
				"-xc++-user-header"
				"--precompile" "${CMAKE_CURRENT_SOURCE_DIR}/${header}"
				"-o" "${pcm_path}"
			)
		else()
			set(VCPKG_INCLUDE_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
			set(PARAMS
				${std}
				"-xc++-user-header"
				"--precompile" "${VCPKG_INCLUDE_PATH}/${header}"
				"-I" "${VCPKG_INCLUDE_PATH}"
				"-o" "${pcm_path}"
			)
		endif()
	endif()

	if (type STREQUAL "SYSTEM")
		add_custom_command(
			OUTPUT ${pcm_path}
			COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
			COMMAND ${CMAKE_COMMAND} -E touch ${pcm_path}
			VERBATIM
		)
	elseif(type STREQUAL "USER")
		add_custom_command(
			DEPENDS "${header}"
			OUTPUT ${pcm_path}
			COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
			COMMAND ${CMAKE_COMMAND} -E touch ${pcm_path}
			VERBATIM
		)
	else()
		add_custom_command(
			DEPENDS "${VCPKG_INCLUDE_PATH}/${header}"
			OUTPUT ${pcm_path}
			COMMAND ${CMAKE_CXX_COMPILER} ${PARAMS}
			COMMAND ${CMAKE_COMMAND} -E touch ${pcm_path}
			VERBATIM
	)
	endif()
	add_custom_target("${header_unit_target}" DEPENDS ${pcm_path})
endfunction()