#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource nghttp2
strapyChrootCd nghttp2-*

printInfo "Configuring nghttp2"

strapyChroot cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \


printInfo "Building nghttp2"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing nghttp2"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
