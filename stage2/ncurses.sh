#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource ncurses
cd ncurses-*


printInfo "Configuring ncurses"

./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --without-debug \
    --without-profile \
    --disable-rpath \
    --with-shared \
    --without-ada \
    --without-normal \
    --enable-widec \
    --enable-largefile \
    --disable-db-install \
    --enable-symlinks \
    --with-pkg-config-libdir=/usr/lib/pkgconfig \
    --without-cxx-binding \
    PKG_CONFIG_LIBDIR=/usr/lib/pkgconfig


printInfo "Building ncurses"
make -j "${STRAPY_BUILD_JOBS}"

# We don't use tic in this step, however.
make -j "${STRAPY_BUILD_JOBS}" install TIC_PATH=$(pwd)/progs/tic  DESTDIR="${STRAPY_INSTALL_DIR}"

for item in "clear" "captoinfo" "infocmp" "infotocap" "reset" "tabs" "tic" "toe" "tput" "tset" ; do
    ln -sv "${STRAPY_TRIPLET}-${item}" "${STRAPY_INSTALL_DIR}/usr/bin/${item}"
done

echo "INPUT(-lncursesw)" > "${STRAPY_INSTALL_DIR}/usr/lib/libncurses.so"
echo "INPUT(-lncursesw)" > "${STRAPY_INSTALL_DIR}/usr/lib/libcurses.so"
