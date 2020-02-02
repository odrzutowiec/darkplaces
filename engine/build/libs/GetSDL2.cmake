include(ExternalProject)

set(SDL2_URL "https://www.libsdl.org/release/SDL2-2.0.10.tar.gz")
set(SDL2_HASH "SHA256=b4656c13a1f0d0023ae2f4a9cf08ec92fffb464e0f24238337784159b8b91d57")

ExternalProject_Add(SDL2
	URL ${SDL2_URL}
	URL_HASH ${SDL2_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)