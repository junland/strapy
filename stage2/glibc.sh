#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource glibc
cd glibc-*

# Build only US UTF-8 locale for now
echo "SUPPORTED_LOCALES=\
en_US.UTF-8/UTF-8
" > localedata/SUPPORTED

export LD="ld.bfd"
export AR="ar"
export RANLIB="ranlib"
export AS="as"
export NM="nm"
export OBJDUMP="objdump"
export READELF="readelf"
export STRIP="strip"
export CC="gcc"
export CXX="g++"

export CFLAGS="${STRAPY_TARGET_CFLAGS}"
export CXXFLAGS="${STRAPY_TARGET_CXXFLAGS}"

export STRAPY_STAGE1_TREE=$(getInstallDir "1")
export PATH="${STRAPY_STAGE1_TREE}/usr/binutils/bin:${PATH}"

printInfo "Configuring glibc"
mkdir build && pushd build
echo "slibdir=/usr/lib" >> configparms
echo "rtlddir=/usr/lib" >> configparms
../configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --disable-multilib \
    --enable-multi-arch \
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${STRAPY_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${STRAPY_TRIPLET}-ranlib \
    ac_cv_prog_AS=${STRAPY_TRIPLET}-as \
    ac_cv_prog_NM=${STRAPY_TRIPLET}-nm \
    libc_cv_sdt=no

printInfo "Building glibc"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
make -j "${STRAPY_BUILD_JOBS}" localedata/install-locales DESTDIR="${STRAPY_INSTALL_DIR}"

# Chronically broken .so scripts.
for broken in "libc.so" "libm.so"; do
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/usr/lib64/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/usr/lib/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/lib64/@@g'
    sed -i "${STRAPY_INSTALL_DIR}/usr/lib/${broken}" -e 's@/lib/@@g'
done
