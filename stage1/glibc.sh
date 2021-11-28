#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource glibc
cd glibc-*

# Build only US UTF-8 locale for now
echo "SUPPORTED_LOCALES=\
en_US.UTF-8/UTF-8
" > localedata/SUPPORTED

export PATH="${STRAPY_INSTALL_DIR}/usr/binutils/bin:${STRAPY_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="-O2"
export CXXFLAGS="-O2"

printInfo "Configuring glibc"
mkdir build && pushd build
echo "slibdir=/usr/lib" >> configparms
echo "rtlddir=/usr/lib" >> configparms
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/glibc \
    --build="${STRAPY_HOST}" \
    --host="${STRAPY_TRIPLET}" \
    --with-headers="${STRAPY_INSTALL_DIR}/usr/include" \
    --disable-multilib \
    --enable-lto \
    --enable-multi-arch \
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${STRAPY_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${STRAPY_TRIPLET}-ranlib \
    ac_cv_prog_AS=${STRAPY_TRIPLET}-as \
    ac_cv_prog_NM=${STRAPY_TRIPLET}-nm \
    CC="gcc" \
    CXX="g++"

printInfo "Building glibc"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

# Chronically broken .so scripts.
for broken in "libc.so" "libm.so"; do
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/usr/lib64/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/usr/lib/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/lib64/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/lib/@@g'
done
