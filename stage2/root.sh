#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

printInfo "Configuring root filesystem layout"

install -v -D -d -m 00755 "${STRAPY_INSTALL_DIR}"/usr/{bin,lib,share,sbin,include}
install -v -D -d -m 00755 "${STRAPY_INSTALL_DIR}"/{etc,proc,run,var,sys,dev,tmp}

install -v -D -d -m 00755 "${STRAPY_INSTALL_DIR}/run/lock"
ln -sv ../run/lock "${STRAPY_INSTALL_DIR}/var/lock"

ln -sv lib "${STRAPY_INSTALL_DIR}/usr/lib64"
ln -sv usr/bin "${STRAPY_INSTALL_DIR}/bin"
ln -sv usr/sbin "${STRAPY_INSTALL_DIR}/sbin"
ln -sv usr/lib "${STRAPY_INSTALL_DIR}/lib"
ln -sv usr/lib64 "${STRAPY_INSTALL_DIR}/lib64"
