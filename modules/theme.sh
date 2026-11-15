# Colour schemes (vfx-theme), the dash-punk icon theme and VFX file types.
# shellcheck shell=bash

run sudo ln -sfn "$REPO_DIR/tools/vfx-theme" /usr/local/bin/vfx-theme
info "vfx-theme: /usr/local/bin/vfx-theme -> tools/vfx-theme"

# Icon theme
link_repo_path icons/dash-punk "$HOME/.local/share/icons/dash-punk"

# File types (.usd/.usda/.usdc/.usdz/.vdb)
link_repo_path packaging/mime/vfx-linux.xml "$HOME/.local/share/mime/packages/vfx-linux.xml"
if command -v update-mime-database >/dev/null; then
  run update-mime-database "$HOME/.local/share/mime"
else
  warn "update-mime-database not found; install shared-mime-info"
fi

# Apply a scheme. Keep the user's current choice if they've picked one.
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vfx-theme"
scheme="$VFX_SCHEME"
[[ -f "$cfg/current" ]] && scheme="$(<"$cfg/current")"
run "$REPO_DIR/tools/vfx-theme" set "$scheme"

# GTK apps read the generated settings (icon theme, dark preference, font).
for v in gtk-3.0 gtk-4.0; do
  dst="$HOME/.config/$v/settings.ini"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$cfg/gtk-settings.ini" ]]; then
    info "linked: ~/.config/$v/settings.ini"
    continue
  fi
  [[ -e "$dst" && ! -L "$dst" ]] && { warn "backing up ~/.config/$v/settings.ini"; run mv "$dst" "$dst.vfx-backup"; }
  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$cfg/gtk-settings.ini" "$dst"
  info "linked: ~/.config/$v/settings.ini -> vfx-theme"
done
