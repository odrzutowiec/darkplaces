# General purpose things

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

macro(pstatus text)
	message(STATUS "${text}")
endmacro()

macro(pfatal text)
	message(FATAL_ERROR "${text}")
endmacro()