include(ExternalProject)

set(ZLIB_URL "https://www.zlib.net/zlib-1.2.11.tar.gz")
set(ZLIB_HASH "SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")

ExternalProject_Add(zlib
	URL ${ZLIB_URL}
	URL_HASH ${ZLIB_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)
