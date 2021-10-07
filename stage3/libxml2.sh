#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libxml2
strapyChrootCd libxml2-*

export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined"

printInfo "Configuring libxml2"
strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building libxml2"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing libxml2"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
