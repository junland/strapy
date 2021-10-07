#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource file
strapyChrootCd file-*


printInfo "Configuring file"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --enable-shared \
    --disable-static


printInfo "Building file"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing file"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
