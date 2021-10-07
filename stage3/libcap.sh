#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libcap
strapyChrootCd libcap-*

# Static linking broken
cd libcap-*
sed -i Makefile -e '/\-C tests/d'

printInfo "Building libcap"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" BUILD_CC=clang CC=clang

printInfo "Installing libcap"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install RAISE_SETFCAP=no prefix=/usr lib=lib
