# vfx-linux rez configuration. Installed to /etc/rez/rezconfig.py and
# selected with REZ_CONFIG_FILE (see /etc/profile.d/rez.sh).

# Where rez looks for packages, in order:
#   ~/packages              your own local builds (rez-build --install)
#   /opt/vfx/rez/packages   the shared VFX stack built by vfx-rez-build
packages_path = [
    "~/packages",
    "/opt/vfx/rez/packages",
]
local_packages_path = "~/packages"
release_packages_path = "/opt/vfx/rez/packages"

default_shell = "bash"
