# -*- coding: utf-8 -*-
name = "openexr"
version = "3.4.18"
description = "OpenEXR images (CY2026: 3.4.x)"
authors = ["vfx-linux"]

requires = [
    "imath-3.2",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
