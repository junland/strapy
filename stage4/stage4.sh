#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: Four                                                          #
#                                                                      #
# We construct a chroot environment from the stage3 environment to use #
# to build stone packages. Sources and stage4 files are then mounted   #
# to be used in the chroot (as it doesn't have networking).            #
#                                                                      #
########################################################################

export SERPENT_STAGE_NAME="stage4"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "${SERPENT_LIBC}"
    "diffutils"
    "zlib"
    "xz"
    "file"
    "libarchive"
    "binutils"
    "gcc"
    "attr"
    "acl"
    "findutils"
    "ncurses"
    "bash"
    "dash"
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
    "coreutils"
    "util-linux"
    "cmake"
    "ninja"
    "libcap"
    "gperf"
    "libffi"
    "python"
    "meson"
    "libwildebeest"
    "libc-support"
    "linux-pam"
    "systemd"
    "shadow"
    "expat"
    "dbus"
    "dbus-broker"
    "util-linux2"
    "systemd"
    "dbus-broker"
    "toolchain"
    "ldc"
    "zstd"
    "boulder"
    "moss"
    "nano"
)

checkRootUser

requireTools "mknod"

prefetchSources
mkdir -p "${SERPENT_BUILD_DIR}/stones" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}/stones"
mkdir -p "${SERPENT_BUILD_DIR}/os" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}/os"
createDownloadStore

bringUpMounts



#for component in ${COMPONENTS[@]} ; do
#    /usr/bin/env -S -i bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
#done

takeDownMounts

