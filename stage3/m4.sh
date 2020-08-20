#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource m4
serpentChrootCd m4-*


printInfo "Configuring m4"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building m4"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing m4"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
