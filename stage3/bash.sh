#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource bash
serpentChrootCd bash-*

printInfo "Configuring bash"
serpentChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --without-bash-malloc \
    --enable-nls

printInfo "Building bash"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
