# AMD Strix Halo: Mesa, ROCm, and unified-memory limits.
# shellcheck shell=bash

install_pkgs gpu

# Device access for ROCm/OpenCL.
for g in render video; do
  if id -nG "$USER" | tr ' ' '\n' | grep -qx "$g"; then
    info "group $g: already a member"
  else
    run sudo usermod -aG "$g" "$USER"
    info "group $g: added (takes effect after re-login)"
  fi
done

# Let the GPU map up to VFX_GPU_MEM_GIB of system RAM (GTT) instead of the
# default ~half. 1 GiB = 262144 pages of 4 KiB.
pages=$(( VFX_GPU_MEM_GIB * 262144 ))
ttm_conf="# vfx-linux: allow the iGPU to map up to ${VFX_GPU_MEM_GIB} GiB of system RAM
options ttm pages_limit=${pages} page_pool_size=${pages}"
if write_root_file /etc/modprobe.d/vfx-ttm.conf "$ttm_conf"; then
  info "rebuilding initramfs so the limit applies at boot"
  run sudo mkinitcpio -P
fi

run sudo install -Dm755 "$REPO_DIR/bin/vfx-gpu-check" /usr/local/bin/vfx-gpu-check
