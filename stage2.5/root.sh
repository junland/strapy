#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

printInfo "Configuring root filesystem"

export SERPENT_STAGE2_TREE=`getInstallDir "2"`

[ -e "${SERPENT_STAGE2_TREE}/usr/bin/clang" ] || serpentFail "Cannot find stage2 tree"

install -D -d -m 00755 "${SERPENT_INSTALL_DIR}" || serpentFail "Could not construct stage2.5 installdir"

printInfo "Duplicating stage2 for 2.5"

# We bindmount prior to rsync, so lets prevent hell on earth.
rsync --exclude '/dev' --exclude '/proc' --exclude '/sys' -aHP "${SERPENT_STAGE2_TREE}/." "${SERPENT_INSTALL_DIR}/."

printInfo "Constructing device nodes"

# TTY support
mknod -m 622 "${SERPENT_INSTALL_DIR}"/dev/console c 5 1
mknod -m 666 "${SERPENT_INSTALL_DIR}"/dev/ptmx c 5 2
mknod -m 666 "${SERPENT_INSTALL_DIR}"/dev/tty c 5 0
chown -v root:tty "${SERPENT_INSTALL_DIR}"/dev/{console,ptmx,tty}

# Runtime support for random/null/zero
mknod -m 666 "${SERPENT_INSTALL_DIR}"/dev/null c 1 3
mknod -m 666 "${SERPENT_INSTALL_DIR}"/dev/zero c 1 5
mknod -m 444 "${SERPENT_INSTALL_DIR}"/dev/random c 1 8
mknod -m 444 "${SERPENT_INSTALL_DIR}"/dev/urandom c 1 9

printInfo "Creating runtime device links"

# runtime support
ln -svf /proc/self/fd "${SERPENT_INSTALL_DIR}"/dev/fd
ln -svf /proc/self/fd/0 "${SERPENT_INSTALL_DIR}"/dev/stdin
ln -svf /proc/self/fd/1 "${SERPENT_INSTALL_DIR}"/dev/stdout
ln -svf /proc/self/fd/2 "${SERPENT_INSTALL_DIR}"/dev/stderr
ln -svf /proc/kcore "${SERPENT_INSTALL_DIR}"/dev/core

printInfo "Duplication completed"
