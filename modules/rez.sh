# rez package manager and the build setup for the VFX library stack.
# The libraries themselves are built afterwards with: vfx-rez-build
# shellcheck shell=bash

install_pkgs rez

REZ_VERSION=3.5.0
if [[ -x /opt/rez/bin/rez/rez ]]; then
  info "rez: $(/opt/rez/bin/rez/rez --version 2>/dev/null || echo installed) in /opt/rez"
else
  info "installing rez $REZ_VERSION into /opt/rez"
  tmp="$(mktemp -d)"
  run curl -fL -o "$tmp/rez.tar.gz" "https://github.com/AcademySoftwareFoundation/rez/archive/refs/tags/$REZ_VERSION.tar.gz"
  run tar -xf "$tmp/rez.tar.gz" -C "$tmp"
  run sudo python3 "$tmp/rez-$REZ_VERSION/install.py" /opt/rez
  rm -rf "$tmp"
fi

# rez commands on PATH for every shell (foot starts non-login shells).
for tool in /opt/rez/bin/rez/*; do
  [[ -x "$tool" ]] || continue
  dst="/usr/local/bin/$(basename "$tool")"
  [[ -L "$dst" && "$(readlink "$dst")" == "$tool" ]] || run sudo ln -sfn "$tool" "$dst"
done
info "rez tools linked into /usr/local/bin"

# Per-user rez config: package paths (~/packages, /opt/vfx/rez/packages).
link_repo_path rez/config/rezconfig.py "$HOME/.rezconfig.py"

# Shared package repository, writable by this user.
if [[ ! -d "$VFX_REZ_PACKAGES" ]]; then
  run sudo mkdir -p "$VFX_REZ_PACKAGES"
  run sudo chown "$USER:" "$VFX_REZ_PACKAGES"
fi
mkdir -p "$HOME/packages"
info "packages: $VFX_REZ_PACKAGES (shared), ~/packages (local)"

run sudo ln -sfn "$REPO_DIR/tools/vfx-rez-build" /usr/local/bin/vfx-rez-build
info "next: run 'vfx-rez-build' to build the VFX libraries (about an hour)"
