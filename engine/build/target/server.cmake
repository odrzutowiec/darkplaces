#   ----------------------------------------------------------------------------
#	COPYRIGHT (C) 2018 David Knapp
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

### BUILD - SERVER ###

# Targets
add_executable(${ENGINE_EXE_NAME}-sv
               "${OBJ_SV}"
			   "${OBJ_COMMON}"
			   "${OBJ_VIDEO_CAPTURE}"
)

set_target_properties(${ENGINE_EXE_NAME}-sv PROPERTIES LINKER_LANGUAGE C
											COMPILE_FLAGS "${ENGINE_PLATFLAGS} ${ENGINE_FLAGS} ${ENGINE_SV_FLAGS}")
target_link_libraries(${ENGINE_EXE_NAME}-sv ${ENGINE_PLATLIBS})

target_include_directories(${ENGINE_EXE_NAME}-sv PRIVATE "${HP_DIR}/inc")
