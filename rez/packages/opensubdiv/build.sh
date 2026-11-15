#!/usr/bin/env bash
# Build opensubdiv 3.7.0. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch opensubdiv https://github.com/PixarAnimationStudios/OpenSubdiv/archive/refs/tags/v3_7_0.tar.gz)"
cmake_build "$src" -DNO_EXAMPLES=ON -DNO_TUTORIALS=ON -DNO_REGRESSION=ON -DNO_DOC=ON \
  -DNO_CUDA=ON -DNO_OPENCL=ON -DNO_PTEX=ON -DNO_GLFW=ON -DNO_TESTS=ON
