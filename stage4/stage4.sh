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

GNUCOMPONENTS=(
    "headers"
    "glibc"
    "binutils"
    "gcc"
)

COMPONENTS=(
    #"root" # need some kind of baselayout
    "diffutils"
    "zlib"
    "xz"
    "file"
    "libarchive"
    "attr"
    "acl"
    "findutils"
    "ncurses"
    "bash"
    "dash" # build failure - common:?
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
    "coreutils" # patches
    "util-linux"
    "cmake"
    "ninja"
    "libcap"
    "gperf"
    "libffi"
    "python"
    "meson"
    "linux-pam"
    "shadow"
    "expat"
    "dbus"
    "systemd"
    "dbus-broker"
    "llvm"
    "libxml2"
    "ldc" # patches
    "zstd"
    "boulder" # needs a release or git support
    "moss" # needs a release or git support
    "nano"
    "bison"
    "flex"
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

restoreBinutils gnu-binutils
restoreGcc gnu-gcc

for component in ${GNUCOMPONENTS[@]} ; do
    cp "${executionPath}/${component}.yml" "${SERPENT_BUILD_DIR}/stones/"
    chroot "${stage3tree}" /bin/bash -c "cd /stones; boulder build ${component}.yml;"
done

restoreBinutils llvm-llvm
restoreGcc llvm-llvm

for component in ${COMPONENTS[@]} ; do
    cp "${executionPath}/${component}.yml" "${SERPENT_BUILD_DIR}/stones/"
    chroot "${stage3tree}" /bin/bash -c "cd /stones; boulder build ${component}.yml;"
done

takeDownMounts
