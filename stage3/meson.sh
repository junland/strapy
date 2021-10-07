#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource meson
strapyChrootCd meson-*


printInfo "Building meson"
strapyChroot python3 setup.py build

printInfo "Installing meson"
strapyChroot python3 setup.py install
