#!/usr/bin/env bash
# Build ocio 2.5.2. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"

# minizip-ng first, as a static lib against plain zlib. Left to itself,
# OCIO's bundled copy finds Arch's zlib-ng (native zng_* API) for the
# headers but links -lz, so the OCIO link fails on zng_inflateInit2 etc.
deps="$REZ_BUILD_PATH/deps"
mz="$(fetch minizip-ng https://github.com/zlib-ng/minizip-ng/archive/refs/tags/4.0.10.tar.gz)"
rm -rf "$REZ_BUILD_PATH/minizip-src" && mv "$mz" "$REZ_BUILD_PATH/minizip-src"
cmake -S "$REZ_BUILD_PATH/minizip-src" -B "$REZ_BUILD_PATH/minizip-build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$deps" -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_DISABLE_FIND_PACKAGE_ZLIBNG=ON -DMZ_ZLIB=ON \
  -DMZ_OPENSSL=OFF -DMZ_LIBBSD=OFF -DMZ_BUILD_TESTS=OFF -DMZ_COMPAT=OFF \
  -DMZ_BZIP2=OFF -DMZ_LZMA=OFF -DMZ_LIBCOMP=OFF -DMZ_ZSTD=OFF -DMZ_PKCRYPT=OFF \
  -DMZ_WZAES=OFF -DMZ_SIGNING=OFF -DMZ_ICONV=OFF \
  -DMZ_FETCH_LIBS=OFF -DMZ_FORCE_FETCH_LIBS=OFF
cmake --build "$REZ_BUILD_PATH/minizip-build" -j "$JOBS"
cmake --install "$REZ_BUILD_PATH/minizip-build"
export CMAKE_PREFIX_PATH="$deps${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"

src="$(fetch ocio https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/v2.5.2.tar.gz)"
# Other small deps (yaml-cpp, pystring, pybind11, ...) are fetched by OCIO's
# own build when the system doesn't have them.
cmake_build "$src" -DOCIO_INSTALL_EXT_PACKAGES=MISSING -DOCIO_BUILD_PYTHON=ON \
  -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_GPU_TESTS=OFF -DOCIO_BUILD_DOCS=OFF \
  -DOCIO_BUILD_APPS=ON -DPython_EXECUTABLE="$(py)" \
  -Dminizip-ng_ROOT="$deps" -DCMAKE_DISABLE_FIND_PACKAGE_ZLIBNG=ON
