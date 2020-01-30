function(hp_build_check_config)
	if(ENGINE_EXE_NAME STREQUAL "") # Cannot be empty
        pfatal("You must give the executable a name.")
    endif()

    if(ENGINE_EXE_NAME MATCHES "[* *]") # Cannot contain spaces.
        pfatal("The executable name must not contain spaces.")
	endif()

	if(NOT ENGINE_BUILD_CLIENT AND NOT ENGINE_BUILD_SERVER)
		pfatal("You must build at least one target.")
	endif()

endfunction()

function(hp_build_parse_config)
	if(GAME_PROJECT)
		if(NOT GAME_PROJECT_DIR)
			pfatal("You must provide a valid GAME_PROJECT_DIR containing a config.cmake")
		endif()
		include(${GAME_PROJECT_DIR}/config.cmake)
	endif()
endfunction()