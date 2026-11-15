#!/usr/bin/env bash
# Build tbb 2022.3.0. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch tbb https://github.com/uxlfoundation/oneTBB/archive/refs/tags/v2022.3.0.tar.gz)"
cmake_build "$src" -DTBB_TEST=OFF -DTBB_STRICT=OFF
