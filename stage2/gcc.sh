#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource gcc
cd gcc-*

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export SERPENT_STAGE1_TREE=$(getInstallDir "1")
export CFLAGS="${SERPENT_TARGET_CFLAGS} -L${SERPENT_INSTALL_DIR}/usr/lib -I${SERPENT_INSTALL_DIR}/usr/include -Wno-unused-command-line-argument ${TOOLCHAIN_CFLAGS} -Wno-error"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS} -L${SERPENT_INSTALL_DIR}/usr/lib -I${SERPENT_INSTALL_DIR}/usr/include -Wno-unused-command-line-argument ${TOOLCHAIN_CFLAGS} -Wno-error"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --with-build-sysroot="${SERPENT_STAGE1_TREE}"
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-bootstrap \
    --disable-multilib \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building gcc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gcc"
make -j "${SERPENT_BUILD_JOBS}" DESTDIR="${SERPENT_INSTALL_DIR}"
