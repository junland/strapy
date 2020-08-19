#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource diffutils

printInfo "Configuring diffutils"
serpentChrootCd diffutils*
serpentChroot ./configure \
    --host="${SERPENT_TRIPLET}" \
    --build="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --bindir=/usr/bin

printInfo "Building diffutils"
serpentChroot make -j${SERPENT_BUILD_JOBS}
serpentChroot make -j${SERPENT_BUILD_JOBS} install
