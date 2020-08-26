#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

serpentChrootCd libc-support
git clone https://dev.serpentos.com/source/libc-support.git

printInfo "Configuring libc-support"
serpentChroot meson --prefix=/usr --buildtype=plain build

printInfo "Building libc-support"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing libc-support"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
