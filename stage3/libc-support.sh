#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "musl" ]]; then
    printInfo "Skipping libc-support with non-musl libc"
    exit 0
fi

strapyChrootCd libc-support
git clone https://dev.strapyos.com/source/libc-support.git

printInfo "Configuring libc-support"
strapyChroot meson --prefix=/usr --buildtype=plain build

printInfo "Building libc-support"
strapyChroot ninja -j "${STRAPY_BUILD_JOBS}" -C build

printInfo "Installing libc-support"
strapyChroot ninja install -j "${STRAPY_BUILD_JOBS}" -C build
