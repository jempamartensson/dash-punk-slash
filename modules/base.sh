# Core CLI tools and the paru AUR helper.
# shellcheck shell=bash

install_pkgs base

if command -v paru >/dev/null; then
  info "paru: installed"
else
  info "building paru from the AUR"
  tmp="$(mktemp -d)"
  run git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
  run bash -c "cd '$tmp/paru-bin' && makepkg -si --noconfirm"
  rm -rf "$tmp"
fi

# Weekly TRIM for the NVMe.
if systemctl is-enabled fstrim.timer &>/dev/null; then
  info "fstrim.timer: enabled"
else
  run sudo systemctl enable --now fstrim.timer
fi
