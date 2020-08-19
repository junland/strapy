#!/bin/true

# Common functionality between all stages

export SERPENT_CHROOT_DIR="/"

# Emit a warning to tty
function printWarning()
{
    echo -en '\e[1m\e[93m[WARNING]\e[0m '
    echo -e $*
}

# Emit an error to tty
function printError()
{
    echo -en '\e[1m\e[91m[ERROR]\e[0m '
    echo -e $*
}

# Emit info to tty
function printInfo()
{
    echo -en '\e[1m\e[94m[INFO]\e[0m '
    echo -e $*
}

# Failed to do a thing. Exit fatally.
function serpentFail()
{
    printError $*
    [ "${EUID}" -eq "0" ] && takeDownMounts
    exit 1
}

# Check tools can be found
function requireTools()
{
    for tool in $* ; do
        which "${tool}" &>/dev/null  || serpentFail "Missing host executable: ${tool}"
    done
}

# Check we're running as the root user
function checkRootUser()
{
    [ "${EUID}" -eq "0" ] || serpentFail "$0: Must be run via sudo"
    [ ! -z "${SUDO_USER}" ] || serpentFail "SUDO_USER incorrectly set"
}

# Create ancillary helpers
function createMountDirs()
{
    [ ! -z "${SERPENT_INSTALL_DIR}" ] || serpentFail "Missing SERPENT_INSTALL_DIR"

    install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/dev/pts" || serpentFail "Failed to construct ${SERPENT_INSTALL_DIR}/dev/pts"
    install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/proc" || serpentFail "Failed to construct ${SERPENT_INSTALL_DIR}/proc"
    install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/sys" || serpentFail "Failed to construct ${SERPENT_INSTALL_DIR}/sys"
    install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/serpent" || serpentFail "Failed to construct ${SERPENT_INSTALL_DIR}/serpent"
    install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/build" || serpentFail "Failed to construct ${SERPENT_INSTALL_DIR}/serpent"
}

# Bring up required bindmounts for functional chroot environment
function bringUpMounts()
{
    printInfo "Bringing up the mounts"
    createMountDirs

    local stage2tree=`getInstallDir 2`

    mount --bind /dev/pts "${SERPENT_INSTALL_DIR}/dev/pts" || serpentFail "Failed to bind-mount /dev/pts"
    mount --bind /sys "${SERPENT_INSTALL_DIR}/sys" || serpentFail "Failed to bind-mount /sys"
    mount --bind /proc "${SERPENT_INSTALL_DIR}/proc" || serpentFail "Failed to bind-mount /proc"
    mount --bind -o ro "${stage2tree}" "${SERPENT_INSTALL_DIR}/serpent" || serpentFail "Failed to bind-mount /serpent"
    mount -o remount,ro,bind "${SERPENT_INSTALL_DIR}/serpent" || serpentFail "Failed to make /serpent read-only"

    mount -v --bind -o ro "${SERPENT_BUILD_DIR}" "${SERPENT_INSTALL_DIR}/build" || serpentFail "Failed to bind-mount /build"
    mount -o remount,ro,bind "${SERPENT_INSTALL_DIR}/build" || serpentFail "Failed to make /build read-only"
}

# Helper to ensure something *does* get unmounted
function serpentUnmount()
{
    local target="${1}"
    [ ! -z "${target}" ] || serpentFail "No mountpoint specified"

    umount "${target}"
    if [[ "$?" != 0 ]]; then
        sleep 1
        umount "${target}"
    fi
    if [[ "$?" != "0" ]]; then
        printWarning "Lazy-unmounting ${target}"
        umount -l "${target}" || :
    fi
}

# Take down the mounts again
function takeDownMounts()
{
    set +e
    printInfo "Taking down the mounts"
    serpentUnmount "${SERPENT_INSTALL_DIR}/build"
    serpentUnmount "${SERPENT_INSTALL_DIR}/serpent"
    serpentUnmount "${SERPENT_INSTALL_DIR}/dev/pts"
    serpentUnmount "${SERPENT_INSTALL_DIR}/sys"
    serpentUnmount "${SERPENT_INSTALL_DIR}/proc"
}

# chroot helper. In future we should expand to support qemu-static.
function serpentChroot()
{
    LD_LIBRARY_PATH="/serpent/usr/lib" PATH="${PATH}:/serpent/usr/bin" chroot "${SERPENT_INSTALL_DIR}" /serpent/usr/bin/bash -c "cd \"${SERPENT_CHROOT_DIR}\"; $*;"
}

# Set the chroot dir
function serpentChrootCd()
{
    export SERPENT_CHROOT_DIR="$1"
}

# Tightly control the path
export PATH="/usr/bin:/bin/:/sbin:/usr/sbin"

export SERPENT_ROOT_DIR="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"

export SERPENT_BUILD_ROOT="${SERPENT_ROOT_DIR}/build"
export SERPENT_DOWNLOAD_DIR="${SERPENT_ROOT_DIR}/downloads"
export SERPENT_INSTALL_ROOT="${SERPENT_ROOT_DIR}/install"
export SERPENT_SOURCES_DIR="${SERPENT_ROOT_DIR}/sources"
export SERPENT_PATCHES_DIR="${SERPENT_ROOT_DIR}/patches"

# Basic validation.
[ -d "${SERPENT_SOURCES_DIR}" ] || serpentFail "Missing source tree"

export LANG="C"
export LC_ALL="C"
