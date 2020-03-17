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

add_executable(client)

find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(CURL REQUIRED)
find_package(SDL2 REQUIRED)
find_package(Vorbis REQUIRED)
find_package(Crypto)

include("${TGT_DIR}/client/flags.cmake")

target_sources(client PRIVATE
	"${OBJ_CL}"
	"${OBJ_MENU}"
	"${OBJ_SND_COMMON}"
	"${OBJ_CD_COMMON}"
	"${OBJ_VIDEO_CAPTURE}"
	"${OBJ_COMMON}"
)

if(WIN32)
	target_sources(client PRIVATE ${ENGINE_BUILD_WINRC})
endif()

#add_dependencies(client d0_blind_id SDL2 zlib PNG JPEG curl)

set_target_properties(client PROPERTIES
	OUTPUT_NAME "${ENGINE_BUILD_NAME}"
	COMPILE_FLAGS "${ENGINE_CL_FLAGS}"
)

target_link_libraries(client "${ENGINE_CL_LIBS}")

target_include_directories(client PRIVATE
	"${INC_DIR}"
	"${SDL2_INCLUDE_DIR}"
	"${JPEG_INCLUDE_DIR}"
	"${PNG_INCLUDE_DIR}"
	"${VORBIS_INCLUDE_DIRS}"
	"${CRYPTO_INCLUDE_DIR}"
)
