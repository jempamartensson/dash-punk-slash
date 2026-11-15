#!/usr/bin/env bash
# Build openvdb 13.2.0. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch openvdb https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/v13.2.0.tar.gz)"
cmake_build "$src" -DOPENVDB_BUILD_UNITTESTS=OFF -DOPENVDB_BUILD_DOCS=OFF \
  -DOPENVDB_BUILD_BINARIES=ON -DOPENVDB_BUILD_VDB_PRINT=ON -DUSE_BLOSC=ON -DUSE_ZLIB=ON \
  -DUSE_IMATH_HALF=ON -DOPENVDB_BUILD_PYTHON_MODULE=OFF
