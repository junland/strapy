#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource grep
strapyChrootCd grep-*


printInfo "Configuring grep"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building grep"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing grep"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
