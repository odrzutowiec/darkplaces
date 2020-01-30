include(ExternalProject)

set(d0_blind_id_PREFIX "${TMP_DIR}/d0_blind_id")
set(d0_blind_id_INCLUDE_DIR "${d0_blind_id_PREFIX}/src")
set(d0_blind_id_LIBRARY "${d0_blind_id_INCLUDE_DIR}/d0_blind_id/.libs/${CMAKE_SHARED_MODULE_PREFIX}d0_blind_id${CMAKE_SHARED_LIBRARY_SUFFIX}")
set(d0_rijndael_LIBRARY "${d0_blind_id_INCLUDE_DIR}/d0_blind_id/.libs/${CMAKE_SHARED_MODULE_PREFIX}d0_rijndael${CMAKE_SHARED_LIBRARY_SUFFIX}")

ExternalProject_Add(d0_blind_id
	BUILD_IN_SOURCE 1
	URL "https://gitlab.com/xonotic/d0_blind_id/-/archive/master/d0_blind_id-master.tar.gz"
	URL_HASH SHA256=a195d1a34a341874a86f8abdb5b847ff2e692c0e0faf9d0e45f1cbc5ea351520
	PREFIX "${d0_blind_id_PREFIX}"
	STEP_TARGETS build
	EXCLUDE_FROM_ALL TRUE
	CONFIGURE_COMMAND <SOURCE_DIR>/autogen.sh COMMAND ./configure
	INSTALL_COMMAND ""
	BUILD_COMMAND "make"
)