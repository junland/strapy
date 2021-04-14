#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource flex
serpentChrootCd flex-*


printInfo "Configuring flex"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building flex"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing flex"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
