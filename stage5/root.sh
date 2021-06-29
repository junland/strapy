#!/bin/true
set -e

#. $(dirname $(realpath -s $0))/common.sh

printInfo "Configuring root filesystem layout"

install -v -D -d -m 00755 "${SERPENT_INSTALL_DIR}"/mossInstall/usr/{bin,lib,share,sbin,include}
install -v -D -d -m 00755 "${SERPENT_INSTALL_DIR}"/mossInstall/{etc,proc,run,var,sys,dev,tmp}

install -v -D -d -m 00755 "${SERPENT_INSTALL_DIR}/mossInstall/run/lock"
ln -svf ../run/lock "${SERPENT_INSTALL_DIR}/mossInstall/var/lock"

ln -svf lib "${SERPENT_INSTALL_DIR}/mossInstall/usr/lib64"
ln -svf usr/bin "${SERPENT_INSTALL_DIR}/mossInstall/bin"
ln -svf usr/sbin "${SERPENT_INSTALL_DIR}/mossInstall/sbin"
ln -svf usr/lib "${SERPENT_INSTALL_DIR}/mossInstall/lib"
ln -svf usr/lib64 "${SERPENT_INSTALL_DIR}/mossInstall/lib64"


printInfo "Constructing device nodes"

# TTY support
mknod -m 622 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/console c 5 1
mknod -m 666 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/ptmx c 5 2
mknod -m 666 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/tty c 5 0
chown -v root:tty "${SERPENT_INSTALL_DIR}"/mossInstall/dev/{console,ptmx,tty}

# Runtime support for random/null/zero
mknod -m 666 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/null c 1 3
mknod -m 666 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/zero c 1 5
mknod -m 444 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/random c 1 8
mknod -m 444 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/urandom c 1 9

printInfo "Creating runtime device links"

# runtime support
ln -svf /proc/self/fd "${SERPENT_INSTALL_DIR}"/mossInstall/dev/fd
ln -svf /proc/self/fd/0 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/stdin
ln -svf /proc/self/fd/1 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/stdout
ln -svf /proc/self/fd/2 "${SERPENT_INSTALL_DIR}"/mossInstall/dev/stderr
ln -svf /proc/kcore "${SERPENT_INSTALL_DIR}"/mossInstall/dev/core

