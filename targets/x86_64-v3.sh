#!/bin/true

. $(dirname $(realpath -s $0))/../lib/base.sh

# This profile is intended for modern Intel CPUs, and should happily work on
# AMD Zen+

export STRAPY_TARGET_CFLAGS="--with-arch=x86-64-v2 --with-tune=generic -O2 -fPIC -pipe -mprefer-vector-width=128"
export STRAPY_TARGET_CXXFLAGS="${STRAPY_TARGET_CFLAGS}"
export STRAPY_TARGET_LDFLAGS=""
export STRAPY_TRIPLET="x86_64-strapy-linux"
export STRAPY_TRIPLET32="i686-strapy-linux"

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    export STRAPY_TRIPLET="${STRAPY_TRIPLET}-musl"
fi

export STRAPY_TARGET_LLVM_BACKEND="X86"
export STRAPY_TARGET_ARCH="x86_64"

# The inlude directory in musl
export STRAPY_TARGET_MUSL="${STRAPY_TARGET_ARCH}"
