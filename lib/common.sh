# Shared helpers for vfx-linux modules. Sourced, not executed.
# shellcheck shell=bash

: "${VFX_DRY_RUN:=0}"
: "${REPO_DIR:?REPO_DIR must be set}"

# Load user overrides (copy config.example.sh to config.sh).
# shellcheck source=/dev/null
[[ -f "$REPO_DIR/config.sh" ]] && source "$REPO_DIR/config.sh"
# shellcheck source=../config.example.sh
source "$REPO_DIR/config.example.sh"

if [[ -t 1 ]]; then
  C_B=$'\e[1m'; C_DIM=$'\e[2m'; C_Y=$'\e[33m'; C_R=$'\e[31m'; C_0=$'\e[0m'
else
  C_B=; C_DIM=; C_Y=; C_R=; C_0=
fi

section() { printf '\n%s== %s ==%s\n' "$C_B" "$*" "$C_0"; }
info()    { printf '   %s\n' "$*"; }
warn()    { printf '%s!! %s%s\n' "$C_Y" "$*" "$C_0" >&2; }
die()     { printf '%sxx %s%s\n' "$C_R" "$*" "$C_0" >&2; exit 1; }

# run CMD...: execute, or just print in dry-run mode.
run() {
  if [[ "$VFX_DRY_RUN" == 1 ]]; then
    printf '%s   [dry-run] %s%s\n' "$C_DIM" "$*" "$C_0"
  else
    "$@"
  fi
}

# Read a package list file: strips comments and blank lines.
read_pkgs() {
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$REPO_DIR/packages/$1.txt"
}

# Install packages from a list file, skipping ones already installed.
install_pkgs() {
  local list="$1" missing=() p
  while read -r p; do
    pacman -Qq "$p" &>/dev/null || missing+=("$p")
  done < <(read_pkgs "$list")
  if [[ ${#missing[@]} -eq 0 ]]; then
    info "packages/$list.txt: all installed"
  else
    info "packages/$list.txt: installing ${missing[*]}"
    run sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi
}

# Same, through the AUR helper, for packages not in the official repos.
install_aur() {
  local list="$1" missing=() p
  while read -r p; do
    pacman -Qq "$p" &>/dev/null || missing+=("$p")
  done < <(read_pkgs "$list")
  [[ ${#missing[@]} -eq 0 ]] && { info "packages/$list.txt: all installed"; return; }
  command -v paru >/dev/null || die "paru not found; run the 'base' module first"
  info "packages/$list.txt (AUR): installing ${missing[*]}"
  run paru -S --needed --noconfirm "${missing[@]}"
}

# Write CONTENT to a root-owned file only if it differs. Returns 0 if changed.
write_root_file() {
  local path="$1" content="$2"
  if [[ -f "$path" ]] && [[ "$(cat "$path")" == "$content" ]]; then
    info "unchanged: $path"
    return 1
  fi
  info "writing: $path"
  if [[ "$VFX_DRY_RUN" != 1 ]]; then
    sudo mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
  fi
  return 0
}

# Symlink a repo path (relative to the repo root) to an absolute destination.
# An existing non-link target is moved aside to *.vfx-backup first.
link_repo_path() {
  local src="$REPO_DIR/$1" dst="$2" show="${2/#$HOME/\~}"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    info "linked: $show"
    return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "backing up existing $show to $show.vfx-backup"
    run mv "$dst" "$dst.vfx-backup"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  info "linked: $show -> $1"
}

# Symlink something from dotfiles/ into $HOME.
link_dotfile() { link_repo_path "dotfiles/$1" "$HOME/$2"; }
