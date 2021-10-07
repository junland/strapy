#!/bin/true

# Common functionality between all stages

export STRAPY_CHROOT_DIR="/"

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
function strapyFail()
{
    printError $*
    [ "${EUID}" -eq "0" ] && takeDownMounts
    exit 1
}

# Check tools can be found
function requireTools()
{
    for tool in $* ; do
        which "${tool}" &>/dev/null  || strapyFail "Missing host executable: ${tool}"
    done
}

# Check we're running as the root user
function checkRootUser()
{
    [ "${EUID}" -eq "0" ] || strapyFail "$0: Must be run via sudo"
    [ ! -z "${SUDO_USER}" ] || strapyFail "SUDO_USER incorrectly set"
}

# Create ancillary helpers
function createMountDirs()
{
    [ ! -z "${STRAPY_INSTALL_DIR}" ] || strapyFail "Missing STRAPY_INSTALL_DIR"

    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/dev/pts" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/dev/pts"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/dev/shm" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/dev/shm"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/proc" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/proc"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/sys" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/sys"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/strapy" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/strapy"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/build" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/build"
    install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/stones" || strapyFail "Failed to construct ${STRAPY_INSTALL_DIR}/stones"
}

# Bring up required bindmounts for functional chroot environment
function bringUpMounts()
{
    printInfo "Bringing up the mounts"
    createMountDirs

    local stage2tree=$(getInstallDir 2)
    local stage3tree=$(getInstallDir 3)

    mount -v --bind /dev/pts "${stage3tree}/dev/pts" || strapyFail "Failed to bind-mount /dev/pts"
    mount -v --bind /dev/shm "${stage3tree}/dev/shm" || strapyFail "Failed to bind-mount /dev/shm"
    mount -v --bind /sys "${stage3tree}/sys" || strapyFail "Failed to bind-mount /sys"
    mount -v --bind /proc "${stage3tree}/proc" || strapyFail "Failed to bind-mount /proc"

    if [ "${STRAPY_STAGE_NAME}" == "stage3" ]; then
        mount -v --bind -o ro "${stage2tree}" "${stage3tree}/strapy" || strapyFail "Failed to bind-mount /strapy"
        mount -v -o remount,ro,bind "${stage3tree}/strapy" || strapyFail "Failed to make /strapy read-only"
        mount -v --bind "${STRAPY_BUILD_DIR}" "${stage3tree}/build" || strapyFail "Failed to bind-mount /build"
    fi

    if [ "${STRAPY_STAGE_NAME}" == "stage4" ]; then
        mount -v --bind "${STRAPY_BUILD_DIR}/stones" "${stage3tree}/stones" || strapyFail "Failed to bind-mount /stones"
    fi

}

function installQemuStatic()
{
        printInfo "Installing qemu-user-static for cross-compilation chroot"
        install -D -m 00755 $(which ${STRAPY_QEMU_USER_STATIC}) "${STRAPY_INSTALL_DIR}/usr/bin/${STRAPY_QEMU_USER_STATIC}" || strapyFail "Failed to install qemu-user-static"
}

# Helper to ensure something *does* get unmounted
function strapyUnmount()
{
    local target="${1}"
    [ ! -z "${target}" ] || strapyFail "No mountpoint specified"

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

    local stage3tree=$(getInstallDir 3)
    printInfo "Taking down the mounts"
    strapyUnmount "${stage3tree}/build"
    strapyUnmount "${stage3tree}/strapy"
    strapyUnmount "${stage3tree}/dev/pts"
    strapyUnmount "${stage3tree}/dev/shm"
    strapyUnmount "${stage3tree}/sys"
    strapyUnmount "${stage3tree}/proc"
    strapyUnmount "${stage3tree}/stones"
}

# chroot helper. In future we should expand to support qemu-static.
function strapyChroot()
{
    if [[ -e "${STRAPY_INSTALL_DIR}/strapy/usr/bin/bash" ]]; then
        LD_LIBRARY_PATH="/strapy/usr/lib" PATH="${PATH}:/strapy/usr/bin" chroot "${STRAPY_INSTALL_DIR}" /strapy/usr/bin/bash -c "cd \"${STRAPY_CHROOT_DIR}\"; $*;"
    else
        LD_LIBRARY_PATH="/usr/lib" PATH="${PATH}:/usr/bin" chroot "${STRAPY_INSTALL_DIR}" /usr/bin/bash -c "cd \"${STRAPY_CHROOT_DIR}\"; $*;"

    fi
}

# Set the chroot dir
function strapyChrootCd()
{
    export STRAPY_CHROOT_DIR="/build/${STRAPY_BUILD_NAME}/$1"
}

# Take down the mounts again
function createDownloadStore()
{
    local stage3tree=$(getInstallDir 3)

    for i in ${STRAPY_DOWNLOAD_DIR}/*; do
        SHASUM=$(sha256sum "${i}" | cut -f1 -d' ')
        FIRST=$(echo ${SHASUM:0:5})
        LAST=$(echo ${SHASUM:59:64})
        if [ ! -f "${stage3tree}/.moss/store/downloads/v1/${FIRST}/${LAST}/${SHASUM}" ]; then
            mkdir -p "${stage3tree}/.moss/store/downloads/v1/${FIRST}/${LAST}"
            install -D ${i} "${stage3tree}/.moss/store/downloads/v1/${FIRST}/${LAST}/${SHASUM}"
        fi
        unset SHASUM FIRST LAST
    done
}

# Stash binutils binaries in subdir
function stashBinutils()
{
    local stage3tree=$(getInstallDir 3)
    local stash_dir="${1}"

    binutils_files="addr2line ar as c++filt elfedit gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip"
    mkdir -p ${stage3tree}/usr/bin/${stash_dir}
    for file in ${binutils_files}; do
        if [ -f ${stage3tree}/usr/bin/${file} ]; then
            mv ${stage3tree}/usr/bin/${file} ${stage3tree}/usr/bin/${stash_dir}/
        fi
    done
}

# Restore binutils binaries from subdir
function restoreBinutils()
{
    local stage3tree=$(getInstallDir 3)
    local stash_dir="${1}"

    binutils_files="addr2line ar as c++filt elfedit gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip"
    for file in ${binutils_files}; do
        if [ -f ${stage3tree}/usr/bin/${stash_dir}/${file} ]; then
            cp -f ${stage3tree}/usr/bin/${stash_dir}/${file} ${stage3tree}/usr/bin/
        fi
    done
}

# Stash GCC binaries in subdir
function stashGcc()
{
    local stage3tree=$(getInstallDir 3)
    local stash_dir="${1}"

    gcc_files="cc c++ cpp g++ gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool lto-dump x86_64-strapy-linux-c++ x86_64-strapy-linux-g++ x86_64-strapy-linux-gcc x86_64-strapy-linux-gcc-10 x86_64-strapy-linux-gcc-ar x86_64-strapy-linux-gcc-nm x86_64-strapy-linux-gcc-ranlib"
    mkdir -p ${stage3tree}/usr/bin/${stash_dir}
    for file in ${gcc_files}; do
        if [ -f ${stage3tree}/usr/bin/${file} ]; then
            mv ${stage3tree}/usr/bin/${file} ${stage3tree}/usr/bin/${stash_dir}/
        fi
    done
}

# Restore GCC binaries from subdir
function restoreGcc()
{
    local stage3tree=$(getInstallDir 3)
    local stash_dir="${1}"

    gcc_files="cc c++ cpp g++ gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool lto-dump x86_64-strapy-linux-c++ x86_64-strapy-linux-g++ x86_64-strapy-linux-gcc x86_64-strapy-linux-gcc-10 x86_64-strapy-linux-gcc-ar x86_64-strapy-linux-gcc-nm x86_64-strapy-linux-gcc-ranlib"
    for file in ${gcc_files}; do
        if [ -f ${stage3tree}/usr/bin/${stash_dir}/${file} ]; then
            cp -f ${stage3tree}/usr/bin/${stash_dir}/${file} ${stage3tree}/usr/bin/
        fi
    done
}

# Tightly control the path
export PATH="/usr/bin:/bin/:/sbin:/usr/sbin"

export STRAPY_ROOT_DIR="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"

export STRAPY_BUILD_ROOT="${STRAPY_ROOT_DIR}/build"
export STRAPY_DOWNLOAD_DIR="${STRAPY_ROOT_DIR}/downloads"
export STRAPY_INSTALL_ROOT="${STRAPY_ROOT_DIR}/install"
export STRAPY_SOURCES_DIR="${STRAPY_ROOT_DIR}/sources"
export STRAPY_PATCHES_DIR="${STRAPY_ROOT_DIR}/patches"

# Basic validation.
[ -d "${STRAPY_SOURCES_DIR}" ] || strapyFail "Missing source tree"

export LANG="C"
export LC_ALL="C"
