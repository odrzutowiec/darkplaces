#   ----------------------------------------------------------------------------
#	COPYRIGHT (C) 2018-2019 David Knapp
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   ----------------------------------------------------------------------------

### --- HORSEPOWER MAIN CMAKE FILE --- ###

### BASICS ###
cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)
project(horsepower)

### VARIABLES ###

# Because I'm lazy.
set(HP_DIR "${CMAKE_SOURCE_DIR}")

set(MODULE_DIR "${HP_DIR}/build")

# Get revision from git.
execute_process(
	COMMAND git rev-parse --short HEAD
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE HP_REV
	OUTPUT_STRIP_TRAILING_WHITESPACE
)

include("${MODULE_DIR}/preload.cmake")

### CHECKS ###

if(ENGINE_EXE_NAME STREQUAL "") # Cannot be empty
    message(FATAL_ERROR "You must give the executable a name.")
endif()

if(ENGINE_EXE_NAME MATCHES "[* *]") # Cannot contain spaces.
    message(FATAL_ERROR "The executable name must not contain spaces.")
endif()

set(ENGINE_DIR "${HP_DIR}/src") 		# Engine source code
set(LIB_DIR "${MODULE_DIR}/libs")		# CMake modules for 3rd party libraries.

# Platform ID stuff...
# Because "internally inconsistent" is the CMake Way(tm)
if(UNIX AND NOT APPLE)
	if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
		set(LINUX TRUE) # CMake please.
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
		set(FREEBSD TRUE) # CMAKE PLEASE.
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
		set(SUN_OS TRUE) # Can I stop now?
	endif()
elseif(APPLE)
	set(DARWIN TRUE)
endif()

### INCLUDE ###
include("${MODULE_DIR}/engine.cmake")
