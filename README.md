# A small CMake helper for C++20 modules

I’ve been experimenting with C++ modules across different compilers and build systems, and ended up writing a small CMake helper script that makes the whole thing much less painful.

It doesn’t try to reinvent module support — it relies on CMake’s native named-module features and only adds a thin layer of convenience (shorter target definitions, optional header-unit helpers, and clean presets for Clang/GCC/MSVC).

If you’re playing with modules or want a minimal, practical setup without extra tooling, you might find it useful.

If you want to see larger example, you can check my older project, fully rewritten to use C++ modules:
👉 https://github.com/basvas-jkj/oul (it fails to compile currently)

## Repository structure

auto/
- original script which enables automatic dependency scanning and header units helpers

manual/
- newer script which requires manually declare modules and they dependencies
- it allows faster compilation without dependency scanning
- still in progress

cmake_helpers.cmake
- some useful bash aliases for cmake presets (including autocomplete definition)
- usable in any cmake preset based project without changes

crun
- allows to run built program easily
- requires update to be usable in different projects
