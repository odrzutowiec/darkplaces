# Callback build.sh to cache user-specified options.
function(hp_build_callback)
	if(NOT from_script EQUAL 1)
		if(UNIX)
			execute_process(
				WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/..
				COMMAND bash ./build.sh --auto --from-cmake --cc=cc --cxx=c++ --build-dir=${CMAKE_BINARY_DIR} --generator=${CMAKE_GENERATOR} --threads=1 --config-dir=${option_project_dir} ${option_project}
				RESULT_VARIABLE status
			)
			if(${status} GREATER 0)
				pfatal("The build script failed. CMake cannot continue.")
			endif()
			include("${CMAKE_SOURCE_DIR}/../.temp.cmake")
		else()
			message("The build script requires a Unix environment. I'll make this work on standard Windows later. For now, I hope you know what you're doing.")
		endif()
	endif()

	if("${GAME_PROJECT_DIR}" STREQUAL "")
		pfatal("GAME_PROJECT_DIR is undefined. If you got here from the build script or used CMake directly, one or both of them are broken again.")
	endif()
endfunction()