# -*- coding: utf-8 -*-
name = "alembic"
version = "1.8.12"
description = "Alembic caches (CY2026: 1.8.x)"
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
