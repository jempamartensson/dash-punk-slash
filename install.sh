#!/usr/bin/env bash
# vfx-linux post-install entry point.
#
# Turns a fresh Arch Linux install into the vfx-linux workstation.
# Safe to re-run: every module checks state before changing anything.
#
# Usage:
#   ./install.sh                 run all modules
#   ./install.sh desktop theme   run only the named modules
#   ./install.sh --dry-run       print what would happen, change nothing
#   ./install.sh --list          list modules
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"

MODULES=(preflight base gpu desktop theme)

selected=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) export VFX_DRY_RUN=1 ;;
    --list) printf '%s\n' "${MODULES[@]}"; exit 0 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    -*) die "unknown option: $arg" ;;
    *) selected+=("$arg") ;;
  esac
done
[[ ${#selected[@]} -eq 0 ]] && selected=("${MODULES[@]}")

# preflight always runs first, whatever was selected.
if [[ " ${selected[*]} " != *" preflight "* ]]; then
  selected=(preflight "${selected[@]}")
fi

for m in "${selected[@]}"; do
  file="$REPO_DIR/modules/$m.sh"
  [[ -f "$file" ]] || die "no such module: $m (see --list)"
  section "module: $m"
  # shellcheck source=/dev/null
  source "$file"
done

section "done"
info "Reboot to pick up kernel parameters and the new login screen."
info "After reboot run: vfx-gpu-check"
