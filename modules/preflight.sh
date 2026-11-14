# Checks the machine before anything is changed.
# shellcheck shell=bash

[[ -f /etc/arch-release ]] || die "this script targets Arch Linux"
[[ $EUID -ne 0 ]] || die "run as your normal user, not root (sudo is used where needed)"
sudo -v || die "sudo is required"

kver="$(uname -r)"
info "kernel: $kver"
kmaj="${kver%%.*}"; kmin="${kver#*.}"; kmin="${kmin%%.*}"
if (( kmaj < 6 || (kmaj == 6 && kmin < 15) )); then
  warn "kernel $kver is older than 6.15; Strix Halo support is much better on 6.15+. Update with: sudo pacman -Syu"
fi

gpu="$(lspci -nn 2>/dev/null | grep -Ei 'vga|display' | grep -i '1002:' || true)"
if [[ -n "$gpu" ]]; then
  info "AMD GPU: ${gpu#*: }"
else
  warn "no AMD GPU found by lspci; the gpu module is tuned for Strix Halo"
fi

mem_gib=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
info "RAM visible to the OS: ${mem_gib} GiB"
if (( mem_gib < 64 )); then
  warn "under 64 GiB visible. If you have 128 GB, the BIOS UMA/VRAM carve-out is probably large; set it to the minimum (512 MB)"
fi

info "updating package databases and system"
run sudo pacman -Syu --noconfirm
