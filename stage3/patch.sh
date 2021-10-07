#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource patch
strapyChrootCd patch-*


printInfo "Configuring patch"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building patch"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing patch"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
