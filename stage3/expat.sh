#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource expat
strapyChrootCd expat-*


printInfo "Configuring expat"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building expat"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing expat"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
