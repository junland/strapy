#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
    printInfo "Skipping bash with non-glibc libc"
    exit 0
fi

extractSource bash
strapyChrootCd bash-*

printInfo "Configuring bash"
strapyChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --without-bash-malloc \
    --enable-nls

printInfo "Building bash"
strapyChroot make -j3

strapyChroot make -j3 install
ln -svf bash "${STRAPY_INSTALL_DIR}/usr/bin/sh"
