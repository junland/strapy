#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource autoconf
strapyChrootCd autoconf-*


printInfo "Configuring autoconf"

strapyChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building autoconf"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing autoconf"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
