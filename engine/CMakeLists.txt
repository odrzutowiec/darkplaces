#------------------------------------------------------------------------------#
#   Copyright (c) 2020 Cloudwalk                                               #
#                                                                              #
#   This program is free software: you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation, either version 3 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
#------------------------------------------------------------------------------#

cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

project(darkplaces C)

include(${CMAKE_SOURCE_DIR}/build/defs.cmake)
include(${UTIL_DIR}/utils.cmake)
include(${UTIL_DIR}/check_config.cmake)
include(${UTIL_DIR}/callback.cmake)

# Initial options
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${LIB_DIR})
set(CMAKE_BUILD_TYPE "")
set(ENGINE_DOWNLOAD_DEPENDS OFF CACHE BOOL "Download all dependencies, compile, and link against them, instead of using system libraries.")
set(ENGINE_BUILD_CLIENT ON CACHE BOOL "Build the client")
set(ENGINE_BUILD_SERVER ON CACHE BOOL "Build the server")
set(ENGINE_BUILD_NAME "darkplaces" CACHE STRING "Engine binary name")
set(ENGINE_BUILD_WINRC "${PROJ_DEFAULT_DIR}/res/darkplaces.rc" CACHE STRING "Location of Windows .rc, usually for icon")
set(GAME_BUILD_CUSTOM_COMMAND "" CACHE STRING "Custom tool to bootstrap. Enter what you would with execute_process")
set(GAME_BUILD_EXTERNAL_PROJECT "" CACHE STRING "External cmake project to add. Enter what you would with ExternalProject_Add")
set(ENGINE_CONFIG_MENU ON CACHE BOOL "Enable menu support")
set(ENGINE_CONFIG_CD ON CACHE BOOL "Enable CD and music support. Actual CDs no longer play with SDL2.")
set(ENGINE_CONFIG_VIDEO_CAPTURE ON CACHE BOOL "Enable video capture support")
set(ENGINE_CONFIG_BUILD_TIMESTAMP ON CACHE BOOL "Add the git commit timestamp to the version string")
set(ENGINE_CONFIG_BUILD_REVISION ON CACHE BOOL "Add the git revision to the version string")

set(ENGINE_LINK_TO_CRYPTO ON CACHE BOOL "Link to d0_blind_id dynamically")
set(ENGINE_LINK_TO_CRYPTO_RIJNDAEL ON CACHE BOOL "Link to d0_blind_id_rijndael dynamically")
set(ENGINE_LINK_TO_ZLIB ON CACHE BOOL "Link to zlib dynamically")
set(ENGINE_LINK_TO_LIBJPEG ON CACHE BOOL "Link to libjpeg dynamically")
set(ENGINE_LINK_TO_LIBODE OFF CACHE BOOL "Link to ODE dynamically")

include(${TGT_DIR}/build.cmake)

hp_build_parse_config()

hp_build_check_config()

hp_build()

#hp_build_callback()