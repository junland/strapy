#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource python
strapyChrootCd Python-*


printInfo "Configuring python"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --without-cxx-main \
    --disable-ipv6


printInfo "Building python"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing python"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
