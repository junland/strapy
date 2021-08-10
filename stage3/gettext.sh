#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource gettext
serpentChrootCd gettext-*


printInfo "Configuring gettext"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share

printInfo "Building gettext"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gettext"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
