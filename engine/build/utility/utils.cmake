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

function(hp_downloadfile url save hashtype _hash)
	pstatus("Downloading '${save}' from '${url}'...")

	if(${_hash} AND ${hashtype})
		set(hash_args "EXPECTED_HASH ${hashtype}=${_hash}")
	endif()

	file(DOWNLOAD ${url} "${save}"
		SHOW_PROGRESS
		TIMEOUT 60
		${hash_args}
	)

	file(${hashtype} "${save}" hash_compare)

	if(NOT ${hash_compare} STREQUAL ${_hash})
		pfatal("The ${hashtype} hash for ${_hashtype} did not match what was expected.")
	endif()
endfunction()

function(hp_extract archive outdir)
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf "${archive}"
		WORKING_DIRECTORY ${outdir}
		RESULT_VARIABLE estatus
	)
	if(${estatus})
		pfatal("Failed to extract ${archive}")
	endif()
endfunction()