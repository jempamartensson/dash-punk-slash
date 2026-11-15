# -*- coding: utf-8 -*-
name = "ocio"
version = "2.5.2"
description = "OpenColorIO (CY2026: 2.5.x)"
authors = ["vfx-linux"]

requires = [
    "python-3.13",
    "imath-3.2",
    "openexr-3.4",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
    env.PYTHONPATH.prepend("{root}/lib/python3.13/site-packages")
