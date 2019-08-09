if(BUILD_CONFIG STREQUAL "")
	set(BUILD_CONFIG "default")
	message(WARNING "No BUILD_CONFIG specified. Using 'default'. Specify -DBUILD_CONFIG to the name of the directory containing your build config if you wish to use a different one.")
endif()

set(PROJ_DIR "${HP_DIR}/../game/${BUILD_CONFIG}")

set(CMAKE_BUILD_DIRECTORY "${PROJ_DIR}")

include("${PROJ_DIR}/config.cmake")
