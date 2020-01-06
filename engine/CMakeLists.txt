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

set(option_project "$ENV{HPOPTION_PROJECT}")
set(option_project_dir "$ENV{HPOPTION_PROJECT_DIR}")

if(NOT DEFINED "$ENV{HPBUILD_FROM_SCRIPT}")
	if(UNIX)
		execute_process(WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/..
			COMMAND bash ./build.sh --auto --from-cmake --nocache --config-dir=${option_project_dir} ${option_project}
			RESULT_VARIABLE status
		)
		if(${status} GREATER 0)
			message(FATAL_ERROR "The build script failed. CMake cannot continue.")
		endif()
		include("${CMAKE_SOURCE_DIR}/../.temp.cmake")
	else()
		message("The build script requires a Unix environment. I'll make this work on standard Windows later. For now, I hope you know what you're doing.")
	endif()
endif()

project(${option_project})

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
# TODO: Add proper date string based on author date, for reproducible builds.
# TZ=UTC git show -s --format=%ad --date='format-local:%a %b %d %Y %H:%I:%S UTC'

### CHECKS ###

# Platform ID stuff...
# Because "internally inconsistent" is the CMake Way(tm)
if(UNIX)
	if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
		set(LINUX TRUE) # CMake please.
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
		set(FREEBSD TRUE) # CMAKE PLEASE.
	elseif(${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
		set(SUN_OS TRUE) # Can I stop now?
	elseif(APPLE)
		set(DARWIN TRUE)
	endif()
elseif(WIN32)
	if(MINGW OR CYGWIN)
		set(WIN_GNU TRUE)
	elseif(MSVC)
		set(WIN_VS TRUE)
	endif()
endif()

if("${option_project_dir}" STREQUAL "")
	message(FATAL_ERROR "option_project_dir is undefined. If you got here from the build script or used CMake directly, one or both of them are broken again.")
endif()

include("${option_project_dir}/config.cmake")

if(ENGINE_EXE_NAME STREQUAL "") # Cannot be empty
    message(FATAL_ERROR "You must give the executable a name.")
endif()

if(ENGINE_EXE_NAME MATCHES "[* *]") # Cannot contain spaces.
    message(FATAL_ERROR "The executable name must not contain spaces.")
endif()

set(ENGINE_DIR "${HP_DIR}/src") 		# Engine source code
set(LIB_DIR "${MODULE_DIR}/libs")		# CMake modules for 3rd party libraries.

### INCLUDE ###
include("${MODULE_DIR}/engine.cmake")
