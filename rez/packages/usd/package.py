# -*- coding: utf-8 -*-
name = "usd"
version = "26.11.1"
description = "OpenUSD with Hydra Storm and a themed usdview"
authors = ["vfx-linux"]

requires = [
    "python-3.13",
    "tbb-2022",
    "opensubdiv-3.7",
    "openvdb-13",
    "ocio-2.5",
    "oiio-3.1",
    "ptex-2.4",
    "alembic-1.8",
    "materialx-1.39",
    "openexr-3.4",
    "imath-3.2",
    "PySide6-6.8",
    "PyOpenGL",
    "numpy-2.3",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
    env.PYTHONPATH.prepend("{root}/lib/python3.13/site-packages")
    # usdview reads this stylesheet instead of its built-in one when it
    # exists (patched in build.sh); vfx-theme writes it per scheme.
    env.VFX_USDVIEW_QSS = "${HOME}/.config/vfx-theme/usdview.qss"
