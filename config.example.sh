# Defaults for vfx-linux. To override, copy to config.sh and edit there
# (config.sh is git-ignored and loaded first, so its values win).
# shellcheck shell=bash

# GPU memory the iGPU may map from system RAM, in GiB.
# Strix Halo shares RAM between CPU and GPU. Set the BIOS UMA/"VRAM" size
# to its minimum (512 MB) and let the driver map memory dynamically up to
# this limit instead. 108 on a 128 GB machine leaves ~20 GB for the OS.
: "${VFX_GPU_MEM_GIB:=108}"

# Login screen: greetd with tuigreet (text login, launches Hyprland).
: "${VFX_ENABLE_GREETER:=1}"

# Terminal used by keybindings and the launcher.
: "${VFX_TERMINAL:=foot}"

# Colour scheme applied on first install: slate, teal, granite or lavender.
# Re-running the installer keeps whatever you picked later with vfx-theme.
: "${VFX_SCHEME:=slate}"
