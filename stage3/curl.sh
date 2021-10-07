#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource curl
strapyChrootCd curl-*

printInfo "Configuring curl"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --with-openssl


printInfo "Building curl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing curl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
