# -*- coding: utf-8 -*-
name = "python"
version = "3.13.18"
description = "CPython (VFX Reference Platform CY2026: 3.13.x)"
authors = ["vfx-linux"]

requires = []

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
