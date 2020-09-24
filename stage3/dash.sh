#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "musl" ]]; then
    printInfo "Skipping dash with non-musl libc"
    exit 0
fi

extractSource dash
serpentChrootCd dash-*

printInfo "Configuring dash"
serpentChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --enable-static

printInfo "Building dash"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing dash"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
ln -svf dash "${SERPENT_INSTALL_DIR}/usr/bin/sh"
