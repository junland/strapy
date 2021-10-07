#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource gzip
strapyChrootCd gzip-*


printInfo "Configuring gzip"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building gzip"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing gzip"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
