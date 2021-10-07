#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

activateStage1Compiler

extractSource linux
cd linux-*

if [[ "${STRAPY_LIBC}" == "glibc" ]]; then
    export STRAPY_STAGE1_TREE=$(getInstallDir "1")
    export PATH="${STRAPY_STAGE1_TREE}/usr/binutils/bin:${PATH}"
fi


printInfo "Configuring headers"
export ARCH="${STRAPY_TARGET_ARCH}"
make mrproper
make headers
find usr/include -name '.*' -delete
rm -vf usr/include/Makefile

printInfo "Installing headers"
install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/usr/include"
cp -Rv usr/include "${STRAPY_INSTALL_DIR}/usr/."
