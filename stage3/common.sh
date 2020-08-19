#!/bin/true

export SERPENT_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

prepareBuild

export TERM="xterm"
export CC="clang"
export CXX="clang++"
export LD="ld.lld"
export AR="llvm-ar"
export RANLIB="llvm-ranlib"
export STRIP="llvm-strip"
export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"
export LDFLAGS="${SERPENT_TARGET_LDFLAGS}"
