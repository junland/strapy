#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource curl
serpentChrootCd curl-*

printInfo "Configuring curl"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --with-openssl


printInfo "Building curl"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing curl"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
