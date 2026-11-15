# Shared helpers for rez build scripts. Sourced by rez/packages/*/build.sh.
# shellcheck shell=bash
#
# rez sets these for a custom build_command:
#   REZ_BUILD_SOURCE_PATH   the package dir (package.py lives here)
#   REZ_BUILD_PATH          scratch build dir
#   REZ_BUILD_INSTALL       1 when run with --install
#   REZ_BUILD_INSTALL_PATH  where to install
#   REZ_BUILD_THREAD_COUNT  parallel jobs
set -euo pipefail

: "${REZ_BUILD_SOURCE_PATH:?run this through rez-build}"
: "${REZ_BUILD_PATH:?}"
: "${REZ_BUILD_INSTALL_PATH:?}"
REZ_BUILD_INSTALL="${REZ_BUILD_INSTALL:-0}"
# Parallel jobs: one per core, but no more than one per 4 GB of RAM, because
# heavy C++ (OpenVDB instantiations, USD) peaks at 2.5-4 GB per compiler.
# Override: VFX_BUILD_JOBS.
mem_jobs=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 / 4 ))
(( mem_jobs >= 1 )) || mem_jobs=1
JOBS="${VFX_BUILD_JOBS:-$(( $(nproc) < mem_jobs ? $(nproc) : mem_jobs ))}"

RECIPES="$(cd "$REZ_BUILD_SOURCE_PATH/../.." && pwd)"   # rez/
CACHE="${VFX_SRC_CACHE:-$HOME/.cache/vfx-src}"
SUMS="$RECIPES/checksums.txt"
mkdir -p "$CACHE"

log() { printf '\e[1m[%s]\e[0m %s\n' "${REZ_BUILD_PROJECT_NAME:-build}" "$*"; }

# fetch NAME URL: download once into the cache, check it against
# rez/checksums.txt (pinned) or record its hash on first download, then
# extract into $REZ_BUILD_PATH/src. Prints the extracted source dir.
fetch() {
  local url="$2" file
  file="$CACHE/$1-$(basename "$2")"
  if [[ ! -f "$file" ]]; then
    log "downloading $url" >&2
    curl -fL --retry 3 -o "$file.part" "$url"
    mv "$file.part" "$file"
  fi
  local have want
  have="$(sha256sum "$file" | cut -d' ' -f1)"
  want="$(awk -v k="$(basename "$file")" '$2 == k {print $1}' "$SUMS" 2>/dev/null || true)"
  if [[ -n "$want" && "$want" != "$have" ]]; then
    echo "checksum mismatch for $file: expected $want, got $have" >&2
    exit 1
  elif [[ -z "$want" ]]; then
    log "new checksum (add to rez/checksums.txt): $have  $(basename "$file")" >&2
    echo "$have  $(basename "$file")" >> "$CACHE/new-checksums.txt"
  fi
  local dest="$REZ_BUILD_PATH/src"
  rm -rf "$dest" && mkdir -p "$dest"
  tar -xf "$file" -C "$dest" --strip-components=1
  echo "$dest"
}

# cmake_build SRC [cmake args...]: configure + build with Ninja, install
# when rez-build was given --install.
cmake_build() {
  local src="$1"; shift
  local bld="$REZ_BUILD_PATH/build"
  cmake -S "$src" -B "$bld" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$REZ_BUILD_INSTALL_PATH" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}" \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DCMAKE_INSTALL_RPATH="$REZ_BUILD_INSTALL_PATH/lib" \
    -DCMAKE_CXX_STANDARD=20 \
    "$@"
  cmake --build "$bld" -j "$JOBS"
  if [[ "$REZ_BUILD_INSTALL" == 1 ]]; then
    cmake --install "$bld"
  fi
}

# The Python everything builds against (from the rez python package).
py() { command -v python3; }
pyver() { python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")'; }
