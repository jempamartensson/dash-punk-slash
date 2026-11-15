#!/usr/bin/env bash
# Build ocio 2.5.2. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch ocio https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/v2.5.2.tar.gz)"
# Small deps (yaml-cpp, pystring, minizip-ng, pybind11, ...) are fetched by
# OCIO's own build when the system doesn't have them.
cmake_build "$src" -DOCIO_INSTALL_EXT_PACKAGES=MISSING -DOCIO_BUILD_PYTHON=ON \
  -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_GPU_TESTS=OFF -DOCIO_BUILD_DOCS=OFF \
  -DOCIO_BUILD_APPS=ON -DPython_EXECUTABLE="$(py)"
