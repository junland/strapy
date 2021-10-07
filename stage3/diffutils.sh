#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource diffutils

printInfo "Configuring diffutils"
strapyChrootCd diffutils*
strapyChroot ./configure \
    --host="${STRAPY_TRIPLET}" \
    --build="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share

printInfo "Building diffutils"
strapyChroot make -j${STRAPY_BUILD_JOBS}
strapyChroot make -j${STRAPY_BUILD_JOBS} install
