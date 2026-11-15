# -*- coding: utf-8 -*-
name = "opensubdiv"
version = "3.7.0"
description = "OpenSubdiv (CY2026: 3.7.x)"
authors = ["vfx-linux"]

requires = [
    "tbb-2022",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
