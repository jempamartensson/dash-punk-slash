#!/usr/bin/env bash
# Build oiio 3.1.19.0. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch oiio https://github.com/AcademySoftwareFoundation/OpenImageIO/archive/refs/tags/v3.1.19.0.tar.gz)"
# Only pybind11 is built by OIIO itself (everything else comes from rez or
# packages/rez.txt), so an unexpected missing dep fails loudly instead of
# being git-cloned unpinned. UltraHDR JPEG is off: not needed for VFX.
cmake_build "$src" -DOpenImageIO_BUILD_MISSING_DEPS=pybind11 -DUSE_LIBUHDR=OFF \
  -DOIIO_BUILD_TESTS=OFF \
  -DBUILD_DOCS=OFF -DINSTALL_DOCS=OFF -DUSE_PYTHON=ON -DUSE_QT=OFF \
  -DPython_EXECUTABLE="$(py)" -DPYTHON_VERSION="$(pyver)"
