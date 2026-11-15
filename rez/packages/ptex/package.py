# -*- coding: utf-8 -*-
name = "ptex"
version = "2.4.3"
description = "Ptex per-face textures (CY2026: 2.4.x)"
authors = ["vfx-linux"]

requires = [
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
