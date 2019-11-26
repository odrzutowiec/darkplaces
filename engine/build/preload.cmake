if(PROJ_DIR STREQUAL "")
	message(FATAL "No PROJ_DIR specified. Specify -DPROJ_DIR to the the directory containing your build config. If you got here from the build script, it's broken again.")
endif()

include("${PROJ_DIR}/config.cmake")
