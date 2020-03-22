include(${TGT_DIR}/common/list.cmake)
include(${TGT_DIR}/common/flags.cmake)

# Build a version string for the engine.
function(hp_build_get_version)
	set(ENV{TZ} "UTC")

	execute_process(
		COMMAND git rev-parse --short HEAD
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE revision
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	execute_process(
		COMMAND "git show -s --format=%ad --date='format-local:%a %b %d %Y %H:%I:%S UTC'"
		OUTPUT_VARIABLE timestamp
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	set(HP_REVISION "${timestamp} - ${revision}")
endfunction()

function(hp_build_game)
	if(GAME_BUILD_EXTERNAL_PROJECT)
		include(ExternalProject)
		ExternalProject_Add(${GAME_BUILD_EXTERNAL_PROJECT})
	endif()
endfunction()

function(hp_build)
	hp_build_get_version()

	if(ENGINE_BUILD_CLIENT)
		include(${TGT_DIR}/client/client.cmake)
	endif()

	if(ENGINE_BUILD_SERVER)
		include(${TGT_DIR}/server/server.cmake)
	endif()

	hp_build_game()
endfunction()