#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "glibc" ]]; then
    printInfo "Skipping binutils with non-glibc libc"
    exit 0
fi

extractSource binutils
pushd binutils-*
mkdir build
popd
serpentChrootCd binutils-*/build

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring binutils"
serpentChroot ../configure --prefix=/usr/binutils \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --includedir=/usr/include \
    --disable-multilib \
    --enable-deterministic-archives \
    --disable-plugins \
    --disable-shared \
    --enable-static \
    --enable-ld=default \
    --enable-secureplt \
    --enable-64-bit-bfd

printInfo "Building binutils"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr/binutils

printInfo "Installing binutils"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr/binutils install
