# -*- coding: utf-8 -*-
name = "imath"
version = "3.2.3"
description = "Imath math library (CY2026: 3.2.x)"
authors = ["vfx-linux"]

requires = [
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
