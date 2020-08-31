#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: Three                                                         #
#                                                                      #
# We construct a chroot environment that has an empty layout, that is  #
# used to natively build the final system. To achieve this, some quick #
# compatibility work is done, such as building musl and the system     #
# headers.
#
# We bind-mount the stage2 support environment to the /serpent tree    #
# and add it to the end of the PATH environmental variable. This lets  #
# us use the native compiler, libs, etc, to natively build all of our  #
# needed software and install to the root of the tree.                 #
#                                                                      #
########################################################################

export SERPENT_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "musl"
    "attr"
    "acl"
    "findutils"
    "zlib"
    "xz"
    "diffutils"
    "ncurses"
    "bash"
    "dash"
    "file"
    "coreutils"
    "util-linux"
    "libarchive"
    "slibtool"
    "gzip"
    "less"
    "sed"
    "gawk"
    "grep"
    "patch"
    "which"
    "m4"
    "make"
    "perl"
    "autoconf"
    "automake"
    "pkgconf"
    "cmake"
    "ninja"
    "libcap"
    "gperf"
    "libffi"
    "python"
    "meson"
    "libc-support"
    "libwildebeest"
    "systemd"
    "shadow"
)

checkRootUser

requireTools "mknod"

prefetchSources
mkdir -p "${SERPENT_BUILD_DIR}" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}"
bringUpMounts

if [[ "${SERPENT_TARGET_ARCH}" != "${SERPENT_ARCH}" ]]; then
        requireTools "${SERPENT_QEMU_USER_STATIC}"
        installQemuStatic
fi

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
done

takeDownMounts

