#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource findutils
serpentChrootCd findutils-*

printInfo "Configuring findutils"
serpentChroot ./configure \
    --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \

printInfo "Building findutils"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
