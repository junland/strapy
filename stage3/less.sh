#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource less
strapyChrootCd less-*


printInfo "Configuring less"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building less"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing less"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
