#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource acl
serpentChrootCd acl-*

printInfo "Configuring acl"
serpentChroot ./configure \
    --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --enable-shared \
    --disable-static

printInfo "Building acl"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
