# Hyprland desktop with the IRIX-inspired theme, and a text login.
# shellcheck shell=bash

install_pkgs desktop

link_dotfile hypr        .config/hypr
link_dotfile waybar      .config/waybar
link_dotfile foot        .config/foot

if [[ "$VFX_ENABLE_GREETER" == 1 ]]; then
  # Newer Hyprland ships a start-hyprland wrapper; fall back to the binary.
  hypr_cmd=Hyprland
  command -v start-hyprland >/dev/null && hypr_cmd=start-hyprland
  greetd_conf="[terminal]
vt = 1

[default_session]
command = \"tuigreet --time --remember --asterisks --greeting 'vfx-linux' --cmd ${hypr_cmd}\"
user = \"greeter\""
  write_root_file /etc/greetd/config.toml "$greetd_conf" || true
  if systemctl is-enabled greetd &>/dev/null; then
    info "greetd: enabled"
  else
    # Another display manager would fight greetd for the VT.
    for dm in gdm sddm lightdm ly; do
      if systemctl is-enabled "$dm" &>/dev/null; then
        warn "disabling $dm in favour of greetd"
        run sudo systemctl disable "$dm"
      fi
    done
    run sudo systemctl enable greetd
  fi
fi
