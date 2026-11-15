#!/usr/bin/env bash
# Build openexr 3.4.18. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch openexr https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v3.4.18.tar.gz)"
cmake_build "$src" -DBUILD_TESTING=OFF -DOPENEXR_BUILD_EXAMPLES=OFF -DOPENEXR_BUILD_DOCS=OFF
