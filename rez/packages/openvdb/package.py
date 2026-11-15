# -*- coding: utf-8 -*-
name = "openvdb"
version = "13.2.0"
description = "OpenVDB volumes (CY2026: 13.x)"
authors = ["vfx-linux"]

requires = [
    "tbb-2022",
    "imath-3.2",
    "openexr-3.4",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
