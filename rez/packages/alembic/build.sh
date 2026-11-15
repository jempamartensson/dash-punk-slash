#!/usr/bin/env bash
# Build alembic 1.8.12. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch alembic https://github.com/alembic/alembic/archive/refs/tags/1.8.12.tar.gz)"
cmake_build "$src" -DUSE_TESTS=OFF -DUSE_BINARIES=ON -DUSE_HDF5=OFF -DUSE_PYALEMBIC=OFF
