#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource attr
strapyChrootCd attr-*

printInfo "Configuring attr"
strapyChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --enable-shared \
    --disable-static

printInfo "Building attr"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
