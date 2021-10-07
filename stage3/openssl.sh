#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource openssl
strapyChrootCd openssl-*


printInfo "Configuring openssl"

strapyChroot ./Configure \
    --prefix=/usr \
    --libdir=/usr/lib \


printInfo "Building openssl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing openssl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
