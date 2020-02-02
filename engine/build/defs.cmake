# Common variables. Should be the first thing included in both
# CMakeLists and cmversion.cmake

set(HP_DIR "${CMAKE_SOURCE_DIR}")			# Shorthand because I'm lazy
set(ROOT_DIR "${HP_DIR}/..")				# Repository root (hopefully!)
set(DEP_PREFIX_DIR "${ROOT_DIR}/.prefix")	# Install prefix for dependencies
set(SRC_DIR "${HP_DIR}/src")				# Darkplaces source
set(INC_DIR "${HP_DIR}/inc")				# Darkplaces include
set(CM_DIR "${HP_DIR}/build")				# Build system scripts
set(UTIL_DIR "${CM_DIR}/utility")			# Utility libraries for the build system
set(LIB_DIR "${CM_DIR}/libs")				# Find dependency libraries for the engine
set(TGT_DIR "${CM_DIR}/target")				# Scripts to build the engine itself
set(TOOLCHAIN_DIR "${CM_DIR}/toolchain")	# Toolchain files for cross-compiling
set(PROJ_DIR "${ROOT_DIR}/game")			# Default location for game projects
set(PROJ_DEFAULT_DIR "${PROJ_DIR}/default")	# Location of the default template
set(TMP_DIR "${ROOT_DIR}/.temp")			# General purpose temp directory