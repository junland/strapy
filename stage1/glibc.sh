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

export CFLAGS="-O2"
export CXXFLAGS="-O2"

printInfo "Configuring glibc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --build="${SERPENT_HOST}" \
    --host="${SERPENT_TRIPLET}" \
    --with-headers="${SERPENT_INSTALL_DIR}/usr/include" \
    --disable-multilib \
    ac_cv_slibdir=/usr/lib

printInfo "Building glibc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
