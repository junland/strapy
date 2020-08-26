#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

serpentChrootCd libwildebeest
git clone https://dev.serpentos.com/source/libwildebeest.git

printInfo "Configuring libwildebeest"
serpentChroot meson --prefix=/usr --buildtype=plain build

printInfo "Building libwildebeest"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing libwildebeest"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
