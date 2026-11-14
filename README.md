# vfx-linux

A post-install setup that turns a fresh Arch Linux install into a VFX
workstation. It's tuned for AMD Strix Halo (Radeon 8060S, gfx1151) with ROCm,
a terminal-first, IRIX-inspired Hyprland desktop, rez-managed VFX libraries
and a local AI assistant.

## Status

| Step | What | State |
|---|---|---|
| 1 | Base system: AMD GPU + ROCm, unified memory, Hyprland desktop | written, untested on hardware |
| 2 | rez + VFX Reference Platform libraries + themed usdview | planned |
| 3 | VFX apps (Houdini, Nuke, Maya, Blender, Katana, Resolve) | planned |
| 4 | Local LLM assistant (llama.cpp + agent) | planned |
| 5 | Multi-user, docs, ISO | later |

## Install

Start from a minimal Arch install with a user that has sudo and working
network (archinstall, "minimal" profile, is fine). Before you begin, set the
BIOS UMA/VRAM size to its **minimum**, because the driver maps GPU memory
dynamically (see `VFX_GPU_MEM_GIB`).

```sh
git clone <this repo> ~/vfx-linux
cd ~/vfx-linux
./install.sh --dry-run   # see what it would do
./install.sh             # do it
sudo reboot
vfx-gpu-check            # after login
```

Run a single part with `./install.sh gpu` or `./install.sh desktop`. Every
module can be re-run safely.

## Modules

- **preflight** checks for Arch, a 6.15+ kernel, the AMD GPU and visible RAM, then updates the system.
- **base** installs CLI tools, the `paru` AUR helper and the weekly TRIM timer.
- **gpu** installs Mesa/RADV, ROCm HIP + OpenCL and adds you to the `render`/`video` groups. It raises the GPU's share of system RAM (TTM/GTT limit) to `VFX_GPU_MEM_GIB` and installs `vfx-gpu-check`.
- **desktop** installs Hyprland, waybar, foot, fuzzel, mako and greetd with a text login. It symlinks `dotfiles/` into `~/.config`, backing up anything already there.

## Settings

Copy `config.example.sh` to `config.sh` and edit it. Your copy isn't
committed to git.

## Keys

| Key | Action |
|---|---|
| Super+Enter | terminal |
| Super+D | launcher |
| Super+Q | close window |
| Super+F / V | fullscreen / float |
| Super+arrows | focus (Shift: move) |
| Super+1..9 | workspace (Shift: send window) |
| Super+L | lock |
| Print | screenshot region to clipboard |

The keyboard layout is set in `dotfiles/hypr/hyprland.conf` (`kb_layout = us`).

## Known open questions

- Does Arch's packaged ROCm include gfx1151 kernels? `vfx-gpu-check` reports
  this. If it doesn't, step 2 will add a ROCm build that does.
- The Hyprland window-rule syntax changes between releases. Check
  `dotfiles/hypr/rules.conf` on first boot.
