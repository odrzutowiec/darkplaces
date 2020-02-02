include(ExternalProject)

set(OGG_URL "http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.gz")
set(OGG_HASH "SHA256=fe5670640bd49e828d64d2879c31cb4dde9758681bb664f9bdbf159a01b0c76e")

ExternalProject_Add(ogg
	URL ${OGG_URL}
	URL_HASH ${OGG_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)
