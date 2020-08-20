#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource coreutils
serpentChrootCd coreutils-*
pushd coreutils-*


printInfo "Configuring coreutils"
# Fix aarch64 SYS_getdents regression
patch -p1 < "${SERPENT_PATCHES_DIR}/coreutils_8_31_ls.patch"

export FORCE_UNSAFE_CONFIGURE=1
serpentChroot ./configure --prefix=/usr \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --enable-largefile \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --enable-single-binary


printInfo "Building coreutils"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing coreutils"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
