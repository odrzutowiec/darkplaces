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


### BUILD - CLIENT ###

if(ENGINE_CONFIG_MENU)
	set(ENGINE_CL_FLAGS "${ENGINE_CL_FLAGS} -DCONFIG_MENU")
endif()

if(ENGINE_CONFIG_CD)
	set(ENGINE_CL_FLAGS "${ENGINE_CL_FLAGS} -DCONFIG_CD")
endif()

set(ENGINE_CL_FLAGS "${ENGINE_CL_FLAGS} -DLINK_TO_LIBJPEG -DLINK_TO_LIBVORBIS")

# Dependencies
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${MODULE_DIR}/libs)

find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(CURL REQUIRED)
find_package(SDL2 REQUIRED)
find_package(Vorbis REQUIRED)

# Targets
add_executable(${ENGINE_EXE_NAME}
			   "${OBJ_CL}"
			   "${OBJ_MENU}"
			   "${OBJ_SND_COMMON}"
			   "${OBJ_CD_COMMON}"
			   "${OBJ_VIDEO_CAPTURE}"
			   "${OBJ_COMMON}"
)
set_target_properties(${ENGINE_EXE_NAME} PROPERTIES LINKER_LANGUAGE C
								         COMPILE_FLAGS "${ENGINE_PLATFLAGS} ${ENGINE_FLAGS} ${ENGINE_CL_FLAGS}")
target_link_libraries(${ENGINE_EXE_NAME} ${SDL2_LIBRARY} ${JPEG_LIBRARY} ${PNG_LIBRARY} ${CURL_LIBRARY} ${VORBIS_LIBRARIES} ${ENGINE_PLATLIBS})

target_include_directories(${ENGINE_EXE_NAME} PRIVATE 
	${HP_DIR}/inc
	${SDL2_INCLUDE_DIR}
	${JPEG_INCLUDE_DIR}
	${PNG_INCLUDE_DIR}
	${VORBIS_INCLUDE_DIRS}
)
