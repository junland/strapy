#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource glibc
cd glibc-*

# Build only US UTF-8 locale for now
echo "SUPPORTED_LOCALES=\
en_US.UTF-8/UTF-8
" > localedata/SUPPORTED

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring glibc"
mkdir build && pushd build
../configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --libdir=/usr/lib \
    libc_cv_forced_unwind=yes

printInfo "Building glibc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
make -j "${SERPENT_BUILD_JOBS}" localedata/install-locales DESTDIR="${SERPENT_INSTALL_DIR}"
