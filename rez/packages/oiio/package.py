# -*- coding: utf-8 -*-
name = "oiio"
version = "3.1.19.0"
description = "OpenImageIO"
authors = ["vfx-linux"]

requires = [
    "python-3.13",
    "imath-3.2",
    "openexr-3.4",
    "ocio-2.5",
    "tbb-2022",
    "ptex-2.4",
    "openvdb-13",
]

build_command = "bash {root}/build.sh"


def commands():
    env.PATH.prepend("{root}/bin")
    env.LD_LIBRARY_PATH.prepend("{root}/lib")
    env.CMAKE_PREFIX_PATH.prepend("{root}")
    env.PKG_CONFIG_PATH.prepend("{root}/lib/pkgconfig")
    env.PYTHONPATH.prepend("{root}/lib/python3.13/site-packages")
