# Check CMake's version and update if necessary, mainly so --parallel works.
# This should only be called from build.sh using the -P option!

include("utils.cmake")

if(NOT (CMAKE_MAJOR_VERSION GREATER 2 AND CMAKE_MINOR_VERSION GREATER 11))
	pstatus("Your cmake is out of date and must be updated.")
	# TODO
endif