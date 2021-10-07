#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource nano
strapyChrootCd nano-*


printInfo "Configuring nano"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --enable-utf8

printInfo "Building nano"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing nano"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
