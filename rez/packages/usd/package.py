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
    env.VFX_USDVIEW_COLORS = "${HOME}/.config/vfx-theme/usdview-colors.ini"
    # usdview's GL viewport: PySide6 can't make a GL context on native
    # Wayland, so run through XWayland, and keep PyOpenGL on GLX to match
    # (it picks EGL whenever WAYLAND_DISPLAY is set).
    env.QT_QPA_PLATFORM = "xcb"
    env.PYOPENGL_PLATFORM = "glx"
    # Storm needs OpenGL 4.5; VM GPUs (virgl) only offer 4.3, so use Mesa's
    # software renderer there. Real GPUs are left alone.
    try:
        with open("/sys/class/dmi/id/sys_vendor") as f:
            vendor = f.read()
    except OSError:
        vendor = ""
    if any(v in vendor for v in ("QEMU", "VMware", "innotek")):
        env.LIBGL_ALWAYS_SOFTWARE = "1"
