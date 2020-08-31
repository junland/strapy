#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource linux-pam
serpentChrootCd Linux-PAM-*


printInfo "Configuring linux-pam"

serpentChroot ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --disable-nis


printInfo "Building linux-pam"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing linux-pam"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
