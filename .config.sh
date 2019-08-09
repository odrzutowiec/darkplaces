#!/bin/bash

# How many threads should the compile run on?
BUILD_THREADS="1"

# Put any extra options you'd like to pass to CMake here.
CMAKE_OPTIONS="-DCMAKE_BUILD_TYPE='Debug'"

# Pick your platform generator here. Run "cmake -G" to get a list of generators for your platform.

# For any Unix/Unix-like system
UNIX_GEN='Unix Makefiles'

# For Windows MSYS2
WIN_GEN='MSYS Makefiles'

# For Mac
MAC_GEN='Xcode'
