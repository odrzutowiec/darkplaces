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

### BUILD - SERVER ###

# Targets
add_executable(server)

target_sources(server PRIVATE
	"${OBJ_SV}"
	"${OBJ_COMMON}"
	"${OBJ_VIDEO_CAPTURE}"
)

if(WIN32)
	target_sources(server PRIVATE ${ENGINE_BUILD_WINRC})
endif()

#add_dependencies(server d0_blind_id)

set_target_properties(server PROPERTIES
	OUTPUT_NAME ${ENGINE_BUILD_NAME}-dedicated
	COMPILE_FLAGS "${ENGINE_FLAGS}"
)

target_link_libraries(server ${ENGINE_LIBS})

target_include_directories(server PRIVATE "${INC_DIR}")
