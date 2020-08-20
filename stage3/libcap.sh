#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libcap
serpentChrootCd libcap-*


printInfo "Building libcap"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing libcap"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install RAISE_SETFCAP=no prefix=/usr lib=lib
