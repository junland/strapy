#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource glibc
cd glibc-*

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring glibc headers"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --build="${MACHTYPE}" \
    --host="${SERPENT_TRIPLET}" \
    --target="${SERPENT_TRIPLET}" \
    libc_cv_forced_unwind=yes


printInfo "Installing glibc headers"
make -j "${SERPENT_BUILD_JOBS}" install-bootstrap-headers=yes install-headers
make -j "${SERPENT_BUILD_JOBS}" csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o "${SERPENT_INSTALL_DIR}/usr/lib"
"${SERPENT_TRIPLET}-gcc" -nostdlib -nostartfiles -shared -x c /dev/null -o "${SERPENT_INSTALL_DIR}/usr/lib/libc.so"
touch "${SERPENT_INSTALL_DIR}/usr/include/gnu/stubs.h"
