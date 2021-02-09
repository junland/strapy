#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource nano
serpentChrootCd nano-*


printInfo "Configuring nano"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --enable-utf8

printInfo "Building nano"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing nano"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
