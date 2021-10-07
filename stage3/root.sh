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


printInfo "Constructing device nodes"

# TTY support
mknod -m 622 "${STRAPY_INSTALL_DIR}"/dev/console c 5 1
mknod -m 666 "${STRAPY_INSTALL_DIR}"/dev/ptmx c 5 2
mknod -m 666 "${STRAPY_INSTALL_DIR}"/dev/tty c 5 0
chown -v root:tty "${STRAPY_INSTALL_DIR}"/dev/{console,ptmx,tty}

# Runtime support for random/null/zero
mknod -m 666 "${STRAPY_INSTALL_DIR}"/dev/null c 1 3
mknod -m 666 "${STRAPY_INSTALL_DIR}"/dev/zero c 1 5
mknod -m 444 "${STRAPY_INSTALL_DIR}"/dev/random c 1 8
mknod -m 444 "${STRAPY_INSTALL_DIR}"/dev/urandom c 1 9

printInfo "Creating runtime device links"

# runtime support
ln -svf /proc/self/fd "${STRAPY_INSTALL_DIR}"/dev/fd
ln -svf /proc/self/fd/0 "${STRAPY_INSTALL_DIR}"/dev/stdin
ln -svf /proc/self/fd/1 "${STRAPY_INSTALL_DIR}"/dev/stdout
ln -svf /proc/self/fd/2 "${STRAPY_INSTALL_DIR}"/dev/stderr
ln -svf /proc/kcore "${STRAPY_INSTALL_DIR}"/dev/core

printInfo "Stashing /bin/sh compat link"

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    ln -svf /strapy/usr/bin/dash "${STRAPY_INSTALL_DIR}/usr/bin/sh"
else
    ln -sfv /strapy/usr/bin/bash "${STRAPY_INSTALL_DIR}/usr/bin/sh"
fi
