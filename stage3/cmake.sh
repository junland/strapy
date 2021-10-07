#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource cmake
strapyChrootCd cmake-*


printInfo "Configuring cmake"

strapyChroot ./configure \
    --prefix=/usr \
    --parallel="${STRAPY_BUILD_JOBS}" \
    -- -DCMAKE_USE_OPENSSL=OFF

printInfo "Building cmake"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing cmake"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
