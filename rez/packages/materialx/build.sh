#!/usr/bin/env bash
# Build materialx 1.39.5. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch materialx https://github.com/AcademySoftwareFoundation/MaterialX/archive/refs/tags/v1.39.5.tar.gz)"
cmake_build "$src" -DMATERIALX_BUILD_PYTHON=ON -DMATERIALX_BUILD_TESTS=OFF \
  -DMATERIALX_BUILD_VIEWER=OFF -DMATERIALX_BUILD_GRAPH_EDITOR=OFF -DMATERIALX_BUILD_SHARED_LIBS=ON \
  -DMATERIALX_INSTALL_PYTHON=OFF -DMATERIALX_PYTHON_EXECUTABLE="$(py)"
