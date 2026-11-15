#!/usr/bin/env bash
# Build imath 3.2.3. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch imath https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/v3.2.3.tar.gz)"
cmake_build "$src" -DBUILD_TESTING=OFF -DPYTHON=OFF
