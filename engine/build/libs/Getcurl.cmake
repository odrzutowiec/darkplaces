include(ExternalProject)

set(CURL_URL "https://curl.haxx.se/download/curl-7.68.0.tar.xz")
set(CURL_HASH "SHA256=b724240722276a27f6e770b952121a3afd097129d8c9fe18e6272dc34192035a")

ExternalProject_Add(curl
	URL ${CURL_URL}
	URL_HASH ${CURL_HASH}
	EXCLUDE_FROM_ALL TRUE
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX='${DEP_PREFIX_DIR}'
)