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
stage3tree=$(getInstallDir 3)

COMPONENTS=(
    #"root"
    "headers" # gnu toolchain needs to set PATH /usr/binutils/bin
    #"glibc"
#    "diffutils"
#    "zlib"
#    "xz"
#    "file"
#    "libarchive"
    #"binutils"
    #"gcc"
#    "attr"
#    "acl"
#    "findutils"
#    "ncurses"
#    "bash"
    "dash" # build failure - common:?
#    "slibtool"
#    "gzip"
#    "less"
#    "sed"
    "gawk" # Needs ar, so want symlinks in build
#    "grep"
#    "patch"
#    "which"
    "m4" # patches
#    "make"
#    "perl"
#    "autoconf"
#    "automake"
    "pkgconf" # .la make error
    "coreutils" # patches
#    "util-linux"
#    "cmake"
#    "ninja"
    "libcap" # Needs ar, so want symlinks in build
#    "gperf"
#    "libffi"
#    "python"
    #"meson"
#    "linux-pam"
#    "shadow"
#    "expat"
#    "dbus"
#    "systemd"
#    "dbus-broker"
    #"toolchain"
    #"libxml2"
    #"ldc"
#    "zstd"
    #"boulder"
    #"moss"
#    "nano"
)

checkRootUser

requireTools "mknod"

# Create download store so boulder is not required to fetch any files (lacks curl)
prefetchSources
mkdir -p "${SERPENT_BUILD_DIR}/stones" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}/stones"
mkdir -p "${stage3tree}/os/store/downloads/v1/staging" || serpentFail "Failed to create directory ${stage3tree}/os/store/downloads/v1/staging"
mkdir -p "${stage3tree}/root" || serpentFail "Failed to create directory ${stage3tree}/root"
createDownloadStore

bringUpMounts

for component in ${COMPONENTS[@]} ; do
    cp "${executionPath}/${component}.yml" "${SERPENT_BUILD_DIR}/stones/"
    chroot "${stage3tree}" /bin/bash -c "cd /stones; boulder build ${component}.yml;"
done

takeDownMounts
