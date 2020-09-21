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


# Help the compiler find pthread.h as it is not in the stage1 compilers default search path
export CFLAGS="${SERPENT_TARGET_CFLAGS} -L${SERPENT_INSTALL_DIR}/usr/lib -I${SERPENT_INSTALL_DIR}/usr/include -Wno-unused-command-line-argument ${TOOLCHAIN_CFLAGS} -Wno-error"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS} -L${SERPENT_INSTALL_DIR}/usr/lib -I${SERPENT_INSTALL_DIR}/usr/include -Wno-unused-command-line-argument ${TOOLCHAIN_CFLAGS} -Wno-error"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-bootstrap \
    --disable-multilib \
    --disable-libstdcxx \
    --enable-shared \
    --enable-threads=posix \
    --enable-gnu-indirect-function \
    --enable-__cxa_atexit \
    --enable-ld=default \
    --enable-clocale=gnu \
    --with-gcc-major-version-only \
    --enable-linker-build-id  \
    --with-linker-hash-style=gnu \
    --with-gnu-ld \
    --enable-languages=c

printInfo "Building gcc"
make -j "${SERPENT_BUILD_JOBS}" all-gcc all-target-libgcc

printInfo "Installing gcc"
make -j "${SERPENT_BUILD_JOBS}" install-gcc install-target-libgcc DESTDIR="${SERPENT_INSTALL_DIR}"
