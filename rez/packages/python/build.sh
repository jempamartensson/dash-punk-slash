#!/usr/bin/env bash
# Build python 3.13.18. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch python https://www.python.org/ftp/python/3.13.18/Python-3.13.18.tar.xz)"
cd "$REZ_BUILD_PATH" || exit 1
"$src/configure" --prefix="$REZ_BUILD_INSTALL_PATH" --enable-shared --with-ensurepip=install \
  LDFLAGS="-Wl,-rpath,$REZ_BUILD_INSTALL_PATH/lib"
make -j "$JOBS"
if [[ "$REZ_BUILD_INSTALL" == 1 ]]; then
  make install
  ln -sf python3 "$REZ_BUILD_INSTALL_PATH/bin/python"
  ln -sf pip3 "$REZ_BUILD_INSTALL_PATH/bin/pip"
fi
