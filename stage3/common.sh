#!/bin/true

export SERPENT_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

prepareBuild

export TERM="xterm"
