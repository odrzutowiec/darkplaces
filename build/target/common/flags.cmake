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

if(UNIX)
	set(ENGINE_CFLAGS "\
		-Wall \
		-Wold-style-definition \
		-Wstrict-prototypes \
		-Wdeclaration-after-statement \
		-Wmissing-prototypes \
		-Wsign-compare \
		-Wno-pointer-sign \
		-Wno-unknown-pragmas \
		-Wno-format-zero-length \
		-Wno-strict-aliasing \
		-Dstrnicmp=strncasecmp \
		-Dstricmp=strcasecmp"
	)
elseif(MSVC)
	#TODO
	set(ENGINE_CFLAGS
		"/Wall"
	)
endif()

set(ENGINE_DFLAGS "${ENGINE_DFLAGS} -MMD")

if(ENGINE_VERSION)
	set(ENGINE_DFLAGS "${ENGINE_DFLAGS} -DSVNREVISION='${ENGINE_VERSION}'")
endif()

if(CMAKE_BUILD_TYPE)
	set(ENGINE_DFLAGS "${ENGINE_DFLAGS} -DBUILDTYPE='${CMAKE_BUILD_TYPE}'")
endif()

if(ENGINE_NO_BUILD_TIMESTAMPS)
	set(ENGINE_DFLAGS "${ENGINE_DFLAGS} -DNO_BUILD_TIMESTAMPS")
endif()

if(UNIX)
	set(ENGINE_LIBS "-lm")
	if(WIN_GNU)
		set(ENGINE_LIBS "${ENGINE_LIBS} -lwinmm -limm32 -lversion -lwsock32 -lws2_32")
	else()
		set(ENGINE_LIBS "${ENGINE_LIBS} -ldl -lz")
		if(NOT APPLE)
			set(ENGINE_LIBS "${ENGINE_LIBS} -lrt")
			if(SUN_OS)
				set(ENGINE_LIBS "${ENGINE_LIBS} -lsocket -lnsl")
			endif()
		else()
			set(ENGINE_LIBS "${ENGINE_LIBS} -framework IOKit -framework CoreFoundation")
		endif()
	endif()
endif()

set(ENGINE_FLAGS "${ENGINE_CFLAGS} ${ENGINE_DFLAGS}")