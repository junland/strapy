#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource glibc
mv glibc-* glibc32bit
extractSource glibc
mv glibc-* glibc64bit

mkdir -p glibc{32,64}bit/build

export PATH="${SERPENT_INSTALL_DIR}/usr/binutils/bin:${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc -m32"
export CXX="g++ -m32"

# Build 32-bit first
export CFLAGS="-O3 -mstackrealign -fPIC"
export CXXFLAGS="${CFLAGS}"

pushd glibc32bit/build

# Build only US UTF-8 locale for now
echo "SUPPORTED_LOCALES=\
en_US.UTF-8/UTF-8
" > ../localedata/SUPPORTED

printInfo "Configuring glibc (32bit)"
echo "slibdir=/usr/lib32" >> configparms
echo "rtlddir=/usr/lib32" >> configparms
../configure --prefix=/usr \
    --libdir=/usr/lib32 \
    --libexecdir=/usr/lib32/glibc \
    --build="${SERPENT_HOST}" \
    --host="${SERPENT_TRIPLET32}" \
    --with-headers="${SERPENT_INSTALL_DIR}/usr/include" \
    ac_cv_slibdir=/usr/lib32 \
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${SERPENT_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${SERPENT_TRIPLET}-ranlib \
    ac_cv_prog_AS=${SERPENT_TRIPLET}-as \
    ac_cv_prog_NM=${SERPENT_TRIPLET}-nm

printInfo "Building glibc (32bit)"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc (32bit)"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"

# Chronically broken .so scripts.
for broken in "libc.so" "libm.so"; do
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib32/${broken}" -e 's@/usr/lib32/@@g'
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib32/${broken}" -e 's@/usr/lib/@@g'
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib32/${broken}" -e 's@/lib32/@@g'
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib32/${broken}" -e 's@/lib/@@g'
done

popd

export CFLAGS="-O3 -fPIC"
export CXXFLAGS="${CFLAGS}"
export CC="gcc"
export CXX="g++"

pushd glibc64bit/build

# Build only US UTF-8 locale for now
echo "SUPPORTED_LOCALES=\
en_US.UTF-8/UTF-8
" > ../localedata/SUPPORTED

printInfo "Configuring glibc (64bit)"
echo "slibdir=/usr/lib" >> configparms
echo "rtlddir=/usr/lib" >> configparms
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/glibc \
    --build="${SERPENT_HOST}" \
    --host="${SERPENT_TRIPLET}" \
    --with-headers="${SERPENT_INSTALL_DIR}/usr/include" \
    ac_cv_slibdir=/usr/lib \
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${SERPENT_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${SERPENT_TRIPLET}-ranlib \
    ac_cv_prog_AS=${SERPENT_TRIPLET}-as \
    ac_cv_prog_NM=${SERPENT_TRIPLET}-nm

printInfo "Building glibc (64bit)"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc (64bit)"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"

# Chronically broken .so scripts.
for broken in "libc.so" "libm.so"; do
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib/${broken}" -e 's@/usr/lib/@@g'
    sed -i "${SERPENT_INSTALL_DIR}/usr/lib/${broken}" -e 's@/lib/@@g'
done
