#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: Five                                                          #
#                                                                      #
# We construct a chroot environment from built stone packages for some #
# quick performance testing. This is not required for the bootstrap,   #
# but being used to test some configurations in boulder.               #
#                                                                      #
########################################################################

export SERPENT_STAGE_NAME="stage5"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

export SERPENT_TARGET=${SERPENT_TARGET:-"x86_64"}                                                    
export SERPENT_LIBC=${SERPENT_LIBC:-"glibc"}
export SERPENT_ROOT_DIR="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"
export SERPENT_INSTALL_ROOT="${SERPENT_ROOT_DIR}/install"
export SERPENT_BUILD_DIR="${SERPENT_BUILD_ROOT}/${SERPENT_STAGE_NAME}"
export SERPENT_INSTALL_DIR="${SERPENT_INSTALL_ROOT}/${SERPENT_TARGET}/${SERPENT_LIBC}/${SERPENT_STAGE_NAME}"

### takeDownMounts
set +e

printInfo "Taking down the mounts"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/build"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/dev/pts"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/dev/shm"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/sys"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/proc"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/tmp"

set -e
###

install -D -d -m 00755 "${SERPENT_BUILD_DIR}"
requireTools "mknod"

checkRootUser

### bringUpMounts

printInfo "Bringing up the mounts"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/dev/pts" || serpentFail "Failed to construct /dev/pts"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/dev/shm" || serpentFail "Failed to construct /dev/shm"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/proc" || serpentFail "Failed to construct /proc"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/sys" || serpentFail "Failed to construct /sys"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/build" || serpentFail "Failed to construct /build"

mount -v --bind /dev/pts "${SERPENT_INSTALL_DIR}/mossInstall/dev/pts" || serpentFail "Failed to bind-mount /dev/pts"
mount -v --bind /dev/shm "${SERPENT_INSTALL_DIR}/mossInstall/dev/shm" || serpentFail "Failed to bind-mount /dev/shm"
mount -v --bind /sys "${SERPENT_INSTALL_DIR}/mossInstall/sys" || serpentFail "Failed to bind-mount /sys"
mount -v --bind /proc "${SERPENT_INSTALL_DIR}/mossInstall/proc" || serpentFail "Failed to bind-mount /proc"
mount -t tmpfs tmpfs "${SERPENT_INSTALL_DIR}/mossInstall/tmp" || serpentFail "Failed to mount /tmp"

mount -v --bind "${SERPENT_BUILD_DIR}" "${SERPENT_INSTALL_DIR}/mossInstall/build" || serpentFail "Failed to bind-mount /build"
###

echo 'export PS1="(chroot/bash-\v/${SERPENT_TRIPLET}) : [\w]\n\\$ "' > "${SERPENT_INSTALL_DIR}/mossInstall/etc/profile"
echo "alias ls='ls --color=auto -F'" >> "${SERPENT_INSTALL_DIR}/mossInstall/etc/profile"

chroot "${SERPENT_INSTALL_DIR}/mossInstall" /bin/bash -i

### takeDownMounts
set +e

printInfo "Taking down the mounts"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/build"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/dev/pts"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/dev/shm"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/sys"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/proc"
serpentUnmount "${SERPENT_INSTALL_DIR}/mossInstall/tmp"

###
