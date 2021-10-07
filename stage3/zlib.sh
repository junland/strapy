#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource zlib
strapyChrootCd zlib-*


printInfo "Configuring zlib"

strapyChroot ./configure --prefix=/usr \
    --libdir=/usr/lib \
    --enable-shared

printInfo "Building zlib"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
