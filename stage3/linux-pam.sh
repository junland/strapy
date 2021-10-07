#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource linux-pam
strapyChrootCd Linux-PAM-*

printInfo "Configuring linux-pam"
unset CONFIG_SITE

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    # Configure is *woefully* broken so we manually set up the required usertype limits
    export CFLAGS="${CFLAGS} $(strapyChroot pkg-config --cflags --libs libwildebeest-pwd) -Wno-unused-command-line-argument -DPAM_USERTYPE_OVERFLOW_UID=65534 -DPAM_USERTYPE_SYSUIDMIN=101 -DPAM_USERTYPE_UIDMIN=1000"
fi

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --disable-nis \
    --with-kernel-overflow-uid=65534

printInfo "Building linux-pam"
strapyChroot make -j 1 V=1 VERBOSE=1

printInfo "Installing linux-pam"
strapyChroot make -j 1 V=1 VERBOSE=1 install
