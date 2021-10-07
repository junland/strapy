#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource automake
strapyChrootCd automake-*


printInfo "Configuring automake"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building automake"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing automake"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
