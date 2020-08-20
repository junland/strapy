#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource coreutils
cd coreutils-*


printInfo "Configuring coreutils"
# Fix aarch64 SYS_getdents regression
patch -p1 < "${SERPENT_PATCHES_DIR}/coreutils/coreutils_8_31_ls.patch"
patch -p1 < "${SERPENT_PATCHES_DIR}/coreutils/0001-m4-host-os-Do-not-define-Serpent-OS-as-GNU-Linux.patch"

export FORCE_UNSAFE_CONFIGURE=1
./configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-acl \
    --disable-nls \
    --enable-largefile \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-single-binary


printInfo "Building coreutils"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing coreutils"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
