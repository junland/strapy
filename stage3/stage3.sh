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
# We bind-mount the stage2 support environment to the /strapy tree    #
# and add it to the end of the PATH environmental variable. This lets  #
# us use the native compiler, libs, etc, to natively build all of our  #
# needed software and install to the root of the tree.                 #
#                                                                      #
########################################################################

export STRAPY_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "${STRAPY_LIBC}"
    "gettext"
    "diffutils"
    "zlib"
    "xz"
    "file"
    "findutils"
    "libarchive"
    "zstd"
    "binutils"
    "gcc"
    "attr"
    "acl"
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
    "libxml2"
    "ldc"
    "moss"
    "nano"
    "bison"
    "flex"
    "openssl"
    "jansson"
    "nghttp2"
    "curl"
)

checkRootUser

requireTools "mknod"

prefetchSources
mkdir -p "${STRAPY_BUILD_DIR}" || strapyFail "Failed to create directory ${STRAPY_BUILD_DIR}"
bringUpMounts

if [[ "${STRAPY_TARGET_ARCH}" != "${STRAPY_ARCH}" ]]; then
        requireTools "${STRAPY_QEMU_USER_STATIC}"
        installQemuStatic
fi

# Install the config.site file for autotools caching
cp "${executionPath}/config.site" "${STRAPY_INSTALL_DIR}/"

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/${component}.sh"  || strapyFail "Building ${component} failed"
done

# Add in 32bit support into Serpent
rm "${STRAPY_INSTALL_DIR}/config.site"
restoreBinutils gnu-binutils
restoreGcc gnu-gcc

printInfo "Taking down the mounts"
strapyUnmount "$(getInstallDir 3)/strapy"

/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/gcc32.sh" || strapyFail "Building gcc32 failed"
/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/gcc32.sh" || strapyFail "Building gcc32 failed"
/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/glibc32.sh" || strapyFail "Building glibc32 failed"
/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/gcc32-2.sh" || strapyFail "Building gcc32-2 failed"
/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/toolchain32.sh" || strapyFail "Building toolchain32 failed"

restoreBinutils llvm-llvm
restoreGcc llvm-llvm

/usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/toolchain.sh" || strapyFail "Building toolchain failed"

takeDownMounts

