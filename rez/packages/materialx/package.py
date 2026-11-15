# -*- coding: utf-8 -*-
name = "materialx"
version = "1.39.5"
description = "MaterialX shading"
authors = ["vfx-linux"]

requires = [
    "python-3.13",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
    env.PYTHONPATH.prepend("{root}/python")
