#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource acl
strapyChrootCd acl-*

printInfo "Configuring acl"
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

printInfo "Building acl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
