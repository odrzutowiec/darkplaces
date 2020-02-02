include(ExternalProject)

set(VORBIS_URL "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.6.tar.gz")
set(VORBIS_HASH "SHA256=6ed40e0241089a42c48604dc00e362beee00036af2d8b3f46338031c9e0351cb")

ExternalProject_Add(vorbis
	URL ${VORBIS_URL}
	URL_HASH ${VORBIS_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)
