#!/bin/true

. $(dirname $(realpath -s $0))/../lib/base.sh

# This profile is intended for modern Intel CPUs, and should happily work on
# AMD Zen+

export SERPENT_TARGET_CFLAGS="-march=haswell -mtune=skylake -O2 -fPIC -pipe -mprefer-vector-width=128"
export SERPENT_TARGET_CXXFLAGS="${SERPENT_TARGET_CFLAGS}"
export SERPENT_TARGET_LDFLAGS=""
export SERPENT_TRIPLET="x86_64-serpent-linux"

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    export SERPENT_TRIPLET="${SERPENT_TRIPLET}-musl"
fi

export SERPENT_TARGET_LLVM_BACKEND="X86"
export SERPENT_TARGET_ARCH="x86_64"

# The inlude directory in musl
export SERPENT_TARGET_MUSL="${SERPENT_TARGET_ARCH}"
