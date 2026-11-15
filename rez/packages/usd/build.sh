#!/usr/bin/env bash
# Build usd 26.11.1. Run through rez-build (see tools/vfx-rez-build).
source "$REZ_BUILD_SOURCE_PATH/../../lib/build-common.sh"
src="$(fetch usd https://github.com/PixarAnimationStudios/OpenUSD/archive/refs/tags/v26.11.1.tar.gz)"

# Let usdview take its stylesheet from VFX_USDVIEW_QSS (our scheme) when
# that file exists, falling back to the stock one.
ctl="$src/pxr/usdImaging/usdviewq/appController.py"
python3 - "$ctl" <<'PY'
import sys, re
p = sys.argv[1]; s = open(p).read()
old = "with open(os.path.join(resourceDir, 'usdviewstyle.qss'), 'r') as sheet:"
new = ("_qss = os.environ.get('VFX_USDVIEW_QSS', '')\n"
       "        if not os.path.isfile(_qss):\n"
       "            _qss = os.path.join(resourceDir, 'usdviewstyle.qss')\n"
       "        with open(_qss, 'r') as sheet:")
if old not in s:
    sys.exit("usdview stylesheet hook not found; update the patch for this USD version")
open(p, "w").write(s.replace(old, new, 1))
PY

cmake_build "$src" \
  -DPXR_BUILD_TESTS=OFF -DPXR_BUILD_EXAMPLES=OFF -DPXR_BUILD_TUTORIALS=OFF -DPXR_BUILD_DOCUMENTATION=OFF \
  -DPXR_ENABLE_PYTHON_SUPPORT=ON -DPython3_EXECUTABLE="$(py)" \
  -DPXR_BUILD_IMAGING=ON -DPXR_BUILD_USD_IMAGING=ON -DPXR_BUILD_USDVIEW=ON \
  -DPXR_ENABLE_GL_SUPPORT=ON -DPXR_ENABLE_VULKAN_SUPPORT=OFF \
  -DPXR_ENABLE_OPENVDB_SUPPORT=ON -DPXR_ENABLE_PTEX_SUPPORT=ON -DPXR_ENABLE_MATERIALX_SUPPORT=ON \
  -DPXR_BUILD_OPENIMAGEIO_PLUGIN=ON -DPXR_BUILD_OPENCOLORIO_PLUGIN=ON \
  -DPXR_BUILD_ALEMBIC_PLUGIN=ON -DPXR_BUILD_DRACO_PLUGIN=OFF -DPXR_BUILD_EMBREE_PLUGIN=OFF \
  -DPXR_BUILD_PRMAN_PLUGIN=OFF
