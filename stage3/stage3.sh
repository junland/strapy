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
    "${SERPENT_LIBC}"
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
    "libxml2"
    "ldc"
    "rocksdb"
    "boulder"
    "moss"
    "nano"
    "bison"
    "flex"
    "openssl"
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

# Install the config.site file for autotools caching
cp "${executionPath}/config.site" "${SERPENT_INSTALL_DIR}/"

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
done

# Add in 32bit support into Serpent
rm "${SERPENT_INSTALL_DIR}/config.site"
restoreBinutils gnu-binutils
restoreGcc gnu-gcc

printInfo "Taking down the mounts"
serpentUnmount "$(getInstallDir 3)/serpent"

/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/gcc32.sh" || serpentFail "Building gcc32 failed"
/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/gcc32.sh" || serpentFail "Building gcc32 failed"
/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/glibc32.sh" || serpentFail "Building glibc32 failed"
/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/gcc32-2.sh" || serpentFail "Building gcc32-2 failed"
/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/toolchain32.sh" || serpentFail "Building toolchain32 failed"

restoreBinutils llvm-llvm
restoreGcc llvm-llvm

/usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/toolchain.sh" || serpentFail "Building toolchain failed"

takeDownMounts

