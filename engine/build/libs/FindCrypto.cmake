include(ExternalProject)

set(d0_blind_id_URL "https://gitlab.com/xonotic/d0_blind_id/-/archive/master/d0_blind_id-master.tar.gz")
set(d0_blind_id_HASH "SHA256=a195d1a34a341874a86f8abdb5b847ff2e692c0e0faf9d0e45f1cbc5ea351520")
set(d0_blind_id_INCLUDE_DIR "${DEP_PREFIX_DIR}/include")
set(d0_blind_id_LIBRARY "${DEP_PREFIX_DIR}/lib/${CMAKE_SHARED_MODULE_PREFIX}d0_blind_id${CMAKE_SHARED_LIBRARY_SUFFIX}")
set(d0_rijndael_LIBRARY "${DEP_PREFIX_DIR}/lib/${CMAKE_SHARED_MODULE_PREFIX}d0_rijndael${CMAKE_SHARED_LIBRARY_SUFFIX}")

ExternalProject_Add(d0_blind_id
	BUILD_IN_SOURCE 1
	URL "${d0_blind_id_URL}"
	URL_HASH "${d0_blind_id_HASH}"
	EXCLUDE_FROM_ALL TRUE
	CONFIGURE_COMMAND <SOURCE_DIR>/autogen.sh
	COMMAND ./configure --prefix=${DEP_PREFIX_DIR}
	BUILD_COMMAND "make"
)