#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource perl
strapyChrootCd perl-*


printInfo "Configuring perl"

strapyChroot ./Configure \
    -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dscriptdir=/usr/bin \
    -Duseshrplib \
    -Dusethreads \
    -Dcc=clang


printInfo "Building perl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing perl"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
