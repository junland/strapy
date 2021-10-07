#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource zstd
strapyChrootCd zstd-*


printInfo "Building zstd"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing zstd"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install PREFIX=/usr LIBDIR=/usr/lib
