#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource shadow
strapyChrootCd shadow-*


printInfo "Configuring shadow"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building shadow"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing shadow"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
