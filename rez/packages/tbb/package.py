# -*- coding: utf-8 -*-
name = "tbb"
version = "2022.3.0"
description = "oneTBB threading (CY2026: 2022.x)"
authors = ["vfx-linux"]

requires = [
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
