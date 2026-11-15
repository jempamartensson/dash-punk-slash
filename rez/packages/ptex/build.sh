#!/usr/bin/env bash
# Build ptex 2.4.3. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch ptex https://github.com/wdas/ptex/archive/refs/tags/v2.4.3.tar.gz)"
# Ptex reads its version from git; give it one for a tarball build.
echo "2.4.3" > "$src/version"
cmake_build "$src" -DPTEX_BUILD_STATIC_LIBS=OFF -DPTEX_BUILD_DOCS=OFF
