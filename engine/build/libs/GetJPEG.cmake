include(ExternalProject)

set(JPEG_URL "http://ijg.org/files/jpegsrc.v9d.tar.gz")
set(JPEG_HASH "SHA256=99cb50e48a4556bc571dadd27931955ff458aae32f68c4d9c39d624693f69c32")

ExternalProject_Add(JPEG
	BUILD_IN_SOURCE 1
	URL ${JPEG_URL}
	URL_HASH ${JPEG_HASH}
	EXCLUDE_FROM_ALL TRUE
	CONFIGURE_COMMAND ./configure --prefix=${DEP_PREFIX_DIR}
	BUILD_COMMAND "make"
)