#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource linux-pam
serpentChrootCd Linux-PAM-*

printInfo "Configuring linux-pam"
unset CONFIG_SITE

# Configure is *woefully* broken so we manually set up the required userype limits
export CFLAGS="${CFLAGS} $(serpentChroot pkg-config --cflags --libs libwildebeest-pwd) -Wno-unused-command-line-argument -DPAM_USERTYPE_OVERFLOW_UID=65534 -DPAM_USERTYPE_SYSUIDMIN=101 -DPAM_USERTYPE_UIDMIN=1000"

serpentChroot ac_cv_func_quotactl=0 ac_cv_search_dlopen="-lc" ac_cv_search_opendir="-lc" ac_cv_search_crypt="-lc" ./configure \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --disable-nis \
    --with-kernel-overflow-uid=65534


serpentChroot sed -e '/PAM_USERTYPE_/d' -i config.h
printInfo "Building linux-pam"
serpentChroot make -j 1 V=1 VERBOSE=1

printInfo "Installing linux-pam"
serpentChroot make -j 1 V=1 VERBOSE=1
