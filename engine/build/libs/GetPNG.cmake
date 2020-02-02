include(ExternalProject)

set(PNG_URL "https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/libpng-1.6.37.tar.xz/download")
set(PNG_HASH "SHA256=505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca")

ExternalProject_Add(PNG
	URL ${PNG_URL}
	URL_HASH ${PNG_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)
