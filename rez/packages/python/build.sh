#!/usr/bin/env bash
# Build python 3.13.18. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"

# Arch ships OpenSSL 4, which removed APIs Python 3.13's ssl module still
# uses (TLSv1_method). Bundle OpenSSL 3.5 LTS inside this package instead.
ssl_src="$(fetch openssl https://github.com/openssl/openssl/releases/download/openssl-3.5.9/openssl-3.5.9.tar.gz)"
ssl_prefix="$REZ_BUILD_INSTALL_PATH/openssl"
[[ "$REZ_BUILD_INSTALL" == 1 ]] || ssl_prefix="$REZ_BUILD_PATH/openssl-prefix"
mv "$ssl_src" "$REZ_BUILD_PATH/openssl-src"
( cd "$REZ_BUILD_PATH/openssl-src" || exit 1
  ./Configure --prefix="$ssl_prefix" --openssldir="$ssl_prefix/ssl" --libdir=lib shared no-tests \
    "-Wl,-rpath,$ssl_prefix/lib"
  make -j "$JOBS"
  make install_sw )
# Use the system's CA certificates.
mkdir -p "$ssl_prefix/ssl"
ln -sfn /etc/ssl/certs "$ssl_prefix/ssl/certs"
ln -sfn /etc/ssl/cert.pem "$ssl_prefix/ssl/cert.pem"

src="$(fetch python https://www.python.org/ftp/python/3.13.18/Python-3.13.18.tar.xz)"
mkdir -p "$REZ_BUILD_PATH/py" && cd "$REZ_BUILD_PATH/py" || exit 1
"$src/configure" --prefix="$REZ_BUILD_INSTALL_PATH" --enable-shared --with-ensurepip=install \
  --with-openssl="$ssl_prefix" --with-openssl-rpath=auto \
  LDFLAGS="-Wl,-rpath,$REZ_BUILD_INSTALL_PATH/lib"
make -j "$JOBS"
if [[ "$REZ_BUILD_INSTALL" == 1 ]]; then
  make install
  ln -sf python3 "$REZ_BUILD_INSTALL_PATH/bin/python"
  ln -sf pip3 "$REZ_BUILD_INSTALL_PATH/bin/pip"
  "$REZ_BUILD_INSTALL_PATH/bin/python3" -c "import ssl; print('ssl ok:', ssl.OPENSSL_VERSION)"
fi
