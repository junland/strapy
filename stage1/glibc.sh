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
export CC="${SERPENT_TRIPLET}-gcc"
export CXX="${SERPENT_TRIPLET}-g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring glibc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --build="${SERPENT_HOST}" \
    --host="${SERPENT_TRIPLET}" \
    --with-headers="${SERPENT_INSTALL_DIR}/usr/include" \
    --disable-multilib

printInfo "Building glibc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
