#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource glibc
cd glibc-*

# Add default toolchain patches into S3
patch -p1 < "${STRAPY_PATCHES_DIR}/glibc/0001-Force-correct-RTLDLIST-for-ldd.patch"
patch -p1 < "${STRAPY_PATCHES_DIR}/glibc/0001-sysdeps-Add-support-for-default-directories.patch"

# Keep only the UTF-8 locales...
supported=./localedata/SUPPORTED
sed -nr '/^(#|SUPPORTED-LOCALES=|.*\/UTF-8)/p' $supported > $supported.new
mv -v $supported.new $supported

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
export PATH="${STRAPY_STAGE1_TREE}/usr/binutils/bin:${STRAPY_STAGE1_TREE}/usr/bin:${PATH}"

printInfo "Configuring glibc"
mkdir build && pushd build
../configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/glibc \
    --sysconfdir=/etc \
    --enable-threads=posix \
    --enable-gnu-indirect-function \
    --enable-multi-arch \
    --enable-plugin \
    --enable-ld=default \
    --enable-clocale=gnu \
    --enable-lto \
    --with-gnu-ld \
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${STRAPY_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${STRAPY_TRIPLET}-ranlib \
    ac_cv_prog_AS=${STRAPY_TRIPLET}-as \
    ac_cv_prog_NM=${STRAPY_TRIPLET}-nm \
    libc_cv_forced_unwind=yes

printInfo "Building glibc"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing glibc"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
make -j "${STRAPY_BUILD_JOBS}" localedata/install-locales DESTDIR="${STRAPY_INSTALL_DIR}"
