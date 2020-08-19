#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

printInfo "Configuring root filesystem"

export SERPENT_STAGE2_TREE=`getInstallDir "2"`

[ -e "${SERPENT_STAGE2_TREE}/usr/bin/clang" ] || serpentFail "Cannot find stage2 tree"

install -D -d -m 00755 "${SERPENT_INSTALL_DIR}" || serpentFail "Could not construct stage2.5 installdir"

printInfo "Duplicating stage2 for 2.5"

rsync -aHP "${SERPENT_STAGE2_TREE}/." "${SERPENT_INSTALL_DIR}/." --delete

printInfo "Duplication completed"
